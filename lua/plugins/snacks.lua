return {
  "snacks.nvim",
  keys = {
    { "<leader><leader>", mode = { "n", "x", "o" }, false },
    { "<leader>ff", mode = { "n", "x", "o" }, false },
    { "<leader>fb", mode = { "n", "x", "o" }, false },
    { "<leader>bb", mode = { "n", "x", "o" }, false },
    { "<leader>bd", mode = { "n", "x", "o" }, false },
    { "<leader>bD", mode = { "n", "x", "o" }, false },
    { "<leader>bo", mode = { "n", "x", "o" }, false },
  },
  opts = {
    scroll = { enabled = false },
    -- https://github.com/folke/snacks.nvim/discussions/860#discussioncomment-12027395
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
      layouts = {
        sidebar = {
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
