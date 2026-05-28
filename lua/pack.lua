-- =============================================================================
-- 插件管理与懒加载配置 (lua/pack.lua)
-- =============================================================================
-- 本文件使用 Neovim 0.12+ 内置的 vim.pack 管理插件，
-- 并结合自定义懒加载框架 (lua/lazy.lua) 延迟初始化重型插件。
--
-- 插件列表：
--   mini.nvim          - 单体插件集（starter、pick、extra、files、icons、
--                        notify、cmdline、completion、snippets、diff、surround）
--   friendly-snippets  - 社区代码片段集合
--   nvim-treesitter    - 语法树解析与高亮
--   nvim-lspconfig     - LSP 客户端配置
--   mason.nvim         - LSP/DAP/格式化工具安装管理器
--   conform.nvim       - 代码格式化（保存时自动格式化）
--   vim-fugitive       - Git 集成
--   grug-far.nvim      - 搜索与替换
--
-- 懒加载策略：
--   InsertEnter    → completion, snippets
--   BufReadPost    → diff, surround
--   VimEnter       → treesitter, lsp
--   按键触发      → pick, fugitive, files, grugfar
--   BufWritePre    → conform
-- =============================================================================

local lazy = require("lazy")
local pick = require("plugins.pick")
require("plugins.git")

-- 在 VimEnter 时记录完整启动时间（此时 runtime 插件、ShaDa 等已加载完毕），
-- 使启动页显示的耗时更接近 --startuptime 的口径。
-- starter 的 autoopen 在 VimEnter 之后渲染，footer 可以安全读取此值。
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		_G.nvim_vimenter_done = (vim.uv or vim.loop).hrtime()
	end,
})

-- ---------------------------------------------------------------------------
-- 插件安装声明
-- ---------------------------------------------------------------------------
-- vim.pack.add(urls, { load = false }) 将插件下载到 pack 目录，
-- 但不自动加载（load = false）。后续通过 packadd 或 require 按需加载。
-- 所有插件的状态锁定在 nvim-pack-lock.json 中。
vim.pack.add({
	"https://github.com/nvim-mini/mini.nvim", -- 核心 UI/功能插件集
	"https://github.com/rafamadriz/friendly-snippets", -- 代码片段库
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" }, -- 语法树
	"https://github.com/neovim/nvim-lspconfig", -- LSP 配置
	"https://github.com/mason-org/mason.nvim", -- 工具安装器
	"https://github.com/stevearc/conform.nvim", -- 格式化
	"https://github.com/tpope/vim-fugitive", -- Git 集成
	"https://github.com/MagicDuck/grug-far.nvim", -- 搜索替换
}, { load = false })

-- ---------------------------------------------------------------------------
-- mini.starter — 启动页
-- ---------------------------------------------------------------------------
-- 每次打开 Neovim（无文件参数时）显示的欢迎页面，
-- 展示 Neovim ASCII Logo 和启动耗时统计。

