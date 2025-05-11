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
    extensions = { "quickfix", "trouble", "mason", "lazy" },
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
  },
}
