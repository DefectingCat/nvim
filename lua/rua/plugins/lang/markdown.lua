return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },
  -- {
  --   "OXY2DEV/markview.nvim",
  --   ft = "markdown",
  -- },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "norg", "rmd", "org" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
    },
    ft = { "markdown", "norg", "rmd", "org" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      -- LazyVim.toggle.map("<leader>um", {
      --   name = "Render Markdown",
      --   get = function()
      --     return require("render-markdown.state").enabled
      --   end,
      --   set = function(enabled)
      --     local m = require("render-markdown")
      --     if enabled then
      --       m.enable()
      --     else
      --       m.disable()
      --     end
      --   end,
      -- })
    end,
  },
}