-- ASCII art 集合（用于启动页等展示）
local logs = {
	a = {
		"⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷",
		"⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇",
		"⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽",
		"⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕",
		"⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕",
		"⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕",
		"⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄",
		"⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕",
		"⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿",
		"⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟",
		"⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠",
		"⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙",
		"⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣",
	},
	b = {
		"░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░ ",
		"░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░",
		"░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░",
		"░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░",
		"░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░",
		"░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░",
		"░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░",
	},
	c = [[
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣡⣾⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣟⠻⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⡿⢫⣷⣿⣿⣿⣿⣿⣿⣿⣾⣯⣿⡿⢧⡚⢷⣌⣽⣿⣿⣿⣿⣿⣶⡌⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣇⣘⠿⢹⣿⣿⣿⣿⣿⣻⢿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠀⢸⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣻⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡇⠀⣬⠏⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣷⣼⣿⣿⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⠀⠈⠁⠀⣿⡇⠘⡟⣿⣿⣿⣿⣿⣿⣿⣿⡏⠿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡏⠀⠀⠐⠀⢻⣇⠀⠀⠹⣿⣿⣿⣿⣿⣿⣩⡶⠼⠟⠻⠞⣿⡈⠻⣟⢻⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢿⠀⡆⠀⠘⢿⢻⡿⣿⣧⣷⢣⣶⡃⢀⣾⡆⡋⣧⠙⢿⣿⣿⣟⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⡥⠂⡐⠀⠁⠑⣾⣿⣿⣾⣿⣿⣿⡿⣷⣷⣿⣧⣾⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡿⣿⣍⡴⠆⠀⠀⠀⠀⠀⠀⠀⠀⣼⣄⣀⣷⡄⣙⢿⣿⣿⣿⣿⣯⣶⣿⣿⢟⣾⣿⣿⢡⣿⣿⣿⣿⣿
⣿⡏⣾⣿⣿⣿⣷⣦⠀⠀⠀⢀⡀⠀⠀⠠⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣡⣾⣿⣿⢏⣾⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⡴⠀⠀⠀⠀⠀⠠⠀⠰⣿⣿⣿⣷⣿⠿⠿⣿⣿⣭⡶⣫⠔⢻⢿⢇⣾⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡿⢫⣽⠟⣋⠀⠀⠀⠀⣶⣦⠀⠀⠀⠈⠻⣿⣿⣿⣾⣿⣿⣿⣿⡿⣣⣿⣿⢸⣾⣿⣿⣿⣿⣿⣿⣿
⡿⠛⣹⣶⣶⣶⣾⣿⣷⣦⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠉⠛⠻⢿⣿⡿⠫⠾⠿⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⡆⣠⢀⣴⣏⡀⠀⠀⠀⠉⠀⠀⢀⣠⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠿⠛⠛⠛⠛⠛⠛⠻⢿⣿⣿⣿⣿⣯⣟⠷⢷⣿⡿⠋⠀⠀⠀⠀⣵⡀⢠⡿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⢿⣿⣿⠂⠀⠀⠀⠀⠀⢀⣽⣿⣿⣿⣿⣿⣿⣿⣍⠛⠿⣿⣿⣿⣿⣿⣿]],
	d = {
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠋⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠈⠉⠉⠙⠛⠛⠻⢿⣿⡿⠟⠁⠀⣀⣴⣿⣿⣿⣿⣿⠟",
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⣉⣡⠀⣠⣴⣶⣶⣦⠄⣀⡀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⡿⢃⣾",
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⣾⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣠⣾⡟⢡⣾⣿⣿⣿⡿⢋⣴⣿⡿⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⢡⣾⣿",
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠃⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⣼⣿⡟⣰⣿⣿⣿⣿⠏⣰⣿⣿⠟⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢚⣛⢿",
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠸⣿⠟⢰⣿⣿⣿⣿⠃⣾⣿⣿⠏⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⣾",
		"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠻⠻⠃⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢉⣴⣿⣿⣿⣿⡇⠘⣿⣿⠋⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡘⣿",
		"⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⠁⢀⣀⠀⢀⣾⣿⣿⣿⣿⣿⣿⠟⠉⠉⠉⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌",
		"⣿⣿⣿⣿⣿⣿⡿⠁⣀⣤⡀⠀⠈⠻⢿⠀⣼⣿⣷⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣿⣿⣿⠟⠛⠙⠃⠀⣿⣿⣿⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⡿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠁⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿",
		"⣿⠟⠁⢀⣴⣶⣶⣾⣿⣿⣿⣿⣶⡐⢦⣄⠀⠀⠈⠛⢿⣿⣿⣿⣿⡀⠀⠀⠀⠀⢀⣼⡿⢛⣩⣴⣶⣶⣶⣶⣶⣶⣭⣙⠻⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿",
		"⠁⠀⣴⣿⣿⣿⣿⠿⠿⣿⣿⣿⣿⣿⣦⡙⠻⣶⣄⡀⠀⠈⠙⢿⣿⣷⣦⣤⣤⣴⣿⡏⣠⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⠻⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⣿⠋⣠⠔⠀⠀⠻⣿⣿⣿⣿⢉⡳⢦⣉⠛⢷⣤⣀⠀⠈⠙⠿⣿⣿⣿⣿⢸⣿⡄⠻⣿⣿⠟⡈⣿⣿⣿⣿⣿⢉⣿⣧⢹⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⡇⠠⡇⠀⠀⠀⠀⣿⣿⣿⣿⢸⣿⣷⣤⣙⠢⢌⡛⠷⣤⣄⠀⠈⠙⠿⣿⣿⣿⣿⣷⣦⣴⣾⣿⣤⣙⣛⣛⣥⣾⣿⣿⡌⣿⣿⣿⣷⣤⣀⣀⣀⣠⣴⣿⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⣷⡀⠡⠀⠀⠀⣰⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣦⣌⡓⠤⣙⣿⣦⡄⠀⠈⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢡⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⣿⣿⣶⣤⣴⣾⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣷⠀⣶⡄⠀⠈⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⣿⣿⣿⠟⠻⣿⣿⡏⣉⣭⣭⡘⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⡇⢸⡇⢠⡀⠈⠙⠋⠉⠉⠉⠉⠛⠫⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⠛⣿⣿⣀⣀⣾⡿⢀⣿⣿⣿⢻⣷⣦⢈⡙⠻⢿⣿⣿⣿⣿⣿⣿⣿⠀⣿⡇⢸⡇⢸⣿⠀⣦⠀⠀⠶⣶⣦⣀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⠀⢸⣿⣿⣦⣈⡛⠿⠟⣋⣤⣾⣿⣿⣿⣸⣿⣿⢸⡇⢰⡆⢈⡙⠻⢿⣿⣿⣿⠀⢿⡇⢸⡇⢸⣿⢠⣿⡇⣿⡆⢈⡙⠻⠧⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⠀⠀⣝⠛⢿⣿⣿⣿⣿⣿⣿⠟⣁⠀⠀⢈⠛⠿⢸⣇⢸⡇⢸⡇⣶⣦⣌⡙⠻⢄⡀⠁⠘⠇⠘⣿⢸⣿⡇⣿⡇⢸⡛⠷⣦⣄⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
	},
	e = {
		"    ____  __  _____ ",
		"   / __ \\/ / / /   |",
		"  / /_/ / / / / /| |",
		" / _, _/ /_/ / ___ |",
		"/_/ |_|\\____/_/  |_|",
	},
	f = {
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⡤⠤⠤⠤⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⠞⠋⠁⠀⠀⠀⠀⠀⠀⠀⠉⠛⢦⣤⠶⠦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⢀⣴⠞⢋⡽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀⠀⠙⢶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⣰⠟⠁⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡀⠀⠀⠉⠓⠦⣤⣤⣤⣤⣤⣤⣄⣀⠀⠀⠀",
		"⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣷⡄⠀⠀⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣆⠀",
		"⠀⠀⣠⠞⠁⠀⠀⣀⣠⣏⡀⠀⢠⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠿⡃⠀⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡆",
		"⢀⡞⠁⠀⣠⠶⠛⠉⠉⠉⠙⢦⡸⣿⡿⠀⠀⠀⡄⢀⣀⣀⡶⠀⠀⠀⢀⡄⣀⠀⣢⠟⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃",
		"⡞⠀⠀⠸⠁⠀⠀⠀⠀⠀⠀⠀⢳⢀⣠⠀⠀⠀⠉⠉⠀⠀⣀⠀⠀⠀⢀⣠⡴⠞⠁⠀⠀⠈⠓⠦⣄⣀⠀⠀⠀⠀⣀⣤⠞⠁⠀",
		"⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠀⠁⠀⢀⣀⣀⡴⠋⢻⡉⠙⠾⡟⢿⣅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠙⠛⠉⠉⠀⠀⠀⠀",
		"⠘⣦⡀⠀⠀⠀⠀⠀⠀⣀⣤⠞⢉⣹⣯⣍⣿⠉⠟⠀⠀⣸⠳⣄⡀⠀⠀⠙⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠈⠙⠒⠒⠒⠒⠚⠋⠁⠀⡴⠋⢀⡀⢠⡇⠀⠀⠀⠀⠃⠀⠀⠀⠀⠀⢀⡾⠋⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⢸⡀⠸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⢠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣇⠀⠀⠉⠋⠻⣄⠀⠀⠀⠀⠀⣀⣠⣴⠞⠋⠳⠶⠞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⠦⢤⠤⠶⠋⠙⠳⣆⣀⣈⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	},
	g = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}

local starter = require("mini.starter")

-- 所有功能模块列表（用于页脚 "X/Y modules" 统计）。
-- 口径与 lazy._loaded 一致：每个独立初始化的功能模块算一个，
-- 不再按 vim.pack 的插件包统计（如 mini.nvim 包含多个模块）。
local all_modules = {
	"starter",
	"notify",
	"cmdline",
	"icons",
	"pick",
	"files",
	"diff",
	"surround",
	"completion",
	"snippets",
	"treesitter",
	"lsp",
	"conform",
	"lspconfig",
	"mason",
	"fugitive",
	"grugfar",
}

-- 计算 Logo 的最大显示宽度，用于页脚居中计算
local max_header_width = 0
for _, line in ipairs(logs.f) do
	max_header_width = math.max(max_header_width, vim.fn.strdisplaywidth(line))
end

starter.setup({
	autoopen = true, -- 无参数启动时自动打开
	evaluate_single = false, -- 只有一个选项时不自动执行
	items = { { name = " ", action = "", section = "" } }, -- 空选项（仅展示页眉页脚）
	header = table.concat(logs.f, "\n"), -- Logo 文本

	-- 页脚函数：显示启动耗时和模块加载统计
	footer = function()
		-- 已加载的模块数（动态统计，包含直接加载和懒加载）
		local loaded = vim.tbl_count(require("lazy")._loaded)
		local total = #all_modules
		-- 优先使用 VimEnter 时间（runtime 插件、ShaDa 等已加载，最接近 --startuptime），
		-- 回退到 init.lua 完成时间，最后回退到当前时间（理论上不会走到）
		local end_time = _G.nvim_vimenter_done or _G.nvim_init_done or (vim.uv or vim.loop).hrtime()
		local ms = (end_time - _G.nvim_start_time) / 1e6
		local text = string.format("  %d/%d modules | %.0f ms", loaded, total, ms)
		local text_width = vim.fn.strdisplaywidth(text)
		-- 计算左填充空格数以实现居中
		local pad = math.floor((max_header_width - text_width) / 2)
		return string.rep(" ", pad) .. text
	end,

	-- 内容钩子：水平和垂直居中
	content_hooks = {
		starter.gen_hook.aligning("center", "center"),
	},
})

lazy.track("starter")

-- ---------------------------------------------------------------------------
-- mini.files — 文件浏览器（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- 提供悬浮文件浏览器，支持目录导航和文件操作。
-- mini.files setup 配置（复用）
local function setup_mini_files()
	require("mini.files").setup({
		mappings = {
			go_in = "<CR>", -- 回车进入目录或打开文件
			go_in_plus = "L", -- L 进入并同步光标
			go_out = "_", -- _ 返回上级目录
			go_out_plus = "H", -- H 返回上级并同步光标
		},
	})
end

-- - ：在当前文件所在目录打开文件浏览器
lazy.on_keys("files", "-", "n", setup_mini_files, function()
	local MiniFiles = require("mini.files")
	-- 打开当前文件所在目录，并定位到当前文件
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
	MiniFiles.reveal_cwd()
end, { desc = "打开文件浏览器（当前文件目录）" })

-- _ ：在项目根目录（git root）打开文件浏览器
lazy.on_keys("files", "_", "n", setup_mini_files, function()
	local git_root = vim.fs.root(0, ".git")
	-- use_latest = false 避免恢复上次浏览深度，确保只展开根目录一层
	require("mini.files").open(git_root or vim.fn.getcwd(), false)
end, { desc = "打开文件浏览器（项目根目录）" })

-- 在启动页（mini.starter）中也绑定 - / _，
-- 因为 starter buffer 可能拦截全局映射
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniStarterOpened",
	callback = function(args)
		vim.keymap.set("n", "-", function()
			require("lazy").load("files", setup_mini_files)
			local MiniFiles = require("mini.files")
			-- starter 无当前文件，打开工作目录
			MiniFiles.open(vim.fn.getcwd())
		end, { buffer = args.buf, desc = "打开文件浏览器（工作目录）" })

		vim.keymap.set("n", "_", function()
			require("lazy").load("files", setup_mini_files)
			local git_root = vim.fs.root(0, ".git")
			require("mini.files").open(git_root or vim.fn.getcwd(), false)
		end, { buffer = args.buf, desc = "打开文件浏览器（项目根目录）" })
	end,
})

