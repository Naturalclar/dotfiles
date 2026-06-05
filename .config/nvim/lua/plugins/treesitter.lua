return {
  "nvim-treesitter/nvim-treesitter",
  init = function()
    -- tell treesitter to use the markdown parser for mdx files
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
