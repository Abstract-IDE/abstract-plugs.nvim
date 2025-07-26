# abstract-window.nvim

Neovim **window management** plugin that provides a command framework for window-related utilities.

---

## Features

- **Toggle maximize/restore**: Quickly maximize the current window and restore its previous dimensions.

## note: more will implemented in future

## Installation

Use your favorite plugin manager. For [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'Abstract-IDE/abstract-window.nvim',
    opts = {}
}
```

require('abs').window().setup()

---

## Usage

### Command

```vim
:AbstractWindow toggle-win-max
```

- **`toggle-win-max`**: Toggles the current window between maximized and its last size.

### Keybinding Example

Bind to any key you prefer (e.g. `<leader>m`):

```lua
vim.keymap.set('n', '<leader>m', ':AbstractWindow toggle-win-max<CR>',                     { noremap = true, silent = true })
-- OR
vim.keymap.set('n', '<leader>m', function() require("abs").window().toggle.maximize() end, { noremap = true, silent = true })
```

---
