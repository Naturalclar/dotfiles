return {
  -- highlihgt colors in css, javascript
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      "css",
      "javascript",
      "typescript",
      "typescriptReact",
    })
  end,
}
