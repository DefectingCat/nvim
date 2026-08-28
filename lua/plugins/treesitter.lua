-- =============================================================================
-- Treesitter 配置 (lua/plugins/treesitter.lua)
-- =============================================================================
-- 本模块配置 Neovim 的 Treesitter 集成，提供语法树驱动的语法高亮、
-- 代码折叠和文本对象支持。
--
-- 加载方式：
--   由 pack.lua 通过 lazy.on_event("treesitter", "VimEnter", "*", ...) 延迟加载。
--
-- 设计要点：
--   1. 启动 100ms 后只检查 parser 文件，仅将缺失项交给安装器
--   2. 高亮按 buffer 动态附加（FileType autocmd），仅在 parser 可用时启用
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
		pattern = "*", -- 匹配所有文件类型
		callback = function(args)
			local buf = args.buf
			local ft = vim.bo[buf].filetype

			-- 将文件类型映射到 treesitter 语言名
			-- 例如 "javascriptreact" → "javascript"
			local lang = vim.treesitter.language.get_lang(ft)
			if not lang then
				return -- 无对应语言，跳过
			end

			-- 尝试注册语言（如果 parser 已安装）
			-- pcall 用于安全调用：parser 未安装时不会报错
			local ok_add = pcall(vim.treesitter.language.add, lang)
			if not ok_add then
				return -- parser 未安装，跳过
			end

			-- 启用 treesitter 高亮
			pcall(vim.treesitter.start, buf, lang)
		end,
	})
end

return M
