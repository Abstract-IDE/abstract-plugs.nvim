local M = {}

-- === export PLUGINS === --
M.window = function()
	return require("abs.plugins.window")
end
M.terminal = function()
	return require("abs.plugins.terminal")
end

M.whitespace = function()
	return require("abs.plugins.whitespace")
end

return M
