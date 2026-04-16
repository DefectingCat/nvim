return {
  -- disable cmp-nvim-lua (neovim lua api completion)
  { "hrsh7th/cmp-nvim-lua", enabled = false },

  -- disable friendly-snippets (preset snippet library)
  { "rafamadriz/friendly-snippets", enabled = false },

  -- disable nvchad menu (right-click context menu)
  { "nvchad/menu", enabled = false },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- for format on save
    opts = require("configs.conform"),
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("configs.lspconfig")
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      filters = {
        dotfiles = false,
        git_ignored = false,
        custom = {},
        exclude = {},
      },
      git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
      },
    },
  },

  -- oil
  {
    "stevearc/oil.nvim",
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
      {
        "_",
        function()
          require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open parent directory",
      },
    },
    cmd = { "Oil" },
    config = function()
      require("oil").setup({
        default_file_explorer = false,
        delete_to_trash = false,
        view_options = {
          show_hidden = true,
        },
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = false,
          ["<C-h>"] = false,
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = false,
          ["q"] = "actions.close",
          ["<C-l>"] = false,
          ["<C-r>"] = { "actions.refresh" },
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = { "actions.cd", opts = { scope = "tab" } },
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
          ["<leader>ff"] = {
            function()
              require("telescope.builtin").find_files({
                hidden = true,
                cwd = require("oil").get_current_dir(),
              })
            end,
            mode = "n",
            nowait = true,
            desc = "Find files in current directory",
          },
          ["<leader>fw"] = {
            function()
              require("telescope.builtin").live_grep({
                cwd = require("oil").get_current_dir(),
              })
            end,
            mode = "n",
            nowait = true,
            desc = "Live grep in current directory",
          },
        },
        skip_confirm_for_simple_edits = true,
        watch_for_changes = true,
      })
    end,
  },

  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = function()
      local gs = require("gitsigns")

      -- Global navigation keymaps
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { silent = true, desc = desc })
      end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      -- stylua: ignore end

      return {
        signs = {
          delete = { text = "󰍵" },
          changedelete = { text = "󱕖" },
        },
        on_attach = function(bufnr)
          local function bufmap(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = desc })
          end
          -- stylua: ignore start
          bufmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          bufmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          bufmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
          bufmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
          bufmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
          bufmap("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
          bufmap("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          bufmap("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
          bufmap("n", "<leader>ghd", gs.diffthis, "Diff This")
          bufmap("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
          bufmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
          -- stylua: ignore end
        end,
      }
    end,
  },

  -- grug-far: search and replace
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },
}
