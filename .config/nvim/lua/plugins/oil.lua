return {
  "stevearc/oil.nvim",
  opts = {},
  dependencides = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      },
    })
  end,
  keys = {
    { "-", ":Oil<CR>", { noremap = true, silent = true } },
  },
}
