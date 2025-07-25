local terminal = require("abs.plugins.terminal.feature")
local M = {}

--- Create a user command `:AbstractTerminal <subcommand>` to call plugin functions.
--- Available subcommands:
---   toggle  - Toggle terminal
---
function M.create_user_cmd()
	vim.api.nvim_create_user_command("AbstractTerminal", function(ctx)
		local cmd = ctx.args
		if cmd == "toggle" then
			terminal.toggle_terminal()
		else
			vim.notify(string.format('AbstractTerminal: unknown command "%s"', cmd), vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		complete = function()
			return { "toggle" }
		end,
		desc = "AbstractTerminal plugin: use subcommands (e.g. toggle)",
	})
end

return M
