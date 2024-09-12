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
      vim.keymap.set({ "n", "t" }, "<A-i>", function()
        float:toggle()
      end, { noremap = true, silent = true })
    end,
    keys = { "<A-i>" },
  },
}
