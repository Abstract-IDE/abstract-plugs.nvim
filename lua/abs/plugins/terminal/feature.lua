-- abs/plugins/terminal/features.lua
local api = vim.api
local fn = vim.fn

---@class AbstractTerminalFeature
---@field buf integer?  -- the terminal buffer
---@field win integer?  -- the floating window
local M = {
	buf = nil,
	win = nil,
}

-- augroup to guard against stray buffer‑switches
local float_guard = api.nvim_create_augroup("AbstractTerminalFloatGuard", { clear = true })

function M.toggle_terminal()
	local opts = _G.ABSTRACT_TERMINAL.opts
	local cache = _G.ABSTRACT_TERMINAL.cache

	-- close if already open
	if M.win and api.nvim_win_is_valid(M.win) then
		cache.toggle_last_mode = api.nvim_get_mode().mode
		api.nvim_win_close(M.win, true)
		M.win = nil
		api.nvim_clear_autocmds({ group = float_guard })
		return
	end

	-- create or reuse a hidden scratch buffer
	if not M.buf or not api.nvim_buf_is_valid(M.buf) then
		M.buf = api.nvim_create_buf(false, true)
		vim.bo[M.buf].bufhidden = "hide"
	end

	-- compute size & position
	local cols, lines = vim.o.columns, vim.o.lines
	local width = math.floor(cols * (opts.width or 0.6))
	local height = math.floor(lines * (opts.height or 0.4))
	local row = math.floor((lines - height) * (opts.offset_row or 1.0))
	local col = math.floor((cols - width) * (opts.offset_col or 0.5))

	-- open the floating window
	M.win = api.nvim_open_win(M.buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = opts.border,
	})

	-- start a real terminal if this isn't one yet
	if vim.bo[M.buf].buftype ~= "terminal" then
		fn.jobstart(vim.o.shell, { term = true })
	end

	-- restore insert-mode if we last closed from terminal
	if cache.toggle_last_mode == "t" then
		api.nvim_command("startinsert")
	end

	-- guard: snap any other buffer back to our terminal
	api.nvim_create_autocmd("BufWinEnter", {
		group = float_guard,
		callback = function(ctx)
			local cur_win = api.nvim_get_current_win()
			if cur_win == M.win and ctx.buf ~= M.buf then
				api.nvim_win_set_buf(M.win, M.buf)
			end
		end,
	})
end

return M
