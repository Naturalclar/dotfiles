if vim.loader then
  vim.loader.enable()
end
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.cmd("source ~/.vim/vimrc")

require("config.lazy")

local builtin = require("telescope.builtin")

-- Setting up nvim-tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
-- vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
-- vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
-- vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
