-- =============================================================================
-- mini.files 文件浏览器配置 (lua/plugins/files.lua)
-- =============================================================================
-- 提供悬浮文件浏览器，支持目录导航和文件操作。
-- 所有 mini.files 相关的配置和键位集中在此文件。
-- =============================================================================

local lazy = require("lazy")

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
