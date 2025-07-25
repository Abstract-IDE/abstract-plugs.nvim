Simple terminal for neovim

---

## Installation

Use your favorite plugin manager. For [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'Abstract-IDE/abstract-terminal.nvim',
    opts = {
		height = 0.4, -- value range between: 0.0 to 1.0
		width = 0.6, -- value range between: 0.0 to 1.0
		offset_row = 0.9, -- vertical: value range between: 0.0 to 1.0
		offset_col = 0.5, -- horizontal: value range between: 0.0 to 1.0
		border = "rounded",
		keymap = { toggle = "<C-t>" },
	}
}
```

---

## Usage

### Command

```vim
:AbstractTerminal toggle
```

- **`toggle`**: Toggles the terminal. opens new terminal if no terminal found

---
