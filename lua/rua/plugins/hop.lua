return {
  "phaazon/hop.nvim",
  branch = "v2",
  event = "BufRead",
  config = function()
    local hop = require("hop")
    hop.setup({ keys = "etovxqpdygfblzhckisuran" })

    local map = vim.keymap.set
    map({ "n", "v" }, "f", function()
      local directions = require("hop.hint").HintDirection
      hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
    end, { desc = "Hop motion search in current line after cursor" })
    map({ "n", "v" }, "F", function()
      local directions = require("hop.hint").HintDirection
      hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
    end, { desc = "Hop motion search in current line before cursor" })
    map({ "n", "v" }, "<leader><leader>", function()
      hop.hint_words({ current_line_only = false })
    end, { desc = "Hop motion search words after cursor" })
  end,
}
