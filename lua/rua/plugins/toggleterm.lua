return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {},
    config = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local float = Terminal:new({
        direction = "float",
        auto_scroll = true,
        persist_mode = false,
        start_in_insert = true,
        float_opts = {
          border = "curved",
        },
        display_name = "RUA",
      })
      local horizontal = Terminal:new({
        direction = "horizontal",
        persist_mode = false,
        auto_scroll = true,
        start_in_insert = true,
        display_name = "RUA",
      })

      local map = vim.keymap.set
      map({ "n", "t" }, "<A-i>", function()
        float:toggle()
      end, { noremap = true, silent = true })
      map({ "n", "t" }, "<A-u>", function()
        horizontal:toggle()
      end, { noremap = true, silent = true })
      map("n", "<C-/>", function()
        horizontal:toggle()
      end)
    end,
    keys = { "<A-i>", "<A-u>", "<C-/>" },
  },
}
