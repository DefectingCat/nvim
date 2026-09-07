-- =============================================================================
-- Treesitter 配置 (lua/plugins/treesitter.lua)
-- =============================================================================
-- 本模块配置 Treesitter parser 管理和按 buffer 启用的语法高亮。
--
-- 加载方式：
--   由 pack.lua 在注册插件后立即加载，确保首次 FileType 前查询文件可用。
--
-- 设计要点：
--   1. 启动 100ms 后只检查 parser 文件，仅将缺失项交给安装器
--   2. 高亮按 buffer 动态附加（FileType autocmd），仅在 parser 可用时启用
--   3. 仅在 nvim-treesitter 更新后异步更新已安装的 parser 和查询
-- =============================================================================

local M = {}

-- ---------------------------------------------------------------------------
-- 预安装的 parser 列表
-- ---------------------------------------------------------------------------
-- 这些 parser 会在首次启动后延迟安装。
-- 如果某个 parser 未在此列表中，打开对应文件类型时仍可通过 nvim-treesitter
-- 的 :TSInstall 手动安装。
local ensure_installed = {
	-- Web 前端
	"javascript",
	"typescript",
	"tsx", -- TypeScript JSX
	"jsdoc", -- JSDoc 注释
	"json",
	"html",
	"css",
	"yaml",
	"kotlin",
	-- 后端
	"rust",
	"toml",
	"go",
	"gomod", -- Go Modules
	"gosum", -- Go Sum
	"gowork", -- Go Workspaces
	-- 基础设施与文档
	"dockerfile",
	"make",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"markdown",
	"markdown_inline",
}

-- ---------------------------------------------------------------------------
-- 模块初始化
-- ---------------------------------------------------------------------------
M.setup = function()
	-- 加载 nvim-treesitter（通过 packadd 激活 opt 插件）
	vim.cmd.packadd("nvim-treesitter")
	local treesitter = require("nvim-treesitter")
	local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

	-- 上游 update() 会重新加载 parser 清单，无需手动清除模块缓存。
	vim.api.nvim_create_autocmd("PackChanged", {
		group = group,
		callback = function(args)
			if args.data.spec.name == "nvim-treesitter" and args.data.kind == "update" then
				vim.schedule(function()
					treesitter.update()
				end)
			end
		end,
	})

	local function start(buf)
		if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
			return
		end

		local ft = vim.bo[buf].filetype
		local lang = vim.treesitter.language.get_lang(ft)
		if not lang or not pcall(vim.treesitter.language.add, lang) then
			return
		end

		pcall(vim.treesitter.start, buf, lang)
	end

	-- 先用 runtimepath 做一次轻量检查；全部已安装时不创建安装任务，
	-- 避免每次启动都让 nvim-treesitter 重扫完整 parser 清单。
	vim.defer_fn(function()
		local missing = vim.tbl_filter(function(lang)
			return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0
		end, ensure_installed)
		if #missing > 0 then
			treesitter.install(missing)
		end
	end, 100)

	-- 按文件类型动态启用 treesitter 高亮。
	-- 当文件的 filetype 被设置时（BufRead、:setfiletype 等），
	-- 尝试查找并加载对应的 parser，成功后启用高亮。
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "*", -- 匹配所有文件类型
		callback = function(args)
			start(args.buf)
		end,
	})

	-- 手动重新执行 setup 时，为已加载的 buffer 补上高亮。
	vim.schedule(function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			start(buf)
		end
	end)
end

return M