-- ---------------------------------------------------------------------------
-- mini.icons — 图标支持（VimEnter 后延迟加载）
-- ---------------------------------------------------------------------------
-- 提供文件类型图标，供 mini.pick、mini.files 等使用。
-- 在 VimEnter 后 setup，确保 UI 已初始化。
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("mini.icons").setup()
		lazy._loaded["icons"] = true
	end,
})

-- ---------------------------------------------------------------------------
-- mini.notify — 通知消息
-- ---------------------------------------------------------------------------
-- 替换默认的 vim.notify，提供美观的浮动通知窗口。
-- 直接初始化（轻量，不阻塞启动）。
require("mini.notify").setup({
	content = {
		-- 简化格式：只显示消息内容，不附加时间戳等元信息
		format = function(notif)
			return notif.msg
		end,
	},
})
-- 将 vim.notify 重定向到 mini.notify
vim.notify = require("mini.notify").make_notify()
lazy.track("notify")

-- ---------------------------------------------------------------------------
-- mini.cmdline — 增强命令行
-- ---------------------------------------------------------------------------
-- 提供美观的命令行界面，首次按 : 时加载。
-- 使用 expr 映射：返回 ":" 让 Vim 继续处理命令行输入。
vim.keymap.set("n", ":", function()
	-- 首次按下 : 时删除此映射，避免后续重复触发 setup
	vim.keymap.del("n", ":")
	require("mini.cmdline").setup({
		autocorrect = { enable = false }, -- 禁用自动纠正
	})
	lazy.track("cmdline")
	return ":"
end, { expr = true, noremap = true })

