return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      -- theme = "catppuccin",
      -- theme = "lackluster",
      -- theme = "rei",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    -- extensions = { "quickfix", "trouble", "mason", "lazy" },
    sections = {
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        "filename",
        -- { LazyVim.lualine.pretty_path() },
      },
      lualine_x = {
        { "encoding" },
        { "fileformat" },
        { "filetype" },
      },
      lualine_y = {
        { "progress" },
      },
      lualine_z = {
        { "location" },
      },
    },
  },
}
