local api = vim.api
local feature = require("abs.plugins.terminal.feature")
local M = {}

function M.setup_keymap()
	local keymap = _G.ABSTRACT_TERMINAL.opts.keymap or nil
	if not keymap then
		return
	end

	if keymap["toggle"] then
		-- If in terminal mode, leave to normal first
		if vim.fn.mode() == "t" then
			api.nvim_feedkeys(api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
		end
		-- Map <toggle> in n, i, t modes
		for _, mode in ipairs({ "n", "i", "t" }) do
			vim.keymap.set(mode, keymap["toggle"], function()
				feature.toggle_terminal()
			end, { silent = true, desc = "Toggle floating terminal" })
		end
	end
end

return M
