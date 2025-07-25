local M = {}
local api = vim.api

function M.toggle_terminal()
	---@type AbstractTerminalToggle
	local opts = _G.ABSTRACT_TERMINAL.opts
	local cache = _G.ABSTRACT_TERMINAL.cache

	-- Close existing float
	if M.win and api.nvim_win_is_valid(M.win) then
		_G.ABSTRACT_TERMINAL.cache.toggle_last_mode = vim.api.nvim_get_mode().mode
		api.nvim_win_close(M.win, true)
		M.win = nil
		return
	end

	-- Create scratch buffer if needed
	if not M.buf or not api.nvim_buf_is_valid(M.buf) then
		M.buf = api.nvim_create_buf(false, true)
		api.nvim_set_option_value("bufhidden", "hide", { buf = M.buf })
	end

	-- Compute dimensions
	local cols = vim.o.columns
	local lines = vim.o.lines
	local width = math.floor(cols * (opts.width or 0.6))
	local height = math.floor(lines * (opts.height or 0.4))

	-- Compute percent-based position
	local row = math.floor((lines - height) * (opts.offset_row or 1.0))
	local col = math.floor((cols - width) * (opts.offset_col or 0.5))

	-- Open floating window
	local open_win_opts = {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
	}
	if opts.border then
		open_win_opts.border = opts.border
	end
	M.win = api.nvim_open_win(M.buf, true, open_win_opts)

	-- Launch terminal once
	local bt = api.nvim_get_option_value("buftype", { buf = M.buf })
	if bt ~= "terminal" then
		vim.cmd("terminal")
	end

	if cache.toggle_last_mode == "t" then
		-- Enter insert mode
		vim.cmd("startinsert")
	end
end

return M
