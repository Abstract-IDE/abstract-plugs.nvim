-- Whitespace Render (VSCode-like)
-- THANKS:
--    https://github.com/mcauley-penney/visual-whitespace.nvim
--    for idea and inspiration

local M = {}
_G.ABSTRACT_WSP = {
	--- @type AbstractWspOptions
	opts = {
		modes = { "v", "V", "\22" }, -- visual by default
		glyphs = {
			space = "·",
			tab = "↦",
			nbsp = vim.fn.nr2char(0xA0),
			lead = "‹",
			trail = "›",
			eol_unix = "↲",
			eol_dos = "↙",
			eol_mac = "←",
		},
		ignore_filetypes = { "help", "markdown" },
		ignore_buftypes = { "terminal", "prompt" },
	},
}

---@param opts? AbstractWspOptions
function M.setup(opts)
	opts = vim.tbl_deep_extend("force", _G.ABSTRACT_WSP.opts, opts or {})
	_G.ABSTRACT_WSP.opts = opts

	local ok = pcall(vim.api.nvim_get_hl, 0, { name = "AbstractWhitespace" })
	if not ok then
		vim.api.nvim_set_hl(0, "AbstractWhitespace", { link = "Whitespace" })
	end

	local select = require("abs.plugins.whitespace.select")
	vim.api.nvim_set_decoration_provider(select.NS, { on_start = select.on_start, on_line = select.on_line })

	require("abs.plugins.whitespace.commands").create_user_cmd()

	-- Expose the APIs
	M.state = select.change_state
end

return M
