local api = vim.api
local fn = vim.fn

local M = {}

---@type AbstractWspState
local state = { enabled = true, selection = {} }
local NS = api.nvim_create_namespace("AbstractWsp")
local NBSP = fn.nr2char(0xA0)
local WS_PATTERN = "[ \t" .. NBSP .. "]"
M.NS = NS

--- Return true if the current mode is one of cfg.modes
---@param modes table<string>
---@return boolean
local function is_active_mode(modes)
	local current_mode = fn.mode(1)
	for _, mode in ipairs(modes) do
		if current_mode == mode then
			return true
		end
	end
	return false
end

--- Determine if plugin should run (not ignored/binary)
---@param opts AbstractWspOptions
---@return boolean
local function is_allowed(opts)
	if opts.ignore_buftypes[vim.bo.buftype] or opts.ignore_filetypes[vim.bo.filetype] then
		return false
	end
	return not vim.bo.binary
end

--- Compute leading/trailing whitespace bounds
---@param line string
---@return number lead_end, number trail_start
local function compute_bounds(line)
	local prefix = line:match("^[ \t" .. NBSP .. "]*") or ""
	local lead_end = #prefix + 1
	local suffix = line:match("[ \t" .. NBSP .. "]*$") or ""
	local trail_start = #line - #suffix + 1
	return lead_end, trail_start
end

--- Pick glyph for a whitespace character
---@param opts AbstractWspOptions
---@param ch string
---@param col number
---@param lead_end number
---@param trail_start number
---@return string?
local function pick_glyph(opts, ch, col, lead_end, trail_start)
	if ch == "\t" then
		return opts.glyphs.tab
	elseif ch == NBSP then
		return opts.glyphs.nbsp
	elseif ch == " " then
		if col < lead_end then
			return opts.glyphs.lead
		elseif col >= trail_start then
			return opts.glyphs.trail
		else
			return opts.glyphs.space
		end
	end
	return nil
end

--- Collect extmarks for a line range
---@param opts AbstractWspOptions
---@param bufnr number
---@param row number
---@param s_col number
---@param e_col number
---@param fileformat string
---@return {row:number, col:number, glyph:string}[]
local function marks_for_line(opts, bufnr, row, s_col, e_col, fileformat)
	local line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
	local lead_end, trail_start = compute_bounds(line)
	local marks = {}
	local idx = s_col
	while true do
		local col = line:find(WS_PATTERN, idx, false)
		if not col or col > e_col then
			break
		end
		local ch = line:sub(col, col)
		local glyph = pick_glyph(opts, ch, col, lead_end, trail_start)
		if glyph then
			marks[#marks + 1] = { row = row, col = col, glyph = glyph }
		end
		idx = col + 1
	end
	if e_col > #line then
		local eol_key = "eol_" .. (fileformat or "unix")
		local eol_g = opts.glyphs[eol_key] or opts.glyphs.eol_unix
		marks[#marks + 1] = { row = row, col = #line + 1, glyph = eol_g }
	end
	return marks
end

--- Called at the start of a buffer redraw
---@return boolean
function M.on_start()
	local opts = _G.ABSTRACT_WSP.opts
	local modes = opts.modes or {}
	if not state.enabled or not is_active_mode(modes) or not is_allowed(opts) then
		return false
	end

	local m = fn.mode(1)
	if m == "n" then
		-- render across every visible line in the window
		local top = vim.fn.line("w0")
		local bot = vim.fn.line("w$")
		state.selection = {}
		for row = top, bot do
			-- show from column 1 through end of line
			state.selection[row] = { start = 1, ["end"] = math.huge }
		end
	elseif m == "i" then
		-- cover full buffer (or visible region) in insert mode:
		local line_count = api.nvim_buf_line_count(0)
		state.selection = {}
		for row = 1, line_count do
			state.selection[row] = { start = 1, ["end"] = math.huge }
		end
	else
		local spos = fn.getpos("v")
		local epos = fn.getpos(".")
		local regs = fn.getregionpos(spos, epos, { type = m, eol = true })
		state.selection = {}
		for _, r in ipairs(regs) do
			local row = r[1][2]
			state.selection[row] = { start = r[1][3], ["end"] = r[2][3] }
		end
	end

	return true
end

--- Called for each visible line after on_start
---@param _ any
---@param winid number
---@param bufnr number
---@param lnum0 number
function M.on_line(_, winid, bufnr, lnum0)
	if winid ~= api.nvim_get_current_win() then
		return
	end
	local row = lnum0 + 1
	local range = state.selection[row]
	if not range then
		return
	end
	local fmt = vim.bo[bufnr].fileformat or "unix"
	for _, m in ipairs(marks_for_line(_G.ABSTRACT_WSP.opts, bufnr, row, range.start, range["end"], fmt)) do
		api.nvim_buf_set_extmark(bufnr, NS, m.row - 1, m.col - 1, {
			virt_text = { { m.glyph, "AbstractWhitespace" } },
			virt_text_pos = "overlay",
			hl_mode = "combine",
			ephemeral = true,
		})
	end
end

--- Toggle rendering on/off
--- @param to "enable" | "disable" | "toggle"
function M.change_state(to)
	state.enabled = (to == "toggle" and not state.enabled) or (to == "enable" and true or false)

	vim.notify("AbstractWhitespace " .. (state.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

return M
