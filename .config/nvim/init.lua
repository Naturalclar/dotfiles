vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.cmd('source ~/.vim/vimrc')

require("config.lazy")

-- Setting up telescope
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '-uu'
    }
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
    },
  },
}
local builtin = require('telescope.builtin')
vim.keymap = vim.keymap or {}
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Setting up nvim-tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- Setup NeoTree
local config = {
  filtered_items = {
    visible = true, -- when true, they will just be displayed differently than normal items
    hide_dotfiles = false,
    hide_gitignored = true,
    hide_hidden = false, -- only works on Windows for hidden files/directories
    hide_by_name = {
      ".DS_Store",
      "thumbs.db"
      --"node_modules",
    },
    hide_by_pattern = { -- uses glob style patterns
    --"*.meta",
    --"*/src/*/tsconfig.json"
    },
  }
} 



