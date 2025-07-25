local M = {}

--- Setup the plugin.
--- @param opts? AbsWindowOptions
--- @return nil
---
function M.setup(opts)
	opts = opts or {} -- for future use
	local commands = require("abs.plugins.window.commands")
	local toggle = require("abs.plugins.window.toggle")

	-- Expose the APIs
	M.toggle = toggle

	commands.create_user_cmd()
end

return M
