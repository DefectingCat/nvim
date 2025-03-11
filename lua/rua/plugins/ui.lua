return {
  {
    "nvim-pack/nvim-spectre",
    opts = {},
    keys = {
      { "<leader>ss", '<cmd>lua require("spectre").open()<CR>', desc = "Toggle Spectre" },
      {
        "<leader>sw",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        desc = "Spectre search current word",
      },
      {
        "<leader>sp",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc = "Spectre search on current file",
      },
      {
        "<leader>sw",
        '<esc><cmd>lua require("spectre").open_visual()<CR>',
        desc = "Spectre search current word",
        mode = "v",
      },
    },
  },
  {
    "mg979/vim-visual-multi",
    keys = {
      {
        "<C-n>",
        "<Plug>(VM-Find-Subword-Under)",
        desc = "Start vim visual multi",
        mode = { "n", "v" },
      },
    },
  },
  {
    "mistricky/codesnap.nvim",
    build = "make",
    cmd = {
      "CodeSnap",
      "CodeSnapASCII",
      "CodeSnapHighlight",
      "CodeSnapSave",
      "CodeSnapSaveHighlight",
    },
    opts = {
      mac_window_bar = true,
      title = "RUA",
      code_font_family = "JetBrains Mono NL",
      watermark = "RUA",
      bg_color = "#535c68",
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "BufReadPost",
    opts = {},
  },
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {},
  },
  {
    "j-hui/fidget.nvim", -- lsp messages
    event = "VeryLazy",
    opts = {
      integration = {
        ["nvim-tree"] = {
          enable = false, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
        },
        ["xcodebuild-nvim"] = {
          enable = false, -- Integrate with wojciech-kulik/xcodebuild.nvim (if installed)
        },
      },
      notification = {
        window = {
          winblend = 0, -- Background color opacity in the notification window
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  -- {
  --   "echasnovski/mini.indentscope",
  --   version = false,
  --   event = "BufReadPost",
  --   opts = {
  --     symbol = "│",
  --     -- options = { try_as_border = true },
  --   },
  --   init = function()
  --     vim.api.nvim_create_autocmd("FileType", {
  --       pattern = {
  --         "alpha",
  --         "dashboard",
  --         "fzf",
  --         "help",
  --         "lazy",
  --         "lazyterm",
  --         "mason",
  --         "neo-tree",
  --         "notify",
  --         "toggleterm",
  --         "Trouble",
  --         "trouble",
  --       },
  --       callback = function()
  --         vim.b.miniindentscope_disable = true
  --       end,
  --     })
  --   end,
  -- },
  -- {
  --   "echasnovski/mini.icons",
  --   lazy = true,
  --   opts = {
  --     file = {
  --       [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
  --       ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  --     },
  --     filetype = {
  --       dotenv = { glyph = "", hl = "MiniIconsYellow" },
  --     },
  --   },
  --   init = function()
  --     package.preload["nvim-web-devicons"] = function()
  --       require("mini.icons").mock_nvim_web_devicons()
  --       return package.loaded["nvim-web-devicons"]
  --     end
  --   end,
  -- },
}
