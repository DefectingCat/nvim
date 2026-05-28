-- =============================================================================
-- 键位映射配置 (lua/keymaps.lua)
-- =============================================================================
-- Leader 键设置为 Space，所有以 <leader> 开头的映射均使用空格触发。
--
-- 映射模式说明：
--   n - normal 模式（默认）
--   v - visual / select 模式
--   i - insert 模式
--   t - terminal 模式
--   x - visual 模式（不含 select）
--
-- 按键分组：
--   <leader> f*  → 查找/文件相关（由 pick.lua 补充）
--   <leader> g*  → Git 相关（由 git.lua 补充）
--   <leader> b*  → Buffer 管理
--   <leader> y*  → 复制/粘贴
--   <leader> t*  → Terminal/Tab
--   <C-*>        → 窗口导航与保存
-- =============================================================================

-- 设置 Leader 键为空格。必须在任何 <leader> 映射之前设置。
vim.g.mapleader = " "

-- 本地别名，简化映射代码
local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- 基础编辑映射
-- ---------------------------------------------------------------------------

-- 按 Esc 清除搜索高亮（/ ? 搜索后的匹配高亮）
-- silent = true 避免在命令行显示 :nohl 的反馈
map("n", "<Esc>", ":nohl<CR>", { desc = "清除搜索高亮", silent = true })

-- Visual 模式下缩进后保持选区，便于连续多次缩进
map("v", "<", "<gv", { desc = "减少缩进并保持选区" })
map("v", ">", ">gv", { desc = "增加缩进并保持选区" })

-- J（合并行）时不移动光标。
-- 原理：mz 设置标记 z，J 合并行，`z 跳回标记位置。
map("n", "J", "mzJ`z", { desc = "合并行且不移动光标" })

-- ---------------------------------------------------------------------------
-- 搜索与替换
-- ---------------------------------------------------------------------------

-- 快速替换当前光标下的单词（全局替换）。
-- <C-r><C-w> 在命令行插入光标下的单词。
-- 映射展开后形如 :%s/oldword/oldword/gI，光标停在末尾，可修改替换内容。
map(
	"n",
	"<leader>ss",
	[[:%s/<<C-r><C-w>>/<<C-r><C-w>>/gI<Left><Left><Left>]],
	{ desc = "全局替换光标下的单词" }
)

-- Visual 模式下在选区范围内搜索替换
-- \%V 是 Vim 正则中的可视区域限定符，确保替换只在选区内生效
map("v", "<leader>ss", ":s/\\%V", { desc = "在可视选区内搜索替换" })

-- ---------------------------------------------------------------------------
-- 行尾操作符重映射
-- ---------------------------------------------------------------------------
-- 将 $ 映射为 g_（行尾最后一个非空白字符），
-- 这比 $（真正的行尾，通常包含尾随空格）更符合直觉。
map("n", "$", "g_")
map("v", "$", "g_")

-- 再次映射缩进保持选区（与上方重复，确保可靠性）
map("v", ">", ">gv")
map("v", "<", "<gv")

-- ---------------------------------------------------------------------------
-- 内置撤销树 (Undotree)
-- ---------------------------------------------------------------------------
-- Neovim 0.12+ 内置了 undotree 插件（nvim.undotree）。
-- 这里通过 packadd 按需加载并打开。
vim.keymap.set("n", "<leader>u", function()
	vim.cmd.packadd("nvim.undotree")
	require("undotree").open()
end, { desc = "打开内置撤销树" })

-- ---------------------------------------------------------------------------
-- 文件操作
-- ---------------------------------------------------------------------------

-- <C-s> 保存当前文件（normal 模式）
map("n", "<C-s>", "<cmd>w<CR>", { desc = "保存文件" })

-- <C-c> 复制整行内容到系统剪贴板
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "复制整个文件内容" })

-- ---------------------------------------------------------------------------
-- Terminal 模式
-- ---------------------------------------------------------------------------

-- Terminal 模式下按 <C-x> 返回 Normal 模式
-- <c-><c-n> 是 Vim 内置的终端转义序列
map("t", "<C-x>", "<c-\\><c-n>", { desc = "从终端模式返回普通模式" })

-- 打开新的终端窗口
map("n", "<leader>tt", ":term<CR>", { desc = "打开新终端" })

-- ---------------------------------------------------------------------------
-- 窗口导航
-- ---------------------------------------------------------------------------
-- 使用 <C-h/j/k/l> 在窗口间快速跳转，替代 <C-w> h/j/k/l 的繁琐操作。
map("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })

-- ---------------------------------------------------------------------------
-- Tab 管理
-- ---------------------------------------------------------------------------
map("n", "<leader>tc", ":tabclose<CR>", { desc = "关闭当前标签页" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "新建标签页" })
map("n", "<leader>]", ":tabnext<CR>", { desc = "下一个标签页" })
map("n", "<leader>[", ":tabprevious<CR>", { desc = "上一个标签页" })

-- ---------------------------------------------------------------------------
-- 复制文件路径
-- ---------------------------------------------------------------------------
-- 复制当前文件的相对路径到系统剪贴板
map("n", "<leader>yp", function()
	local path = vim.fn.expand("%")
	vim.fn.setreg("+", path)
	vim.notify("已复制相对路径: " .. path, vim.log.levels.INFO)
end, { desc = "复制相对文件路径" })

-- 复制当前文件的绝对路径到系统剪贴板
map("n", "<leader>yP", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("已复制绝对路径: " .. path, vim.log.levels.INFO)
end, { desc = "复制绝对文件路径" })

-- ---------------------------------------------------------------------------
-- Buffer 管理
-- ---------------------------------------------------------------------------
-- 关闭当前 Buffer，有未保存更改时提示确认。
-- 使用 vim.ui.select 提供交互式选择对话框。
map("n", "<leader>x", function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].modified then
		vim.ui.select({ "是", "否" }, {
			prompt = "Buffer 有未保存的更改，不保存就关闭吗？",
			format_item = function(item)
				return item
			end,
		}, function(choice)
			if choice == "是" then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end)
	else
		vim.cmd.bdelete()
	end
end, { desc = "关闭当前 Buffer" })

-- 新建空 Buffer
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "新建 Buffer" })

-- 关闭除当前 Buffer 外的所有 Buffer。
-- 跳过指定文件类型的 Buffer（如文件管理器），避免误关闭侧边栏。
map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	local skipped_ft = { "NvimTree", "oil", "aerial" } -- 跳过的文件类型列表
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			local ft = vim.bo[buf].filetype
			if not vim.tbl_contains(skipped_ft, ft) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end
end, { desc = "关闭其他 Buffer" })
