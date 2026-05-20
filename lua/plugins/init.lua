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
      view = {
        side = "right",
      },
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
      _G.get_oil_winbar = function()
        local dir = require("oil").get_current_dir()
        if dir then
          return vim.fn.fnamemodify(dir, ":.")
        end
        return ""
      end

      require("oil").setup({
        default_file_explorer = false,
        delete_to_trash = false,
        win_options = {
          winbar = "%!v:lua.get_oil_winbar()",
        },
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

  -- persistence: session management
  {
    "folke/persistence.nvim",
    lazy = true,
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- nvim-surround
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    keys = {
      { "ys", desc = "Add Surrounding", mode = "n" },
      { "yS", desc = "Add Surrounding on Line", mode = "n" },
      { "ds", desc = "Delete Surrounding", mode = "n" },
      { "cs", desc = "Change Surrounding", mode = "n" },
      { "S", desc = "Add Surrounding (Visual)", mode = "x" },
    },
  },

  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
    },
  },

  -- codediff: side-by-side diff viewer
  {
    "esmuellert/codediff.nvim",
    lazy = true,
    cmd = "CodeDiff",
    keys = {
      {
        "<leader>gd",
        function()
          vim.cmd("CodeDiff")
        end,
        desc = "CodeDiff git status",
      },
      {
        "<leader>gD",
        function()
          vim.cmd("CodeDiff history")
        end,
        desc = "CodeDiff file history",
      },
    },
    opts = {
      diff = {
        layout = "side-by-side",
        disable_inlay_hints = true,
        jump_to_first_change = true,
        cycle_next_hunk = true,
        cycle_next_file = true,
      },
      -- highlights = {
      --   line_insert = "DiffAdd",
      --   line_delete = "DiffDelete",
      -- },
      explorer = {
        width = 35,
      },
      keymaps = {
        view = {
          quit = "q",
          -- toggle_explorer = "<leader>e",
          -- focus_explorer = "<leader>ce",
          next_hunk = "]c",
          prev_hunk = "[c",
          next_file = "]f",
          prev_file = "[f",
          diff_get = "do",
          diff_put = "dp",
          open_in_prev_tab = "gf",
          toggle_stage = "<leader>cs",
          stage_hunk = "<leader>hs",
          unstage_hunk = "<leader>hu",
          discard_hunk = "<leader>hr",
          hunk_textobject = "ih",
          show_help = "g?",
          align_move = "gm",
          toggle_layout = "t",
        },
      },
    },
  },

  -- markdown-preview: browser preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  -- render-markdown: in-editor rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = false,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.keymap.set("n", "<leader>um", function()
        local rm = require("render-markdown")
        rm.toggle()
        vim.notify("Render Markdown " .. (rm.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
      end, { desc = "Toggle Render Markdown" })
    end,
  },
}
