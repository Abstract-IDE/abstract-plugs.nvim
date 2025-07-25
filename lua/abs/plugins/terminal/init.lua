local commands = require("abs.plugins.terminal.commands")
local keymap = require("abs.plugins.terminal.keymap")
local M = {}

_G.ABSTRACT_TERMINAL = {
	--- @type AbstractTerminalOptions
	opts = {},
	cache = {
		-- very last mode when terminal toggled
		-- this will help to avid auto scroll to bottom in terminal when toggling
		---@type "nt" | "t"
		toggle_last_mode = "t"
	}
}

--- Setup abstract-terminal plugin
--- @param opts? AbstractTerminalOptions default options overrides
function M.setup(opts)
	--- Merge user opts with defaults
	_G.ABSTRACT_TERMINAL.opts = opts or {}


	-- Register commands
	commands.create_user_cmd()

	-- Setup keymap
	keymap.setup_keymap()
end

return M
