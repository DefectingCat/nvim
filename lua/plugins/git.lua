-- =============================================================================
-- Git 工具封装 (lua/plugins/git.lua)
-- =============================================================================
-- 本模块提供基于 mini.diff 和原生 git 命令的 Git 相关功能。
--
-- 功能列表：
--   1. Hunk Preview（<leader>ghp）— 预览当前光标处 git diff hunk
--   2. Blame Line（<leader>ghb）— 查看当前行的 git blame 信息
--   3. Blame Buffer（<leader>gB）— 整文件 blame（via fugitive）
--   4. File History（<leader>gD）— 查看当前文件的 git log
--   5. Fugitive 全屏（<leader>gg）— 在新标签页打开 fugitive
--   6. Git diff 分割（<leader>gd）— 垂直分割查看 diff
--
-- 依赖：
--   - mini.diff（已在 pack.lua 中通过 BufReadPost 懒加载）
--   - vim-fugitive（本文件通过 lazy.on_keys 按键触发懒加载）
-- =============================================================================

local lazy = require("lazy")

-- ---------------------------------------------------------------------------
-- 辅助函数：获取光标所在行的 hunk
-- ---------------------------------------------------------------------------
-- 遍历当前 buffer 的所有 hunks，找到包含光标所在行的那个。
--
-- 返回值：
--   hunk      - hunk 对象 { type, buf_start, buf_count, ref_start, ref_count }
--   ref_text  - 参考文本（HEAD 版本的内容）
--   nil       - 光标不在任何 hunk 上
local function get_cursor_hunk()
	local buf = vim.api.nvim_get_current_buf()
	-- 从 mini.diff 获取当前 buffer 的 diff 数据
	local data = require("mini.diff").get_buf_data(buf)
	if not data or not data.hunks or #data.hunks == 0 then
		return nil
	end

	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

	for _, h in ipairs(data.hunks) do
		-- hunk 在 buffer 中的起始行（1-based）
		local start_line = math.max(h.buf_start, 1)
		-- hunk 在 buffer 中的结束行
		local end_line = h.buf_start + h.buf_count - 1
		-- 空删除（0 行）时特殊处理
		if h.buf_count == 0 then
			end_line = start_line
		end

		-- 检查光标是否在此 hunk 范围内
		if cursor_line >= start_line and cursor_line <= end_line then
			return h, data.ref_text
		end
	end

	return nil
end

-- ---------------------------------------------------------------------------
-- Hunk Preview — 浮动窗口预览当前 hunk
-- ---------------------------------------------------------------------------
-- 创建一个居中的浮动窗口，显示光标所在 hunk 的详细 diff 信息。
-- 支持三种 hunk 类型：
--   add    — 显示新增的行
--   delete — 显示被删除的行（从参考文本中恢复）
--   change — 并排显示修改前后的内容
local function preview_hunk()
	local hunk, ref_text = get_cursor_hunk()
	if not hunk then
		vim.notify("光标不在变更区域", vim.log.levels.WARN)
		return
	end

	local lines = {}
	table.insert(lines, "Hunk 类型: " .. hunk.type)
	table.insert(lines, string.format("Buffer 行: %d-%d", hunk.buf_start, hunk.buf_start + hunk.buf_count - 1))
	table.insert(lines, string.format("参考行: %d-%d", hunk.ref_start, hunk.ref_start + hunk.ref_count - 1))
	table.insert(lines, "---")

	local buf = vim.api.nvim_get_current_buf()
	local ref_lines = vim.split(ref_text or "", "\n")

	if hunk.type == "delete" then
		-- 删除型 hunk：显示被删除的内容（来自参考文本）
		table.insert(lines, "被删除的行（来自参考版本）:")
		for i = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
			table.insert(lines, "- " .. (ref_lines[i] or ""))
		end
	elseif hunk.type == "add" then
		-- 新增型 hunk：显示 buffer 中新增的内容
		table.insert(lines, "新增的行:")
		for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
			table.insert(lines, "+ " .. (vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] or ""))
		end
	else
		-- 修改型 hunk：显示修改前后的对比
		table.insert(lines, "修改前（参考版本）:")
		for i = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
			table.insert(lines, "- " .. (ref_lines[i] or ""))
		end
		table.insert(lines, "修改后（当前版本）:")
		for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
			table.insert(lines, "+ " .. (vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] or ""))
		end
	end

	-- 计算浮动窗口尺寸
	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(#lines + 2, vim.o.lines - 4)

	-- 创建预览 buffer
	local preview_buf = vim.api.nvim_create_buf(false, true) -- 无文件、可编辑
	vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = preview_buf })
	vim.api.nvim_set_option_value("filetype", "diff", { buf = preview_buf }) -- diff 语法高亮

	-- 打开浮动窗口
	local win = vim.api.nvim_open_win(preview_buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " Hunk Preview ",
		title_pos = "center",
	})

	-- q / Esc 关闭窗口
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = preview_buf })
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = preview_buf })
end

