# mods.nvim

If you use [mods](https://github.com/charmbracelet/mods) in your terminal for
AI queries, and if you use Neovim,
this plugin might be interesting to you. It is simply a way to call mods
from within Neovim and get some quick actions like highlighting code in
the editor and asking AI a question about it.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'ntawileh/mods.nvim'
}
```

## Usage

```lua
require("mods").query({
    -- optional, defaults to current buffer
    bufnr = 0,
    -- optional, defaults to false. if true,
    -- no content from the buffer will be passed in the prompt
    exclude_context = false,
})
```

This will prompt you to select a prompt and then query mods with the selected prompt.

In Normal mode, the entire buffer will be passed in as context
(unless you set `exclude_context` to true).
In Visual mode, only the selected text will be passed in as context.

### Keymaps

My keymaps to use this plugin are:

```lua

vim.keymap.set({ "v", "n" }, "<leader>aa", function()
    require("mods").query({})
    end, {
      desc = "Query Mods AI with selection/buffer as context",
    })

    vim.keymap.set({ "n" }, "<leader>aq", function()
        require("mods").query({
          exclude_context = true,
       })
       end, {
        desc = "Query Mods AI without context",
       })
```

## Configuration

You can call the `setup` function to add more prompts. By default, the plugin
includes the prompts to _Explain_ and _Summarize_ the code/selection

```lua

require("mods").setup({
  prompts = {
         {
             name = "Caveman Explanation",
             prompt = "Explain the following code snippet to a caveman",
         },
     },
 })
```

## Credits

Have to credit [teej_dv](https://github.com/teej_dv) for the great Advent of
Neovim videos, which taught me lua and Neovim plugin development.

Also, thanks to the creators of [mods](https://github.com/charmbracelet/mods)
for building a very cool AI tool!
