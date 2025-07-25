--- @class AbstractTerminalUi
--- @field width? number Fraction of editor width (0.1-1.0)
--- @field height? number Fraction of editor height (0.1-1.0)
--- @field offset_row? number Lines from bottom (>=0)
--- @field offset_col? integer Columns from left (>=0). Calculated if nil.
--- @field border? "none"| "single"| "double"| "rounded" Border style
--- @field title? string Title of terminal
--- @field title_pos? "left" | "center" | "right" Terminal title position

--- @class AbstractTerminalOptions: AbstractTerminalUi
--- @field keymap? table<"toggle", string> Keybindings, e.g. { toggle = "<C-t>" }

--- @class AbstractTerminalState
---@field bufs integer[]               -- all terminal buffer IDs
---@field win integer?                 -- handle for the floating window
---@field current integer              -- which terminal is active (1‑based)
---@field modes table<integer, "t"|"n"> -- last mode in each terminal ("t" for terminal, "n" for normal)