-- ---------------------------------------------------------------------------
-- Blame Line — 查看当前行的 Git blame 信息
-- ---------------------------------------------------------------------------
-- 执行 git blame --porcelain 获取当前行的详细提交信息，
-- 以通知消息的形式展示提交哈希、作者、时间和提交摘要。
--
-- --porcelain 格式是机器可读的 blame 输出，包含以下字段：
--   <hash> <orig-line> <final-line> [<num-lines>]
--   author <name>
--   author-mail <email>
--   author-time <timestamp>
--   author-tz <timezone>
--   summary <commit-message>
--   ...
local function blame_line()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("当前 buffer 无文件名", vim.log.levels.WARN)
		return
	end

	local line = vim.api.nvim_win_get_cursor(0)[1]
	-- -L 限制 blame 范围为单行，提升性能
	local cmd = { "git", "blame", "-L", line .. "," .. line, "--porcelain", file }
	local output = vim.fn.system(cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("git blame 执行失败", vim.log.levels.ERROR)
		return
	end

	-- 解析 --porcelain 输出
	local hash = output:match("^(%x+)%s") or "?"
	local author = output:match("author ([^\n]+)") or "?"
	local email = output:match("author%-mail ([^\n]+)") or "?"
	local time = output:match("author%-time (%d+)")
	local summary = output:match("summary ([^\n]+)") or "?"
	local time_str = time and os.date("%Y-%m-%d %H:%M", tonumber(time)) or "?"

	vim.notify(
		string.format("%s | %s %s | %s\n%s", hash:sub(1, 8), author, email, time_str, summary),
		vim.log.levels.INFO
	)
end

-- ---------------------------------------------------------------------------
-- vim-fugitive 懒加载触发器
-- ---------------------------------------------------------------------------
local function load_fugitive()
	vim.cmd.packadd("vim-fugitive")
end

-- ---------------------------------------------------------------------------
-- 键位映射
-- ---------------------------------------------------------------------------

-- <leader>ghp — 预览当前 hunk
vim.keymap.set("n", "<leader>ghp", preview_hunk, { desc = "预览 hunk" })

-- <leader>ghb — 查看当前行 blame
vim.keymap.set("n", "<leader>ghb", blame_line, { desc = "Blame 当前行" })

-- <leader>gg — 在新标签页中打开 Fugitive 全屏
lazy.on_keys("fugitive", "<leader>gg", "n", load_fugitive, function()
	vim.cmd("Git")
end, { desc = "Fugitive 全屏新标签" })

-- <leader>gd — Git diff 垂直分割
lazy.on_keys("fugitive", "<leader>gd", "n", load_fugitive, function()
	vim.cmd("Gvdiffsplit")
end, { desc = "Git diff 分割" })

-- <leader>gB — 整文件 blame（使用 fugitive 的 :Git blame）
lazy.on_keys("fugitive", "<leader>gB", "n", load_fugitive, function()
	vim.cmd("Git blame")
end, { desc = "Blame 整个文件" })

-- <leader>gD — 查看当前文件的 git 历史
lazy.on_keys("fugitive", "<leader>gD", "n", load_fugitive, function()
	vim.cmd("Git log -p -- %")
end, { desc = "查看文件 Git 历史" })