-- 诊断位置列表（Quickfix 的本地化版本）
vim.keymap.set("n", "<leader>ds", function()
	vim.diagnostic.setloclist()
end, { desc = "诊断位置列表" })

-- ---------------------------------------------------------------------------
-- mini.pick / mini.extra — 文件查找器（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- 所有 pick 相关映射共用 pick.load_pick() 初始化，确保 mini.pick 和 mini.extra
-- 只在首次使用时 setup 一次。
-- <leader>ff ：文件查找
lazy.on_keys("pick", "<leader>ff", "n", pick.load_pick, function()
	require("mini.pick").builtin.files()
end, { desc = "文件查找" })

-- <leader>fw ：实时 grep（在项目中搜索文本）
lazy.on_keys("pick", "<leader>fw", "n", pick.load_pick, function()
	require("mini.pick").builtin.grep_live()
end, { desc = "项目内实时搜索" })

-- <leader>sk ：键位映射搜索
lazy.on_keys("pick", "<leader>sk", "n", pick.load_pick, function()
	require("mini.extra").pickers.keymaps()
end, { desc = "搜索键位映射" })

-- <leader>fa ：查找所有文件（含隐藏和忽略的文件）
lazy.on_keys("pick", "<leader>fa", "n", pick.load_pick, function()
	require("mini.pick").builtin.cli({
		command = { "rg", "--files", "--hidden", "--no-ignore", "--color=never" },
	})
end, { desc = "查找所有文件（含隐藏/忽略）" })

