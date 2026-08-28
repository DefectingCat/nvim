-- =============================================================================
-- 插件管理与懒加载配置 (lua/pack.lua)
-- =============================================================================
-- 本文件使用 Neovim 0.12+ 内置的 vim.pack 管理插件，
-- 并结合自定义懒加载框架 (lua/lazy.lua) 延迟初始化重型插件。
--
-- 职责边界：
--   - 声明插件安装（vim.pack.add）
--   - 直接 setup 通用/轻量插件（UI、编辑增强、补全、独立工具）
--   - 功能域插件（git/lsp/pick/files/treesitter/starter）的配置与键位
--     移至 lua/plugins/*.lua，由本文件 require 调度
--
-- 拆分规则：
--   - 配置简单（纯 setup 或少量选项）→ 留在本文件
--   - 配置复杂（含多键位、自定义函数、交互逻辑）→ 移至 plugins/
--
-- 插件列表：
--   mini.nvim          - 单体插件集（starter、pick、extra、files、icons、
--                        notify、cmdline、completion、snippets、surround、
--                        clue、statusline）
--   friendly-snippets  - 社区代码片段集合
--   nvim-treesitter    - 语法树解析与高亮
--   nvim-lspconfig     - LSP 客户端配置
--   mason.nvim         - LSP/DAP/格式化工具安装管理器
--   conform.nvim       - 代码格式化（保存时自动格式化）
--   gitsigns.nvim      - Git inline gutter + hunk 操作（buffer 级）
--   neogit             - Git status 客户端（仓库级，依赖 plenary）
--   codediff.nvim      - side-by-side diff 可视化（文件级）
--   grug-far.nvim      - 搜索与替换
--
-- 懒加载策略：
--   InsertEnter    → completion, snippets, pairs
--   BufReadPost    → gitsigns, surround, ai, cursorword
--   VimEnter       → treesitter, icons
--   代码 FileType  → lsp, mason
--   按键触发      → pick, neogit, codediff, files, grugfar
--   BufWritePre    → conform
--   命令触发      → ex-colors
-- =============================================================================

local lazy = require("lazy")

-- ---------------------------------------------------------------------------
-- 插件安装声明
-- ---------------------------------------------------------------------------
-- mini.nvim 的 starter/notify 会在本文件中直接 require，因此先加入 runtimepath；
-- 其余插件仅登记安装，等各自触发器执行 :packadd 后才进入 runtimepath。
-- 所有插件的状态锁定在 nvim-pack-lock.json 中。
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" }, { load = false })

vim.pack.add({
	"https://github.com/rafamadriz/friendly-snippets", -- 代码片段库
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }, -- 语法树
	"https://github.com/neovim/nvim-lspconfig", -- LSP 配置
	"https://github.com/mason-org/mason.nvim", -- 工具安装器
	"https://github.com/stevearc/conform.nvim", -- 格式化
	"https://github.com/lewis6991/gitsigns.nvim", -- Git inline gutter + hunk 操作
	"https://github.com/nvim-lua/plenary.nvim", -- neogit 依赖
	"https://github.com/NeogitOrg/neogit", -- Git status 客户端
	-- "https://github.com/DefectingCat/neogit", -- Git status 客户端
	"https://github.com/esmuellert/codediff.nvim", -- side-by-side diff 可视化
	"https://github.com/MagicDuck/grug-far.nvim", -- 搜索替换
	"https://github.com/MeanderingProgrammer/render-markdown.nvim", -- Markdown 渲染增强
	-- "https://github.com/aileot/ex-colors.nvim", -- colorscheme 提取与优化
}, {
	load = function() end,
})

-- ---------------------------------------------------------------------------
-- 功能域插件配置（lua/plugins/*.lua）
-- ---------------------------------------------------------------------------
-- 加载各功能域插件的配置模块（含键位映射与自定义逻辑）。
-- 必须在 vim.pack.add 之后：普通插件路径已注册，延迟插件也已完成安装登记。
require("plugins.git")
require("plugins.pick")
require("plugins.files")
require("plugins.starter")
require("plugins.markdown")
require("plugins.neovide")
local lsp = require("plugins.lsp")

-- =============================================================================
-- UI 层：通知、命令行、图标
-- =============================================================================

-- mini.notify — 替换默认 vim.notify，提供浮动通知窗口（直接初始化，轻量不阻塞）
-- 使用 pcall 保护首次启动（插件可能尚未下载完成）
local ok_notify, notify = pcall(require, "mini.notify")
if ok_notify then
	notify.setup({
		lsp_progress = { enable = false },
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

-- mini.cmdline — 增强命令行（首次按 : 时加载）
-- 使用 expr 映射：返回 ":" 让 Vim 继续处理
vim.keymap.set("n", ":", function()
	-- 首次按下 : 时删除此映射，避免后续重复触发
	vim.keymap.del("n", ":")
	require("mini.cmdline").setup({
		autocorrect = { enable = false },
	})
	lazy.track("cmdline")
	return ":"
end, { expr = true, noremap = true })

-- mini.icons — 文件类型图标（VimEnter 后延迟加载）
-- 供 mini.pick、mini.files、mini.statusline 等使用
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("mini.icons").setup()
		lazy.track("icons")

		-- mini.statusline — 状态栏（依赖 mini.icons，故同处 VimEnter）
		-- 最简配置：用内置 section 组合，自适应窗口宽度。
		-- Git/diff 段回退到 gitsigns.nvim（已启用），无需 mini.git/mini.diff。
		require("mini.statusline").setup({ use_icons = true })

		-- 覆盖 section_git / section_diff / section_lsp 返回空串隐藏它们：
		-- - section_git/diff：默认读 gitsigns buffer 变量显示分支和增删改数
		-- - section_lsp：默认显示 '󰰎 +'，加号数量 = attach 的 LSP client 数
		-- combine_groups 会自动跳过空段，不留多余空格。
		require("mini.statusline").section_git = function()
			return ""
		end
		require("mini.statusline").section_diff = function()
			return ""
		end
		require("mini.statusline").section_lsp = function()
			return ""
		end

		-- 覆盖 section_filename：原逻辑宽窗口返回 %F（绝对路径），
		-- 这里改为宽窗口也用 %f（相对路径）。窄窗口降级到 %t（仅文件名）。
		require("mini.statusline").section_filename = function(args)
			local ms = require("mini.statusline")
			if vim.bo.buftype == "terminal" or ms.is_truncated(args.trunc_width) then
				return "%t%m%r"
			end
			return "%f%m%r"
		end
		lazy.track("statusline")
	end,
})

-- =============================================================================
-- 编辑增强：括号配对、textobject、光标高亮、环绕操作
-- =============================================================================

-- mini.pairs — 自动括号配对（InsertEnter 懒加载）
lazy.on_event("pairs", "InsertEnter", "*", function()
	require("mini.pairs").setup()
end)

-- mini.ai — 扩展 a/i textobject（读取文件或新建 Buffer 时懒加载）
lazy.on_event("ai", { "BufReadPost", "BufNewFile", "BufNew" }, "*", function()
	require("mini.ai").setup()
end)

-- mini.cursorword — 自动高亮光标下单词（读取文件或新建 Buffer 时懒加载）
lazy.on_event("cursorword", { "BufReadPost", "BufNewFile", "BufNew" }, "*", function()
	require("mini.cursorword").setup()
end)

-- mini.surround — 环绕文本操作（读取文件或新建 Buffer 时懒加载）
lazy.on_event("surround", { "BufReadPost", "BufNewFile", "BufNew" }, "*", function()
	require("mini.surround").setup({
		mappings = {
			add = "ys",
			delete = "ds",
			replace = "cs",
			find = "",
			find_left = "",
			highlight = "",
			suffix_last = "",
			suffix_next = "",
		},
		search_method = "cover_or_next",
	})
	-- Visual 模式使用 S，避免 ys 前缀让 y 等待 timeoutlen。
	vim.keymap.del("x", "ys")
	vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add("visual")<CR>]], {
		silent = true,
		desc = "Add surrounding to selection",
	})
end)

-- =============================================================================
-- 补全与代码片段（InsertEnter 懒加载）
-- =============================================================================

-- mini.completion — 自动补全引擎（LSP + Buffer）
lazy.on_event("completion", "InsertEnter", "*", function()
	require("mini.completion").setup({
		lsp_completion = {
			auto_setup = true,
		},
	})
	-- setup 只会通过后续 BufEnter 设置 completefunc，需回填当前 Buffer。
	vim.bo.completefunc = "v:lua.MiniCompletion.completefunc_lsp"

	-- 回车确认补全：
	--   有选中项 → 接受选中项（<C-y>）
	--   弹窗可见但无选中项 → 先选第一项再接受（<C-n><C-y>）
	--   无弹窗 → 走 mini.pairs 的换行
	_G.cr_action = function()
		local info = vim.fn.complete_info()
		if info.selected ~= -1 then
			return "\25" -- <C-y>
		end
		if info.pum_visible == 1 then
			return "\14\25" -- <C-n><C-y>
		end
		return require("mini.pairs").cr()
	end
	vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })
end)

-- mini.snippets — 代码片段引擎
lazy.on_event("snippets", "InsertEnter", "*", function()
	vim.cmd("packadd! friendly-snippets")
	local MiniSnippets = require("mini.snippets")
	MiniSnippets.setup({
		snippets = {
			MiniSnippets.gen_loader.from_lang(),
		},
	})
	MiniSnippets.start_lsp_server({ match = false })
end)

-- =============================================================================
-- 重型模块（按实际需要延迟加载）
-- =============================================================================
-- treesitter 在 VimEnter 后初始化；LSP/Mason 仅在首次打开代码文件时初始化。
lazy.on_event("treesitter", "VimEnter", "*", function()
	require("plugins.treesitter").setup()
end)

local lsp_filetypes = {
	"css",
	"scss",
	"less",
	"go",
	"gomod",
	"gowork",
	"gotmpl",
	"html",
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"kotlin",
	"lua",
	"rust",
	"svelte",
	"toml",
}

local lsp_loading = false
local lsp_filetype_loader
local lsp_command_loader
local function load_lsp()
	-- vim.lsp.enable() 会为已有 buffer 重放 FileType；加载中直接返回，避免递归。
	if lsp_loading then
		return
	end
	lsp_loading = true
	local ok = lazy.load("lsp", lsp.setup)
	lsp_loading = false
	if not ok then
		return
	end

	-- 初始化成功后移除两个入口，后续由真实 LSP/Mason 命令接管。
	if lsp_filetype_loader then
		vim.api.nvim_del_autocmd(lsp_filetype_loader)
		lsp_filetype_loader = nil
	end
	if lsp_command_loader then
		vim.api.nvim_del_autocmd(lsp_command_loader)
		lsp_command_loader = nil
	end
end

lsp_filetype_loader = vim.api.nvim_create_autocmd("FileType", {
	pattern = lsp_filetypes,
	callback = function(args)
		-- quickfix、帮助页等特殊 buffer 即使伪装成代码 filetype 也不启动 LSP。
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		load_lsp()
	end,
})

-- 空启动也允许直接执行 Mason 命令；CmdUndefined 后命令会自动重试。
-- Neovim 0.12 的 LSP 管理由内置 :lsp / :checkhealth vim.lsp 提供，无需兼容旧命令。
lsp_command_loader = vim.api.nvim_create_autocmd("CmdUndefined", {
	pattern = {
		"Mason",
		"MasonInstall",
		"MasonLog",
		"MasonUninstall",
		"MasonUninstallAll",
		"MasonUpdate",
	},
	callback = load_lsp,
})

-- =============================================================================
-- mini.clue — 按键提示浮窗（VimEnter 后 setup）
-- =============================================================================
-- 按下前缀键（<Leader>/g/z/<C-w>/[/]）后弹出浮窗，列出后续可用键及描述。
-- 类 which-key 但更轻量，且独立于 'timeoutlen'。
--
-- 不走 lazy.on_keys 懒加载：mini.clue 需自己把前缀键注册为 buffer-local
-- 触发器，与 on_keys 的"包装映射"机制互斥；且 setup 成本极低，无懒加载收益。
--
-- 时序要点（来自官方文档）：触发器必须是 buffer 中最后创建的 buffer-local
-- 映射，否则会被后续 LSP/gitsigns 等的 buffer-local 映射"压住"而失灵。
-- 这里通过 VimEnter 延迟 setup（此时全局映射已全部就位），
-- 并在 LspAttach 中调用 ensure_buf_triggers 兜底。
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local ok_clue, miniclue = pcall(require, "mini.clue")
		if not ok_clue then
			return
		end

		miniclue.setup({
			triggers = {
				{ mode = { "n", "x" }, keys = "<Leader>" },
				{ mode = { "n", "x" }, keys = "g" },
				{ mode = { "n", "x" }, keys = "z" },
				{ mode = "n", keys = "<C-w>" },
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
			},
			clues = {
				-- 内置前缀键描述生成器（g/z/窗口/方括号跳转）
				miniclue.gen_clues.g(),
				miniclue.gen_clues.z(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.square_brackets(),

				-- <Leader> 分组描述（与 keymaps.lua / plugins/*.lua 中的映射对齐）
				{ mode = "n", keys = "<Leader>f", desc = "+文件" },
				{ mode = "n", keys = "<Leader>g", desc = "+Git" },
				{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
				{ mode = "n", keys = "<Leader>c", desc = "+代码" },
				{ mode = "n", keys = "<Leader>d", desc = "+诊断" },
				{ mode = "n", keys = "<Leader>s", desc = "+搜索" },
				{ mode = "n", keys = "<Leader>t", desc = "+标签/终端" },
				{ mode = "n", keys = "<Leader>u", desc = "+用户" },
				{ mode = "n", keys = "<Leader>y", desc = "+复制" },
			},
			window = {
				delay = 300, -- 默认 1000ms 太慢，300ms 接近 which-key 体验
				config = { border = "rounded" },
			},
		})

		-- LSP attach 后重新确保触发器排在最后（LSP 可能创建 buffer-local 映射）
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function()
				pcall(miniclue.ensure_buf_triggers)
			end,
		})

		lazy.track("clue")
	end,
})

-- =============================================================================
-- 独立工具（按键/命令触发懒加载）
-- =============================================================================

-- grug-far.nvim — 搜索与替换（按键触发懒加载）
-- 提供类似 VS Code 的查找替换界面，支持正则和文件过滤
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
