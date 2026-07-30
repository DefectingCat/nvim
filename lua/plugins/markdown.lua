-- =============================================================================
-- Markdown 渲染增强 (lua/plugins/markdown.lua)
-- =============================================================================
-- 本模块配置 MeanderingProgrammer/render-markdown.nvim 插件，
-- 用于在 buffer 内实时渲染标题、代码块、表格、列表、Callout 等 Markdown 元素。
--
-- 懒加载策略：
--   1. FileType 事件：当打开 markdown/quarto/vimwiki/codecompanion 等类型文件时自动加载
--   2. 按键触发：<leader>tm 切换渲染
--   3. 命令触发：:RenderMarkdown
-- =============================================================================

local lazy = require("lazy")

local function load_render_markdown()
	vim.cmd.packadd("render-markdown.nvim")
	require("render-markdown").setup({
		-- 默认依赖 mini.icons / nvim-web-devicons，按需渲染标题与图标
		file_types = { "markdown", "quarto", "vimwiki", "codecompanion" },
	})
end

-- 1. FileType 事件延迟加载
lazy.on_event("render-markdown", "FileType", { "markdown", "quarto", "vimwiki", "codecompanion" }, load_render_markdown)

-- 2. 按键 <leader>tm 切换 Markdown 渲染
lazy.on_keys("render-markdown", "<leader>tm", "n", load_render_markdown, function()
	vim.cmd("RenderMarkdown toggle")
end, { desc = "切换 Markdown 渲染" })

-- 3. 命令 :RenderMarkdown 触发懒加载
lazy.on_cmd(
	"render-markdown",
	"RenderMarkdown",
	load_render_markdown,
	{ nargs = "*", bang = true, desc = "Markdown 渲染命令" }
)
