return {
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<cmd> DiffviewOpen <CR>", desc = "Open diff view" },
    },
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
      -- map("n", "<leader>gd", "<cmd> DiffviewOpen <CR>", { desc = "Open diff view" })
      map("n", "<leader>gg", "<cmd> Neogit <CR>", { desc = "Open Neogit" })
      map("n", "<leader>gh", "<cmd> DiffviewFileHistory % <CR>", { desc = "Open current file history" })
      map("n", "<leader>gc", "<cmd> DiffviewClose <CR>", { desc = "Close Diffview" })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")

        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Diff this ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
      end,
    },
  },
}
