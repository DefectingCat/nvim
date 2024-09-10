return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      -- mode = "tabs",
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      themable = true,
      offsets = {
        {
          filetype = "NvimTree",
          text = "",
          text_align = "left",
          separator = true,
        },
      },
    },
  },
}
