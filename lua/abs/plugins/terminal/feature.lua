local api, fn = vim.api, vim.fn

---@class AbstractTerminalState
local M = {
	bufs = {},
	win = nil,
	current = 0,
	modes = {},
}

-- group for our autocmds that keep the float pinned to its buffer
local float_guard = api.nvim_create_augroup("AbstractTerminalFloatGuard", { clear = true })

-- calculate width, height, and position for the floating window
local function get_dimensions(opts)
	local cols, lines = vim.o.columns, vim.o.lines
	local w = math.floor(cols * (opts.width or 0.6))
	local h = math.floor(lines * (opts.height or 0.4))
	local r = math.floor((lines - h) * (opts.offset_row or 1.0))
	local c = math.floor((cols - w) * (opts.offset_col or 0.5))
	return w, h, r, c
end

-- refresh the title bar to show "Term X/Y"
local function update_title()
	if M.win and api.nvim_win_is_valid(M.win) then
		local opts = _G.ABSTRACT_TERMINAL.opts or {}
		api.nvim_win_set_config(M.win, {
			title = string.format(" %s %d/%d ", opts.title or "Terminal", M.current, #M.bufs),
		})
	end
end

-- make sure nothing else steals our float's buffer
local function guard_buf(buf)
	api.nvim_clear_autocmds({ group = float_guard })
	api.nvim_create_autocmd("BufWinEnter", {
		group = float_guard,
		nested = true,
		callback = function(ctx)
			local win = api.nvim_get_current_win()
			if win == M.win and ctx.buf ~= buf then
				pcall(api.nvim_win_set_buf, M.win, buf)
			end
		end,
	})
end

-- open a new floating window for the given buffer
local function open_floating(buf)
	local opts = _G.ABSTRACT_TERMINAL.opts or {}
	local w, h, r, c = get_dimensions(opts)

	M.win = api.nvim_open_win(buf, true, {
		relative = "editor",
		width = w,
		height = h,
		row = r,
		col = c,
		style = "minimal",
		border = opts.border,
		title = string.format(" %s %d/%d ", opts.title or "Terminal", M.current, #M.bufs),
		title_pos = opts.title_pos or "right",
	})

	guard_buf(buf)
end

-- drop any dead terminal buffers and adjust current index
local function prune_buffers()
	local live, last_modes = {}, {}
	for i, buf in ipairs(M.bufs) do
		if api.nvim_buf_is_valid(buf) then
			table.insert(live, buf)
			last_modes[#live] = M.modes[i]
		end
	end

	M.bufs = live
	M.modes = last_modes

	if #live == 0 then
		M.current = 0
	else
		M.current = math.max(1, math.min(M.current, #live))
	end
end

-- create a brand-new terminal buffer and show it
function M.new_terminal()
	prune_buffers()

	-- if there's already a float, close it first
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_win_close(M.win, true)
		api.nvim_clear_autocmds({ group = float_guard })
		M.win = nil
	end

	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "hide"
	table.insert(M.bufs, buf)
	M.current = #M.bufs
	M.modes[M.current] = "t"

	open_floating(buf)
	api.nvim_set_current_win(M.win)
	api.nvim_set_current_buf(buf)
	fn.jobstart(vim.o.shell, { term = true })
	vim.cmd.startinsert()
end

-- show or hide the floating terminal
function M.toggle_terminal()
	prune_buffers()

	if M.current == 0 then
		return M.new_terminal()
	end

	if M.win and api.nvim_win_is_valid(M.win) then
		M.modes[M.current] = api.nvim_get_mode().mode
		api.nvim_win_close(M.win, true)
		api.nvim_clear_autocmds({ group = float_guard })
		M.win = nil
	else
		open_floating(M.bufs[M.current])
		api.nvim_set_current_win(M.win)
		if M.modes[M.current] == "t" then
			vim.cmd.startinsert()
		end
	end
end

-- helper to move forward or back through terminals
local function _cycle(direction, cycle)
	prune_buffers()
	if #M.bufs <= 1 or not (M.win and api.nvim_win_is_valid(M.win)) then
		return
	end

	-- remember and exit the current mode
	M.modes[M.current] = api.nvim_get_mode().mode
	if M.modes[M.current] == "t" then
		vim.cmd.stopinsert()
	end

	-- do the switch on the next tick to avoid mode-reentry errors
	vim.schedule(function()
		if not (M.win and api.nvim_win_is_valid(M.win)) then
			return
		end

		local idx = M.current + direction
		if idx > #M.bufs then
			if cycle == false then
				return
			end
			idx = 1
		elseif idx < 1 then
			if cycle == false then
				return
			end
			idx = #M.bufs
		end

		api.nvim_win_close(M.win, true)
		M.win = nil
		M.current = idx

		open_floating(M.bufs[M.current])
		api.nvim_set_current_win(M.win)
		update_title()

		if M.modes[M.current] == "t" then
			vim.cmd.startinsert()
		end
	end)
end

-- go to the next terminal (wrap by default)
function M.next_terminal(cycle)
	_cycle(1, cycle)
end

-- go to the previous terminal (wrap by default)
function M.prev_terminal(cycle)
	_cycle(-1, cycle)
end

-- delete the current terminal and pick the next one
function M.close_terminal()
	prune_buffers()
	if M.current == 0 then
		return
	end

	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_set_current_win(M.win)
		if api.nvim_get_mode().mode == "t" then
			vim.cmd.stopinsert()
		end
	end

	local buf = M.bufs[M.current]
	if api.nvim_buf_is_valid(buf) then
		api.nvim_buf_delete(buf, { force = true })
	end

	table.remove(M.bufs, M.current)
	table.remove(M.modes, M.current)

	if #M.bufs == 0 then
		if M.win and api.nvim_win_is_valid(M.win) then
			api.nvim_win_close(M.win, true)
		end
		api.nvim_clear_autocmds({ group = float_guard })
		M.win = nil
		M.current = 0
		return
	end

	if M.current > #M.bufs then
		M.current = #M.bufs
	end

	open_floating(M.bufs[M.current])
	api.nvim_set_current_win(M.win)
	update_title()
	if M.modes[M.current] == "t" then
		vim.cmd.startinsert()
	end
end

return M
