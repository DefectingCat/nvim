return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {},
    config = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local float = Terminal:new({
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })
      local horizontal = Terminal:new({
        direction = "horizontal",
      })

      local map = vim.keymap.set
      map({ "n", "t" }, "<A-i>", function()
        float:toggle()
      end, { noremap = true, silent = true })
      map({ "n", "t" }, "<A-u>", function()
        horizontal:toggle()
      end, { noremap = true, silent = true })
    end,
    keys = { "<A-i>", "<A-u>" },
  },
}
