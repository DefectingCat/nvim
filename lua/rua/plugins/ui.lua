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
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
}
