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
        on_open = function()
          vim.wo.cursorline = true
        end,
        on_close = function()
          vim.wo.cursorline = true
        end,
        display_name = "RUA",
      })
      local horizontal = Terminal:new({
        direction = "horizontal",
        on_open = function()
          vim.wo.cursorline = true
        end,
        on_close = function()
          vim.wo.cursorline = true
        end,
        display_name = "RUA",
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
