return {
  "phaazon/hop.nvim",
  branch = "v2",
  keys = {
    {
      "f",
      function()
        local hop = require("hop")
        local directions = require("hop.hint").HintDirection
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
      end,
      desc = "Hop motion search in current line after cursor",
      mode = { "n", "v" },
    },
    {
      "F",
      function()
        local hop = require("hop")
        local directions = require("hop.hint").HintDirection
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
      end,
      desc = "Hop motion search in current line before cursor",
      mode = { "n", "v" },
    },
    -- {
    --   "<leader><leader>",
    --   function()
    --     local hop = require("hop")
    --     hop.hint_words({ current_line_only = false })
    --   end,
    --   desc = "Hop motion search words after cursor",
    --   mode = { "n", "v" },
    -- },
  },
  opts = {
    keys = "etovxqpdygfblzhckisuran",
  },
}
