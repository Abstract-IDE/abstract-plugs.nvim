-- abs/plugins/terminal/features.lua
local api, fn = vim.api, vim.fn

---@class AbstractTerminalMultiOpts
---@field width? number            -- fraction of editor width (0.1-1.0)
---@field height? number           -- fraction of editor height (0.1-1.0)
---@field offset_row? number       -- lines from bottom (>=0)
---@field offset_col? number       -- columns from left (>=0)
---@field border? string           -- border style: "none"|"single"|"double"|"rounded"

---@class AbstractTerminalMulti
---@field bufs integer[]                     -- list of terminal buffer IDs
---@field win integer?                       -- floating window handle
---@field current integer                    -- index of current terminal (1-based)
---@field modes table<integer, "t"|"n">    -- last mode per terminal ('t' or 'n')
local M = { bufs = {}, win = nil, current = 0, modes = {} }

-- Augroup to guard against stray buffer entries
---@type integer
local float_guard = api.nvim_create_augroup("AbstractTerminalFloatGuard", { clear = true })

--- Compute float dimensions and position
---@param opts table                         -- any table with width, height, offset_row, offset_col, border
---@return integer width, integer height, integer row, integer col
local function get_dimensions(opts)
	local cols, lines = vim.o.columns, vim.o.lines
	local w = math.floor(cols * (opts.width or 0.6))
	local h = math.floor(lines * (opts.height or 0.4))
	local r = math.floor((lines - h) * (opts.offset_row or 1.0))
	local c = math.floor((cols - w) * (opts.offset_col or 0.5))
	return w, h, r, c
end

--- Update the floating window title
---@return nil
local function update_title()
	if M.win and api.nvim_win_is_valid(M.win) then
		local title = string.format("Term %d/%d", M.current, #M.bufs)
		api.nvim_win_set_config(M.win, { title = title })
	end
end

--- Guard the terminal float against buffer switches
---@param buf integer
---@return nil
local function guard_buf(buf)
	api.nvim_clear_autocmds({ group = float_guard })
	api.nvim_create_autocmd("BufWinEnter", {
		group = float_guard,
		callback = function(ctx)
			local cur_win = api.nvim_get_current_win()
			if cur_win == M.win and ctx.buf ~= buf then
				api.nvim_win_set_buf(M.win, buf)
			end
		end,
	})
end

--- Open or refresh the floating terminal window
---@param buf integer
---@return nil
local function open_floating(buf)
	local opts = _G.ABSTRACT_TERMINAL.opts or {}
	local w, h, r, c = get_dimensions(opts)

	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_win_set_buf(M.win, buf)
		update_title()
		guard_buf(buf)
		api.nvim_set_current_win(M.win)
		return
	end

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

--- Remove invalid buffers and clamp current index
---@return nil
local function prune_buffers()
	local valid_bufs, valid_modes = {}, {}
	for i, buf in ipairs(M.bufs) do
		if api.nvim_buf_is_valid(buf) then
			table.insert(valid_bufs, buf)
			valid_modes[#valid_bufs] = M.modes[i]
		end
	end
	M.bufs = valid_bufs
	M.modes = valid_modes
	if #M.bufs == 0 then
		M.current = 0
	else
		if M.current < 1 then
			M.current = 1
		end
		if M.current > #M.bufs then
			M.current = #M.bufs
		end
	end
end

--- Create and open a new terminal (fresh buffer)
---@return nil
function M.new_terminal()
	prune_buffers()
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
	api.nvim_command("startinsert")
end

--- Toggle the floating terminal (create first if none)
---@return nil
function M.toggle_terminal()
	prune_buffers()
	if M.current == 0 then
		M.new_terminal()
		return
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
			api.nvim_command("startinsert")
		end
	end
end

--- Switch to the next terminal
---@param cycle boolean? defaults to true
---@return nil
function M.next_terminal(cycle)
	prune_buffers()
	if #M.bufs <= 1 then
		return
	end
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_set_current_win(M.win)
		M.modes[M.current] = api.nvim_get_mode().mode
	end
	local idx = M.current + 1
	if idx > #M.bufs then
		if cycle == false then
			return
		end
		idx = 1
	end
	M.current = idx
	open_floating(M.bufs[M.current])
	api.nvim_set_current_win(M.win)
	update_title()
	if M.modes[M.current] == "t" then
		api.nvim_command("startinsert")
	end
end

--- Switch to the previous terminal
---@param cycle boolean? defaults to true
---@return nil
function M.prev_terminal(cycle)
	prune_buffers()
	if #M.bufs <= 1 then
		return
	end
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_set_current_win(M.win)
		M.modes[M.current] = api.nvim_get_mode().mode
	end
	local idx = M.current - 1
	if idx < 1 then
		if cycle == false then
			return
		end
		idx = #M.bufs
	end
	M.current = idx
	open_floating(M.bufs[M.current])
	api.nvim_set_current_win(M.win)
	update_title()
	if M.modes[M.current] == "t" then
		api.nvim_command("startinsert")
	end
end

--- Close the current terminal
---@return nil
function M.close_terminal()
	prune_buffers()
	if M.current == 0 then
		return
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
		api.nvim_command("startinsert")
	end
end

return M
