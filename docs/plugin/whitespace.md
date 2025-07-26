````markdown
# visual_whitespace.nvim

Render whitespace glyphs in selection, insert and normal mode
just like VSCode’s `renderWhitespace: selection`.

---

## Installation

Use your favorite plugin manager.

### lazy.nvim

```lua
{
  'Abstract-IDE/abstract-plugs.nvim',
}
```
````

---

## Configuration

```lua
require('abs').whitespace().setup({
    -- Which modes to activate in (default: visual only)
    modes = { 'n', 'v', 'V', '\22', 'i' },

    -- Override any glyph (defaults shown)
    glyphs = {
        space    = '·',
        tab      = '↦',
        nbsp     = vim.fn.nr2char(0xA0),
        lead     = '‹',
        trail    = '›',
        eol_unix = '↲',
        eol_dos  = '↙',
        eol_mac  = '←',
    },

    -- Skip highlighting in these filetypes / buftypes
    ignore_filetypes = { 'help', 'markdown' },
    ignore_buftypes  = { 'terminal', 'prompt' },
})
```

> All options are optional—defaults will be applied if you omit them.

---

## Usage

`:AbstractWhitespace toggle` Toggle rendering on or off
`:AbstractWhitespace enable` enable rendering
`:AbstractWhitespace disable` disable rendering

above equivalent using APIs


```
require('abs').whitespace().state('toggle')
require('abs').whitespace().state('enable')
require('abs').whitespace().state('disable')
```

---

## Highlight Group

By default the plugin uses a single group, `AbstractWhitespace`.
If it isn’t defined, it falls back to linking `Whitespace`. To customize:

---
