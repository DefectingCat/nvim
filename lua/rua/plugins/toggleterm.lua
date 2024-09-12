return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {},
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local float = Terminal:new({
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })
      -- vim.keymap.set({ "n", "t" }, "<C-\\>", function()
      --   float:toggle()
      -- end, { noremap = true, silent = true })
      return {
        {
          [[<A-i>]],
          function()
            float:toggle()
          end,
          desc = "Toggle float terminal",
          mode = { "n", "t" },
          -- { noremap = true, silent = true },
        },
      }
    end,
    config = function() end,
  },
}