-- <leader>fh ：帮助标签搜索
lazy.on_keys("pick", "<leader>fh", "n", pick.load_pick, function()
	require("mini.pick").builtin.help()
end, { desc = "搜索帮助标签" })

-- <leader>fo ：最近打开的文件
lazy.on_keys("pick", "<leader>fo", "n", pick.load_pick, function()
	require("mini.extra").pickers.oldfiles()
end, { desc = "最近打开的文件" })

-- <leader>fz ：当前缓冲区行内搜索
lazy.on_keys("pick", "<leader>fz", "n", pick.load_pick, function()
	require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "当前缓冲区行内搜索" })

-- ---------------------------------------------------------------------------
-- vim-fugitive — Git 集成（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- tpope 的 Git 包装插件，提供 :Git 等命令。
local function load_fugitive()
	vim.cmd.packadd("vim-fugitive")
end

-- <leader>gg ：在新标签页中打开 Fugitive 全屏
lazy.on_keys("fugitive", "<leader>gg", "n", load_fugitive, function()
	vim.cmd("tabnew | Git | only")
end, { desc = "Fugitive 全屏新标签" })

-- <leader>gd ：Git diff 垂直分割
lazy.on_keys("fugitive", "<leader>gd", "n", load_fugitive, function()
	vim.cmd("Gvdiffsplit")
end, { desc = "Git diff 分割" })

