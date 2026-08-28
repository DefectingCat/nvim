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
-- 4. 首次使用折叠时启用 Treesitter foldexpr
-- ---------------------------------------------------------------------------
-- foldexpr 会在首屏计算所有折叠；等用户实际按下 z 再启用，避免无折叠操作时的开销。
-- 使用命名 namespace，重新加载配置时替换旧监听器，不会重复注册。
local fold_ns = vim.api.nvim_create_namespace("UserTreesitterFoldOnDemand")
local treesitter_foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.on_key(function(_, typed)
	if typed ~= "z" then
		return
	end

	local mode = vim.api.nvim_get_mode().mode
	if mode ~= "n" and mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return
	end

	-- 保留特殊 buffer 和自定义折叠；允许 Neovim 的 Lua ftplugin 预设同一个 foldexpr。
	local foldexpr = vim.wo.foldexpr
	if
		vim.bo.buftype ~= ""
		or vim.wo.foldmethod ~= "manual"
		or (foldexpr ~= "0" and foldexpr ~= treesitter_foldexpr)
	then
		return
	end

	vim.wo.foldexpr = treesitter_foldexpr
	vim.wo.foldmethod = "expr"
end, fold_ns)
