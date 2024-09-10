return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    -- config = function()
    --   require("nvim-ts-autotag").setup({})
    -- end,
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
}
