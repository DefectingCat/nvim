return {
  -- search
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
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
    event = "VeryLazy",
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
    opts = {},
  },
}
