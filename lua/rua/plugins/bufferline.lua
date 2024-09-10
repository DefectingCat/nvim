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
    map("n", "<leader>la", ":BufferLineCloseOthers<CR>", { silent = true })
    map("n", "<leader>x", ":bp|bd# <CR>", { silent = true })
    map("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
    map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })
    map("n", "<A-l>", ":BufferLineMoveNext<CR>", { silent = true })
    map("n", "<A-h>", ":BufferLineMovePrev<CR>", { silent = true })
  end,
}
