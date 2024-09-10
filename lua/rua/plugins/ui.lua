return {
  -- search
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
    config = function(_, opts)
      require("spectre").setup(opts)
      local map = vim.keymap.set

      map("n", "<leader>ss", '<cmd>lua require("spectre").open()<CR>', { desc = "Toggle Spectre" })
      map(
        "n",
        "<leader>sw",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        { desc = "Spectre search current word" }
      )
      map(
        "n",
        "<leader>sp",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        { desc = "Spectre search on current file" }
      )
      map(
        "v",
        "<leader>sw",
        '<esc><cmd>lua require("spectre").open_visual()<CR>',
        { desc = "Spectre search current word" }
      )
      map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })
    end,
  },
  {
    "mg979/vim-visual-multi",
    event = "BufReadPost",
  },
  {
    "mistricky/codesnap.nvim",
    build = "make",
    event = "BufRead",
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
    event = "BufRead",
    opts = {},
  },
  {
    "RRethy/vim-illuminate",
    event = "BufRead",
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
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufRead",
    opts = {
      symbol = "│",
      -- options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "lazyterm",
          "mason",
          "neo-tree",
          "notify",
          "toggleterm",
          "Trouble",
          "trouble",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
