# Terminal

A minimal, floating terminal integration for Neovim.

---

## Installation

Use your preferred plugin manager. For [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Abstract-IDE/abstract-plugs.nvim",
}

require('abs').terminal().setup({
    width      = 0.6,    -- fraction of editor width (0.0–1.0)
    height     = 0.4,    -- fraction of editor height (0.0–1.0)
    offset_row = 0.9,    -- vertical position (0.0–1.0 from top)
    offset_col = 0.5,    -- horizontal position (0.0–1.0 from left)
    border     = "rounded",
    title      = "Terminal"
    title_pos  = "right" -- "left" | "center" | "right"
    keymap     = { toggle = "<C-t>" },
	})

```

> **Note:** All options are optional—defaults will be used if you omit any.

---

## Usage

### Toggle Terminal

Open or close the floating terminal:

```vim
:AbstractTerminal toggle
```

- **`toggle`**: Opens a new terminal if none exist; otherwise shows or hides the current terminal.

---

### Commands (via `:AbstractTerminal`)

| Subcommand | Description                                   |
| ---------- | --------------------------------------------- |
| `toggle`   | Toggle the floating terminal window           |
| `new`      | Create and switch to a brand‑new terminal     |
| `next`     | Move to the next terminal session (wraps)     |
| `prev`     | Move to the previous terminal session (wraps) |
| `close`    | Close the current terminal session            |

```vim
:AbstractTerminal new
:AbstractTerminal next
:AbstractTerminal prev
:AbstractTerminal close
```

above equivalent using APIs

```
require("abs").terminal().new()
require("abs").terminal().prev()
require("abs").terminal().next()
require("abs").terminal().close()
```

---

## Keymaps

### TODO:
