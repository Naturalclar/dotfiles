return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      sources = {
        files = { hidden = true },
      },
      -- your picker configuration comes here
      -- or leave it empty to use the default settings
      win = {
        -- input window
        input = {
          keys = { -- refer to the configuration section below
            ["h"] = { "toggle_hidden", mode = { "n" } },
          },
        },
      },
    },
  },
}
