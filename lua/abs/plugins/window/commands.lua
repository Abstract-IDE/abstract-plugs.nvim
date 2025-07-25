local toggle = require("abs.plugins.window.toggle")
local M = {}

--- Create a user command `:AbstractWindow <subcommand>` to call plugin functions.
--- Available subcommands:
---   toggle-win-max  - Toggle maximize/restore current window
---
function M.create_user_cmd()
	vim.api.nvim_create_user_command("AbstractWindow", function(ctx)
		local cmd = ctx.args
		if cmd == "toggle-win-max" then
			toggle.maximize()
		else
			vim.notify(string.format('AbstractWindow: unknown command "%s"', cmd), vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		complete = function()
			return { "toggle-win-max" }
		end,
		desc = "AbstractWindow plugin: use subcommands (e.g. toggle-win-max)",
	})
end

return M
