return {
  {
    "sindrets/diffview.nvim",
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
      keymaps = {
        view = {
          ["<tab>"] = false,
        },
        file_panel = {
          ["<tab>"] = false,
        },
        file_history_panel = {
          ["<tab>"] = false,
        },
        option_panel = {
          ["<tab>"] = false,
        },
      },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    event = { "BufRead" },
    opts = {
      console_timeout = 10000,
    },
    --[[ config = true, ]]
    config = function(_, opts)
      require("neogit").setup(opts)

      local map = vim.keymap.set
      map("n", "<leader>gd", "<cmd> DiffviewOpen <CR>", { desc = "Open diff view" })
      map("n", "<leader>gg", "<cmd> Neogit <CR>", { desc = "Open Neogit" })
      map("n", "<leader>gh", "<cmd> DiffviewFileHistory % <CR>", { desc = "Open current file history" })
      map("n", "<leader>gc", "<cmd> DiffviewClose <CR>", { desc = "Close Diffview" })
    end,
  },
}