-- ---------------------------------------------------------------------------
-- mini.completion — 自动补全（InsertEnter 懒加载）
-- ---------------------------------------------------------------------------
-- 轻量级补全引擎，支持 LSP 补全、buffer 单词、路径补全。
lazy.on_event("completion", "InsertEnter", "*", function()
	require("mini.completion").setup({
		lsp_completion = {
			auto_setup = true, -- 自动配置 LSP 补全源
		},
	})
end)

-- ---------------------------------------------------------------------------
-- mini.snippets — 代码片段（InsertEnter 懒加载）
-- ---------------------------------------------------------------------------
-- 代码片段引擎，支持 LSP 片段扩展。
lazy.on_event("snippets", "InsertEnter", "*", function()
	local MiniSnippets = require("mini.snippets")
	MiniSnippets.setup({
		snippets = {
			-- 从 friendly-snippets 加载对应语言的片段
			MiniSnippets.gen_loader.from_lang(),
		},
	})
	-- 启动 LSP 片段服务器（match = false 表示不匹配时不自动触发）
	MiniSnippets.start_lsp_server({ match = false })
end)

-- ---------------------------------------------------------------------------
-- mini.diff — Git diff 标记（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
-- 在 signcolumn 中显示当前 buffer 相对于 git HEAD 的变更标记。
lazy.on_event("diff", "BufReadPost", "*", function()
	require("mini.diff").setup({
		-- 使用 git 作为 diff 源（index = false 表示对比工作区 vs HEAD，不含暂存区）
		source = require("mini.diff").gen_source.git({ index = false }),
		view = {
			style = "sign", -- 以符号形式显示（在 signcolumn 中）
			signs = { add = "│", change = "│", delete = "│" }, -- 统一的竖线符号
		},
		mappings = {
			apply = "gs", -- gs 应用当前 hunk
			textobject = "", -- 禁用文本对象映射
		},
	})
end)

-- ---------------------------------------------------------------------------
-- mini.surround — 环绕文本操作（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
-- 快速添加、删除、修改包围符号（如括号、引号、HTML 标签等）。
lazy.on_event("surround", "BufReadPost", "*", function()
	require("mini.surround").setup()
end)

-- ---------------------------------------------------------------------------
-- 重型模块延迟加载（VimEnter 事件）
-- ---------------------------------------------------------------------------
-- treesitter 和 lsp 是启动时最耗时的模块，
-- 延迟到 VimEnter 事件触发后加载，让编辑器界面先渲染出来。
lazy.on_event("treesitter", "VimEnter", "*", function()
	require("plugins.treesitter").setup()
end)

lazy.on_event("lsp", "VimEnter", "*", function()
	require("plugins.lsp")
end)

-- ---------------------------------------------------------------------------
-- grug-far.nvim — 搜索与替换（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- 提供类似 VS Code 的查找替换界面，支持正则和文件过滤。
local function load_grug_far()
	vim.cmd.packadd("grug-far.nvim")
	require("grug-far").setup({ headerMaxWidth = 80 })
end

local function open_grug_far()
	local grug = require("grug-far")
	-- 根据当前文件扩展名预填充文件过滤器
	local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
	grug.open({
		transient = true, -- 关闭后自动销毁 buffer
		prefills = {
			filesFilter = ext and ext ~= "" and "*." .. ext or nil,
		},
	})
end

-- Normal 模式和 Visual 模式均绑定 <leader>sr
lazy.on_keys("grugfar", "<leader>sr", "n", load_grug_far, open_grug_far, { desc = "搜索并替换" })
lazy.on_keys("grugfar", "<leader>sr", "x", load_grug_far, open_grug_far, { desc = "搜索并替换" })
