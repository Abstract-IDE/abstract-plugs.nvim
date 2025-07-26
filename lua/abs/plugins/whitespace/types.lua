---@class AbstractWspOptions
---@field modes? table<string> Enable in these mode (eg: v, V, "\22")
---@field glyphs? table<string, string> Glyphs for space, tab, nbsp, lead, trail, eol_unix, eol_dos, eol_mac
---@field ignore_filetypes? table<string, boolean>
---@field ignore_buftypes? table<string, boolean>

---@class AbstractWspState
---@field enabled boolean
---@field selection table<number, {start:number, ["end"]:number}>
