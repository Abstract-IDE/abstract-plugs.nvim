local select = require("abs.plugins.whitespace.select")
local M = {}

--- Create a user command `:AbstractWhiteSpace <subcommand>` to call plugin functions.
--- Available subcommands:
---   toggle  - Toggle enable/disable the whitespace
---   enable  - Enable the whitespace
---   disable  -Disble the whitespace
---
function M.create_user_cmd()
	vim.api.nvim_create_user_command("AbstractWhiteSpace", function(ctx)
		--- @type "toggle" | "enable" | "disable"
		local cmd = ctx.args
		if cmd == "toggle" or cmd == "enable" or cmd == "disable" then
			select.change_state(cmd)
		else
			vim.notify(string.format('AbstractWhiteSpace: unknown command "%s"', cmd), vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		complete = function()
			return { "toggle", "enable", "disable" }
		end,
		desc = "AbstractWhiteSpace plugin: use subcommands (e.g. toggle)",
	})
end

return M
