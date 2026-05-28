_G.nvim_start_time = (vim.uv or vim.loop).hrtime()

require("vim._core.ui2").enable({})

require("options")
require("keymaps")
require("autocmds")
require("usercmds")
require("pack")
require("treesitter")
require("lsp")

vim.g.moonflyTransparent = true
vim.cmd("colorscheme catppuccin-mocha")
