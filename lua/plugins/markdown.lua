-- =============================================================================
-- Markdown 渲染预览 (lua/plugins/markdown.lua)
-- =============================================================================
-- 本模块配置 delphinus/md-render.nvim：把 Markdown 渲染成带高亮、表格、
-- callout、图片与 Mermaid 的富文本视图，渲染结果放在浮动窗口（或标签页/
-- 分屏）中，源 buffer 保持原样。
--
-- 与 render-markdown.nvim 的取舍：md-render 不修改编辑缓冲区，定位是"预览"；
-- 图片/视频/Mermaid 需要终端支持 Kitty graphics protocol（Ghostty、kitty、
-- WezTerm 可用），Neovide 等不支持的终端只渲染文字部分。
--
-- 懒加载策略：
--   1. 按键触发：<leader>tm 打开/关闭浮动预览
--   2. 命令触发：:MdRender 首次执行时加载，由 Neovim 自动重试原命令
-- =============================================================================

local lazy = require("lazy")

-- 正文宽度随编辑器变化，不再受固定列数限制。
local function resize_preview()
	local width = math.max(1, math.floor(vim.o.columns * 0.8))
	vim.g.md_render_max_width = width

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		local buf = vim.api.nvim_win_get_buf(win)
		if config.relative == "editor" and vim.b[buf].md_render then
			vim.api.nvim_win_set_config(win, {
				relative = "editor",
				row = config.row,
				width = width,
				col = math.floor((vim.o.columns - width) / 2),
			})
		end
	end

	-- 浮动预览不会自行重排；使用插件接口同步正文、图片与页脚。
	local preview = package.loaded["md-render.preview"]
	if preview then
		preview.rebuild_visible()
	end
end

resize_preview()
vim.api.nvim_create_autocmd("VimResized", {
	group = vim.api.nvim_create_augroup("UserMarkdownPreview", { clear = true }),
	desc = "随编辑器宽度调整 Markdown 预览",
	callback = resize_preview,
})

local function load_md_render()
	vim.cmd.packadd("md-render.nvim")
end

-- 1. 按键 <leader>tm 打开/关闭 Markdown 浮动预览
lazy.on_keys("md-render", "<leader>tm", "n", load_md_render, function()
	require("md-render").preview.show()
end, { desc = "切换 Markdown 渲染预览" })

-- 2. 命令首次触发时加载插件，由 Neovim 原样重试，保留修饰符和参数。
lazy.on_event("md-render", "CmdUndefined", "MdRender", load_md_render)
