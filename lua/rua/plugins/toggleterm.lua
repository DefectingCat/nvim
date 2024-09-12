return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {},
    keys = function()
      local test = function()
        local Terminal = require("toggleterm.terminal").Terminal
        local float = Terminal:new({
          direction = "float",
          float_opts = {
            border = "curved",
          },
        })
        float:toggle()
      end
      return {
        {
          [[<A-i>]],
          test,
          desc = "Toggle float terminal",
          mode = { "n", "t" },
          -- { noremap = true, silent = true },
        },
      }
    end,
    -- config = function()
    --   local Terminal = require("toggleterm.terminal").Terminal
    --   local float = Terminal:new({
    --     direction = "float",
    --     float_opts = {
    --       border = "curved",
    --     },
    --   })
    --   vim.keymap.set({ "n", "t" }, "<A-i>", function()
    --     float:toggle()
    --   end, { noremap = true, silent = true })
    -- end,
    -- keys = { "<A-i>" },
  },
}
