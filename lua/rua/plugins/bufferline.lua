return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      themable = true,
      indicator = {
        icon = "",
        style = "none",
      },
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
  config = function(_, opts)
    require("bufferline").setup(opts)

    local map = vim.keymap.set
    map("n", "<leader>la", ":BufferLineCloseOthers<CR>")
    map("n", "<leader>x", ":bp|bd# <CR>")
    map("n", "<S-l>", ":BufferLineCycleNext<CR>")
    map("n", "<S-h>", ":BufferLineCyclePrev<CR>")
    map("n", "<A-l>", ":BufferLineMoveNext<CR>")
    map("n", "<A-h>", ":BufferLineMovePrev<CR>")
  end,
}
