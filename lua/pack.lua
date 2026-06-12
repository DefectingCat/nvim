-- =============================================================================
-- 插件管理与懒加载配置 (lua/pack.lua)
-- =============================================================================
-- 本文件使用 Neovim 0.12+ 内置的 vim.pack 管理插件，
-- 并结合自定义懒加载框架 (lua/lazy.lua) 延迟初始化重型插件。
--
-- 职责边界：
--   - 声明插件安装（vim.pack.add）
--   - 调度各插件的加载时机（lazy.on_event / lazy.on_keys / lazy.on_cmd）
--   - 直接初始化轻量插件（notify、cmdline）
--   - 具体的插件配置和键位移至 lua/plugins/*.lua
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
--   InsertEnter    → completion, snippets, pairs
--   BufReadPost    → diff, surround, ai, cursorword
--   VimEnter       → treesitter, lsp, icons
--   按键触发      → pick, fugitive, files, grugfar
--   BufWritePre    → conform
--   命令触发      → ex-colors
-- =============================================================================

local lazy = require("lazy")

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
	-- "https://github.com/aileot/ex-colors.nvim", -- colorscheme 提取与优化
}, { load = false })

-- ---------------------------------------------------------------------------
-- 加载各插件的配置模块（含键位映射）
-- 必须在 vim.pack.add 之后，确保插件路径已注册到 runtimepath
-- ---------------------------------------------------------------------------
require("plugins.git")
require("plugins.pick")
require("plugins.files")
require("plugins.starter")

-- ---------------------------------------------------------------------------
-- mini.notify — 通知消息（直接初始化）
-- ---------------------------------------------------------------------------
-- 替换默认的 vim.notify，提供美观的浮动通知窗口。
-- 轻量，不阻塞启动。使用 pcall 保护首次启动。
local ok_notify, notify = pcall(require, "mini.notify")
if ok_notify then
	notify.setup({
		content = {
			-- 简化格式：只显示消息内容
			format = function(notif)
				return notif.msg
			end,
		},
	})
	vim.notify = notify.make_notify()
	lazy.track("notify")
end

-- ---------------------------------------------------------------------------
-- mini.cmdline — 增强命令行（首次按 : 时加载）
-- ---------------------------------------------------------------------------
-- 提供美观的命令行界面，使用 expr 映射：返回 ":" 让 Vim 继续处理。
vim.keymap.set("n", ":", function()
	-- 首次按下 : 时删除此映射，避免后续重复触发
	vim.keymap.del("n", ":")
	require("mini.cmdline").setup({
		autocorrect = { enable = false },
	})
	lazy.track("cmdline")
	return ":"
end, { expr = true, noremap = true })

-- ---------------------------------------------------------------------------
-- mini.icons — 图标支持（VimEnter 后延迟加载）
-- ---------------------------------------------------------------------------
-- 提供文件类型图标，供 mini.pick、mini.files 等使用。
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("mini.icons").setup()
		lazy.track("icons")
	end,
})

-- ---------------------------------------------------------------------------
-- mini.pairs — 自动括号配对（InsertEnter 懒加载）
-- ---------------------------------------------------------------------------
lazy.on_event("pairs", "InsertEnter", "*", function()
	require("mini.pairs").setup()
end)

-- ---------------------------------------------------------------------------
-- mini.ai — 扩展 a/i textobject（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
lazy.on_event("ai", "BufReadPost", "*", function()
	require("mini.ai").setup()
end)

-- ---------------------------------------------------------------------------
-- mini.cursorword — 自动高亮光标下单词（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
lazy.on_event("cursorword", "BufReadPost", "*", function()
	require("mini.cursorword").setup()
end)

-- ---------------------------------------------------------------------------
-- mini.completion — 自动补全（InsertEnter 懒加载）
-- ---------------------------------------------------------------------------
lazy.on_event("completion", "InsertEnter", "*", function()
	require("mini.completion").setup({
		lsp_completion = {
			auto_setup = true,
		},
	})
end)

-- ---------------------------------------------------------------------------
-- mini.snippets — 代码片段（InsertEnter 懒加载）
-- ---------------------------------------------------------------------------
lazy.on_event("snippets", "InsertEnter", "*", function()
	local MiniSnippets = require("mini.snippets")
	MiniSnippets.setup({
		snippets = {
			MiniSnippets.gen_loader.from_lang(),
		},
	})
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
			style = "sign",
			signs = { add = "│", change = "│", delete = "│" },
		},
		mappings = {
			apply = "gs",
			textobject = "",
		},
	})
end)

-- ---------------------------------------------------------------------------
-- mini.surround — 环绕文本操作（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
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
	local filesFilter = ext and ext ~= "" and "*." .. ext or nil
	local prefills = { filesFilter = filesFilter }

	-- Visual 模式用当前选中文本预填充搜索框；Normal 模式直接打开
	if vim.fn.mode():match("^[vV\22]$") then
		grug.with_visual_selection({ prefills = prefills })
	else
		grug.open({ transient = true, prefills = prefills })
	end
end

-- Normal 和 Visual 模式共用同一个映射，通过 mode 表一次性注册
lazy.on_keys("grugfar", "<leader>sr", { "n", "x" }, load_grug_far, open_grug_far, { desc = "搜索并替换" })

-- ---------------------------------------------------------------------------
-- ex-colors.nvim — colorscheme 提取与优化（命令触发懒加载）
-- ---------------------------------------------------------------------------
-- 仅在执行 :ExColors 时加载，不占用启动时间。
-- 生成的文件保存在 ~/.config/nvim/colors/ex-{colors_name}.lua
lazy.on_cmd("ex-colors", "ExColors", function()
	vim.cmd.packadd("ex-colors.nvim")
	require("ex-colors").setup({
		colors_dir = vim.fn.stdpath("config") .. "/colors",
		clear_highlight = false,
		reset_syntax = false,
		ignore_default_colors = true,
		ignore_clear = true,
		omit_default = true,
		relinker = require("ex-colors.presets").recommended.relinker,
		required_syntaxes = { "diff", "html", "markdown" },
		included_hlgroups = require("ex-colors.presets").recommended.included_hlgroups,
		excluded_hlgroups = require("ex-colors.presets").recommended.excluded_hlgroups,
		included_patterns = require("ex-colors.presets").recommended.included_patterns,
		excluded_patterns = require("ex-colors.presets").recommended.excluded_patterns,
		autocmd_patterns = {
			CmdlineEnter = {
				["*"] = { "^debug%u", "^health%u" },
			},
		},
		embedded_global_options = { "background" },
		embedded_global_variables = {
			"terminal_color_0",
			"terminal_color_1",
			"terminal_color_2",
			"terminal_color_3",
			"terminal_color_4",
			"terminal_color_5",
			"terminal_color_6",
			"terminal_color_7",
			"terminal_color_8",
			"terminal_color_9",
			"terminal_color_10",
			"terminal_color_11",
			"terminal_color_12",
			"terminal_color_13",
			"terminal_color_14",
			"terminal_color_15",
		},
	})
end, { bang = true, desc = "提取当前 colorscheme 为优化版 ex-colors" })
