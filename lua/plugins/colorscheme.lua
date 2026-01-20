local init_lackluster_icons = function()
  -- local lackluster = require("lackluster")
  require("nvim-web-devicons").setup({
    color_icons = false,
    override = {
      ["default_icon"] = {
        -- color = lackluster.color.gray4,
        color = "#444444",
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
  --   -- priority = 1000,
  --   -- lazy = true,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "macchiato", -- latte, frappe, macchiato, mocha
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
  --       color_overrides = {
  --         rosewater = "#f4dbd6",
  --         flamingo = "#f0c6c6",
  --         pink = "#f5bde6",
  --         mauve = "#B9AEE6",
  --         red = "#A87692",
  --         maroon = "#FD9491",
  --         peach = "#f5a97f",
  --         yellow = "#FCD0A1",
  --         green = "#809FA1",
  --         teal = "#8bd5ca",
  --         sky = "#91d7e3",
  --         sapphire = "#7dc4e4",
  --         blue = "#91B8E9",
  --         lavender = "#b7bdf8",
  --         text = "#DAD0E9",
  --         subtext1 = "#b8c0e0",
  --         subtext0 = "#a5adcb",
  --         overlay2 = "#939ab7",
  --         overlay1 = "#8087a2",
  --         overlay0 = "#6e738d",
  --         surface2 = "#5b6078",
  --         surface1 = "#494d64",
  --         surface0 = "#363a4f",
  --         base = "#24273a",
  --         mantle = "#1e2030",
  --         crust = "#181926",
  --       },
  --       custom_highlights = {},
  --       default_integrations = true,
  --       integrations = {
  --         cmp = true,
  --         gitsigns = true,
  --         nvimtree = true,
  --         treesitter = true,
  --         alpha = true,
  --         mini = {
  --           enabled = true,
  --           indentscope_color = "",
  --         },
  --         mason = true,
  --         markdown = true,
  --         dap = true,
  --         dap_ui = true,
  --         which_key = false,
  --         native_lsp = {
  --           enabled = true,
  --           virtual_text = {
  --             errors = { "italic" },
  --             hints = { "italic" },
  --             warnings = { "italic" },
  --             information = { "italic" },
  --             ok = { "italic" },
  --           },
  --           underlines = {
  --             errors = { "underline" },
  --             hints = { "underline" },
  --             warnings = { "underline" },
  --             information = { "underline" },
  --             ok = { "underline" },
  --           },
  --           inlay_hints = {
  --             background = true,
  --           },
  --         },
  --         telescope = {
  --           enabled = true,
  --           -- style = "nvchad"
  --         },
  --         -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
  --       },
  --     })
  --     -- vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  -- {
  --   "aileot/ex-colors.nvim",
  --   lazy = true,
  --   cmd = "ExColors",
  --   ---@type ExColors.Config
  --   opts = {},
  -- },
  -- {
  --   "nvim-tree/nvim-web-devicons",
  --   lazy = true,
  --   init = init_lackluster_icons,
  -- },
  -- {
  --   "slugbyte/lackluster.nvim",
  --   lazy = true,
  --   priority = 1000,
  --   init = init_lackluster,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "lackluster",
      -- colorscheme = "ex-lackluster",
      -- colorscheme = "catppuccin",
      colorscheme = "ex-catppuccin-mocha",
    },
  },
}
