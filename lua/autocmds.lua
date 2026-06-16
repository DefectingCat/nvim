-- =============================================================================
-- 自动命令配置 (lua/autocmds.lua)
-- =============================================================================
-- 自动命令（autocmd）是事件驱动的回调机制，
-- 在特定编辑器事件（如打开文件、切换 buffer、进入插入模式等）发生时自动执行。
--
-- 所有 autocmd 归属于 "UserAutocmds" 组，
-- 使用 { clear = true } 确保每次重载配置时先清除旧的 autocmd，
-- 避免重复注册导致命令被多次触发。
-- =============================================================================

-- 创建用户 autocmd 组，clear = true 表示创建前清空组内所有现有命令
local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- ---------------------------------------------------------------------------
-- 1. Yank 高亮
-- ---------------------------------------------------------------------------
-- 复制文本时短暂高亮被复制的区域，提供视觉反馈。
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "复制文本时高亮被复制的区域",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ---------------------------------------------------------------------------
-- 2. 恢复上次编辑位置
-- ---------------------------------------------------------------------------
-- 打开文件后，将光标恢复到上次关闭时的位置。
-- 原理：Vim 在关闭文件时会保存光标位置到 `"` 标记（双引号标记），
--       下次打开时可通过此标记恢复。
--
-- 跳过的情况：
--   - commit / gitcommit：Git 提交消息文件，总是从头开始编辑
--   - xxd：十六进制编辑模式
--   - gitrebase：Git rebase 交互式编辑
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	callback = function()
		-- 获取 `"` 标记的位置（行, 列）
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local row = mark[1] -- 行号（1-based）
		local ft = vim.bo.filetype

		-- 仅当标记有效（行号 > 1 且在文件范围内）时恢复光标
		if row > 1 and row <= vim.fn.line("$") then
			-- 排除特定文件类型
			if ft ~= "commit" and ft ~= "gitcommit" and not ft:match("xxd") and not ft:match("gitrebase") then
				vim.api.nvim_win_set_cursor(0, mark)
			end
		end
	end,
})

-- ---------------------------------------------------------------------------
-- 3. 注释延续行为
-- ---------------------------------------------------------------------------
-- 控制按回车或 o/O 时是否自动延续注释符号（如 //、#、--）。
--
-- formatoptions 说明：
--   o  - 使用 o/O 换行时延续注释（被移除，避免在 normal 模式下意外延续）
--   r  - 按回车时延续注释（保留，insert 模式下回车延续注释符）
--
-- 注意：此设置对自动格式化（conform.nvim）的行为也有影响。
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function()
		-- 移除 'o'：按 o/O 时不自动插入注释符号
		vim.opt_local.formatoptions:remove("o")
		-- 追加 'r'：按回车时自动插入注释符号
		vim.opt_local.formatoptions:append("r")
	end,
})

-- ---------------------------------------------------------------------------
-- 4. 按文件类型设置 Treesitter 折叠
-- ---------------------------------------------------------------------------
-- 使用 treesitter 的 foldexpr 进行语法感知的代码折叠。
-- 在 FileType 事件中按 buffer 设置 window-local 选项：
--   - 仅对有 treesitter parser 的文件类型启用 expr 折叠
--   - window-local（vim.wo）而非全局（vim.o），避免污染 help/man/quickfix 等窗口
--   - 每个 buffer 独立设置，分屏与新窗口正确继承
--
-- foldmethod = "expr" 表示使用表达式（foldexpr）计算折叠范围。
-- foldexpr = "v:lua.vim.treesitter.foldexpr()" 是 Neovim 0.10+ 的内置函数，
--   基于 treesitter 语法树计算折叠边界。无 parser 时返回 0（不折叠），不会报错。
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function()
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})
