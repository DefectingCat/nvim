return {
  {
    "folke/flash.nvim",
    enabled = false,
    keys = {
      -- disable the default flash keymap
      { "s", mode = { "n", "x", "o" }, false },
    },
  },
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xL", mode = { "n" }, false },
      { "<leader>xQ", mode = { "n" }, false },
      { "<leader>xx", mode = { "n" }, false },
      { "<leader>xX", mode = { "n" }, false },
    },
  },
}
