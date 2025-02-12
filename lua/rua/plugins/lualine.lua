return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    local lualine = require("lualine")

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        -- theme = "catppuccin",
        theme = "lackluster",
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
}
