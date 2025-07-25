--- @class AbstractTerminalToggle
--- @field width? number Fraction of editor width (0.1-1.0)
--- @field height? number Fraction of editor height (0.1-1.0)
--- @field offset_row? number Lines from bottom (>=0)
--- @field offset_col? integer Columns from left (>=0). Calculated if nil.
--- @field border? "none"| "single"| "double"| "rounded" Border style

--- @class AbstractTerminalOptions: AbstractTerminalToggle
--- @field keymap? table<"toggle", string> Keybindings, e.g. { toggle = "<C-t>" }
