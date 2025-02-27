local init_lackluster_icons = function()
  local lackluster = require("lackluster")
  require("nvim-web-devicons").setup({
    color_icons = false,
    override = {
      ["default_icon"] = {
        color = lackluster.color.gray4,
        name = "Default",
      },
    },
  })
end
local init_lackluster = function()
  require("ex-colors").setup({
    -- included_patterns = require("ex-colors.presets").recommended.included_patterns + {
    --   "^Cmp%u", -- hrsh7th/nvim-cmp
    --   '^GitSigns%u', -- lewis6991/gitsigns.nvim
    --   '^RainbowDelimiter%u', -- HiPhish/rainbow-delimiters.nvim
    -- },
    autocmd_patterns = {
      CmdlineEnter = {
        ["*"] = {
          "^debug%u",
          "^health%u",
        },
      },
      -- FileType = {
      --   ['Telescope*'] = {
      --     '^Telescope%u', -- nvim-telescope/telescope.nvim
      --   },
      -- },
    },
  })
  require("lackluster").setup({
    tweak_syntax = {
      string = "default",
      string_escape = "default",
      comment = "#3b3b3b",
      builtin = "default", -- builtin modules and functions
      type = "default",
      keyword = "default",
      keyword_return = "default",
      keyword_exception = "default",
    },
    tweak_background = {
      normal = "none",
    },
  })
  -- vim.cmd.colorscheme("lackluster")
  -- vim.cmd.colorscheme("lackluster-hack")
  -- vim.cmd.colorscheme("lackluster-mint")
end

return {
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   lazy = false,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "mocha", -- latte, frappe, macchiato, mocha
  --       background = { -- :h background
  --         light = "latte",
  --         dark = "mocha",
  --       },
  --       transparent_background = true, -- disables setting the background color.
  --       show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
  --       term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
  --       dim_inactive = {
  --         enabled = false, -- dims the background color of inactive window
  --         shade = "dark",
  --         percentage = 0.15, -- percentage of the shade to apply to the inactive window
  --       },
  --       no_italic = false, -- Force no italic
  --       no_bold = false, -- Force no bold
  --       no_underline = false, -- Force no underline
  --       styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
  --         comments = { "italic" }, -- Change the style of comments
  --         conditionals = { "italic" },
  --         loops = {},
  --         functions = {},
  --         keywords = {},
  --         strings = {},
  --         variables = {},
  --         numbers = {},
  --         booleans = {},
  --         properties = {},
  --         types = {},
  --         operators = {},
  --         -- miscs = {}, -- Uncomment to turn off hard-coded styles
  --       },
  --       color_overrides = {},
  --       custom_highlights = {},
  --       default_integrations = true,
  --       integrations = {
  --         cmp = true,
  --         gitsigns = true,
  --         nvimtree = true,
  --         treesitter = true,
  --         notify = false,
  --         mini = {
  --           enabled = true,
  --           indentscope_color = "",
  --         },
  --         -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
  --       },
  --     })
  --     -- vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "wheat-thin-wiens/rei.nvim" },
    event = "VimEnter",
    config = function()
      local lualine = require("lualine")

      -- configure lualine with modified theme
      lualine.setup({
        options = {
          -- theme = "catppuccin",
          -- theme = "lackluster",
          theme = "rei",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        extensions = { "quickfix", "trouble", "mason", "lazy", "nvim-tree" },
        sections = {
          lualine_x = {
            { "encoding" },
            { "fileformat" },
            { "filetype" },
          },
          -- lualine_y = {
          --   { "progress", color = { bg = "#de9aa3", fg = "#000000" } },
          -- },
          -- lualine_z = {
          --   { "location", color = { bg = "#eac8c7" } },
          -- },
        },
      })
    end,
  },
  {
    "aileot/ex-colors.nvim",
    lazy = true,
    cmd = "ExColors",
    ---@type ExColors.Config
    opts = {},
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    -- init = init_lackluster_icons,
  },
  {
    "slugbyte/lackluster.nvim",
    lazy = true,
    -- priority = 1000,
    -- init = init_lackluster,
  },
  {
    "wheat-thin-wiens/rei.nvim",
    -- priority = 1000,
    lazy = true,
    config = function()
      require("rei").setup({
        styles = {
          comments = { italic = true },
          keywords = {},
          identifiers = {},
          functions = { italic = true, bold = true },
          variables = {},
          booleans = {},
          loops = { italic = true },
        },
        integrations = {
          gitsigns = true,
          indent_blankline = true,
          lsp = true,
          mason = true,
          neotree = true,
          render_markdown = true,
          telescope = true, -- 'borderless' theme also available, leave as true for default theme
          treesitter = true,
          which_key = true,
        },
        transparency = true, -- Enables / Disables background transparency
        terminal_colors = true,
        highlight_overrides = {},
      })
      -- vim.cmd.colorscheme("rei")
    end,
  },
}
