return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    lazy = true,
    event = "InsertEnter",
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "BufReadPre",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "BufRead",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
}
