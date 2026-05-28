_G.nvim_start_time = (vim.uv or vim.loop).hrtime()

-- 禁用不需要的内置插件，减少启动时 source 的 plugin 文件
vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logipat = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_syntax = 1
vim.g.loaded_synmenu = 1
vim.g.loaded_optwin = 1
vim.g.loaded_compiler = 1
vim.g.loaded_bugreport = 1
vim.g.loaded_ftplugin = 1

require("vim._core.ui2").enable({})

require("options")
require("keymaps")
require("autocmds")
require("usercmds")
require("pack")

vim.g.moonflyTransparent = true
vim.cmd("colorscheme catppuccin-mocha")

-- 延迟加载 heavy 模块，避免阻塞启动
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("treesitter")
		require("lsp")
	end,
})
