-- =============================================================================
-- mini.files 文件浏览器配置 (lua/plugins/files.lua)
-- =============================================================================
-- 提供悬浮文件浏览器，支持目录导航和文件操作。
-- 所有 mini.files 相关的配置和键位集中在此文件。
-- =============================================================================

local lazy = require("lazy")

-- 复制光标下条目的路径到默认寄存器。
-- kind = "absolute" 复制绝对路径，"relative" 复制相对 cwd 的路径。
local function yank_entry_path(kind)
	local entry = require("mini.files").get_fs_entry()
	if entry == nil or entry.path == nil then
		vim.notify("光标不在有效条目上", vim.log.levels.WARN)
		return
	end
	local path = kind == "relative" and vim.fn.fnamemodify(entry.path, ":.") or entry.path
	-- 统一复制到系统剪贴板（+ 寄存器），与 keymaps.lua 的 <leader>yp/yP 行为一致
	vim.fn.setreg("+", path)
	-- 复用内置 yank 高亮（vim.hl 是 0.11+ 新 API，vim.highlight 为已弃用别名）
	vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	vim.notify("已复制: " .. path)
end

-- 回车智能进入：光标在目录上则展开，在文件上则打开并关闭文件浏览器
local function go_in_smart()
	local MiniFiles = require("mini.files")
	local entry = MiniFiles.get_fs_entry()
	-- fs_type 为 "directory" 时展开目录，其余（"file"）打开文件后关闭浏览器
	if entry and entry.fs_type ~= "directory" then
		MiniFiles.go_in()
		MiniFiles.close()
	else
		MiniFiles.go_in()
	end
end

-- 仅对纯创建批次自动确认；删除、移动、复制和重命名继续提示。
local function is_create_only_confirmation(message)
	local has_action = false
	for line in message:gmatch("[^\n]+") do
		local action = line:match("^  (%u+)%s+│%s")
		if action ~= nil then
			has_action = true
			if action ~= "CREATE" then
				return false
			end
		end
	end
	return has_action
end

-- mini.files 没有免确认参数；仅对创建操作临时自动确认。
local function synchronize_with_safe_create()
	local MiniFiles = require("mini.files")
	local confirm = vim.fn.confirm

	vim.fn.confirm = function(message, ...)
		vim.fn.confirm = confirm
		if type(message) == "string" and is_create_only_confirmation(message) then
			return 1
		end
		return confirm(message, ...)
	end

	local ok, result = xpcall(function()
		return MiniFiles.synchronize()
	end, debug.traceback)

	vim.fn.confirm = confirm
	if not ok then
		error(result)
	end
	return result
end

-- mini.files setup 配置
local function setup_mini_files()
	require("mini.files").setup({
		mappings = {
			go_in = "<CR>", -- 回车进入目录或打开文件
			go_in_plus = "L", -- L 进入并同步光标
			go_out = "_", -- _ 返回上级目录
			go_out_plus = "H", -- H 返回上级并同步光标
		},
	})

	-- 在 explorer buffer 中绑定 buffer-local 键位
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniFilesBufferCreate",
		callback = function(args)
			local buf_id = args.data.buf_id
			local opts = function(desc)
				return { buffer = buf_id, desc = desc }
			end
			-- 回车打开文件后自动关闭文件浏览器；目录则正常展开
			vim.keymap.set("n", "<CR>", go_in_smart, opts("打开文件并关闭浏览器"))
			vim.keymap.set("n", "<leader>yp", function()
				yank_entry_path("relative")
			end, opts("复制相对路径"))
			vim.keymap.set("n", "<leader>yP", function()
				yank_entry_path("absolute")
			end, opts("复制绝对路径"))
			vim.keymap.set("n", "<C-s>", synchronize_with_safe_create, opts("同步（创建免确认）"))
		end,
	})
end

-- 公共函数：在 starter buffer 中打开文件浏览器
local function open_files_in_starter(cwd)
	require("lazy").load("files", setup_mini_files)
	local MiniFiles = require("mini.files")
	MiniFiles.open(cwd)
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
			open_files_in_starter(vim.fn.getcwd())
		end, { buffer = args.buf, desc = "打开文件浏览器（工作目录）" })

		vim.keymap.set("n", "_", function()
			local git_root = vim.fs.root(0, ".git")
			open_files_in_starter(git_root or vim.fn.getcwd())
		end, { buffer = args.buf, desc = "打开文件浏览器（项目根目录）" })
	end,
})
