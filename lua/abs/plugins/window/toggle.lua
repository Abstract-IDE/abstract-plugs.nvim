local M = {}

--- @class AbsWindowToggleState
local state = {
	winid = nil,
	width = nil,
	height = nil,
}

--- Toggle the current window between full size and its previous size.
--- @return nil
---
function M.maximize()
	local win = vim.api.nvim_get_current_win()
	--- @type integer
	local current_win = win
	if state.winid == current_win then
		-- Restore previous size if available
		if state.height and state.width then
			vim.api.nvim_win_set_height(current_win, state.height)
			vim.api.nvim_win_set_width(current_win, state.width)
		end
		-- Reset state
		state.winid, state.width, state.height = nil, nil, nil
	else
		-- Save current size
		state.winid = current_win
		state.height = vim.api.nvim_win_get_height(current_win)
		state.width = vim.api.nvim_win_get_width(current_win)
		-- Maximize silently
		vim.cmd("silent! wincmd _")
		vim.cmd("silent! wincmd |")
	end
end

return M
