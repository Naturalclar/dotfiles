return {
  "stevearc/oil.nvim",
  opts = {},
  dependencides = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup()
  end,
  keys = {
    { "-", ":Oil<CR>", { noremap = true, silent = true } },
  },
}
