-- =============================================================================
-- LSP、格式化与诊断配置 (lua/lsp.lua)
-- =============================================================================
-- 本文件配置 Neovim 的 LSP 客户端、代码格式化（conform.nvim）和诊断导航。
--
-- 加载方式：
--   由 pack.lua 通过 lazy.on_event("lsp", "VimEnter", "*", ...) 延迟加载，
--   在 VimEnter 事件触发后初始化，避免阻塞 startup。
--
-- 依赖加载顺序：
--   1. conform.nvim（BufWritePre 时按需 packadd 加载）
--   2. nvim-lspconfig（直接 packadd）
--   3. mason.nvim（直接 setup）
-- =============================================================================
local lazy = require("lazy")

-- ---------------------------------------------------------------------------
-- conform.nvim — 代码格式化（BufWritePre 懒加载）
-- ---------------------------------------------------------------------------
-- conform.nvim 是一个轻量级格式化器包装器，支持保存时自动格式化。
-- 由于格式化器通常不是立即需要的，通过 lazy.on_event 在 BufWritePre 时
-- 才进行 packadd 和 setup。
local function setup_conform()
	-- 通过 packadd 加载 conform.nvim（因为 vim.pack.add 时设置了 load = false）
	vim.cmd.packadd("conform.nvim")

	-- 动态判断使用 Biome 还是 Prettier。
	-- 从当前文件向上搜索 biome.json / biome.jsonc，如果找到则使用 Biome，
	-- 否则回退到 Prettier。stop 参数限制搜索到用户主目录，避免向上搜索到根目录。
	local function biome_or_prettier()
		if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
			return { "biome-check", "biome", stop_after_first = true }
		end
		return { "prettier" }
	end

	require("conform").setup({
		-- 按文件类型配置格式化器
		formatters_by_ft = {
			lua = { "stylua" }, -- Lua 格式化
			go = { "gofumpt", "goimports" }, -- Go：先 gofumpt 格式化，再 goimports 整理导入
			javascript = biome_or_prettier, -- JS：Biome 或 Prettier
			typescript = biome_or_prettier, -- TS：Biome 或 Prettier
			javascriptreact = biome_or_prettier, -- JSX：Biome 或 Prettier
			typescriptreact = biome_or_prettier, -- TSX：Biome 或 Prettier
			json = biome_or_prettier, -- JSON：Biome 或 Prettier
			css = { "prettier" }, -- CSS：Prettier
			html = { "prettier" }, -- HTML：Prettier
			markdown = { "prettier" }, -- Markdown：Prettier
			toml = { "taplo" }, -- TOML：taplo
		},

		-- 保存时自动格式化回调
		-- 可通过 vim.b[bufnr].autoformat = false 关闭当前 buffer 的自动格式化
		-- 或通过 vim.g.autoformat = false 全局关闭
		format_on_save = function(bufnr)
			if vim.b[bufnr].autoformat == false or vim.g.autoformat == false then
				return nil -- 返回 nil 表示不格式化
			end
			return { timeout_ms = 500, lsp_fallback = true }
		end,
	})
end

-- BufWritePre 时触发 conform 加载。
-- 注意：conform 的 setup 内部会注册自己的 BufWritePre autocmd，
-- 但新创建的 autocmd 不会在同一次事件中触发。
-- 因此这里手动调用 format 补偿第一次保存（确保首次保存也能格式化）。
lazy.on_event("conform", "BufWritePre", "*", function()
	setup_conform()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr].autoformat ~= false and vim.g.autoformat ~= false then
		require("conform").format({ bufnr = bufnr, timeout_ms = 500, lsp_fallback = true })
	end
end)

-- ---------------------------------------------------------------------------
-- Mason + LSP 配置
-- ---------------------------------------------------------------------------
-- Mason 是 LSP 服务器、DAP 适配器和格式化工具的安装管理器。
-- nvim-lspconfig 提供常见 LSP 服务器的预设配置。
vim.cmd.packadd("nvim-lspconfig")
lazy.track("lspconfig")

require("mason").setup()
lazy.track("mason")

-- 构建 LSP 客户端 capabilities（能力声明），告知服务器客户端支持的功能。
-- 先获取 Neovim 默认 capabilities，再与 mini.completion 的 LSP 补全能力合并。
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

-- 为所有 LSP 服务器设置默认 capabilities
vim.lsp.config("*", { capabilities = capabilities })

-- Lua 语言服务器特殊配置：将 "vim" 声明为全局变量，避免 "Undefined global" 诊断
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

-- ---------------------------------------------------------------------------
-- 已安装的 Mason 工具清单（通过 :Mason 查看）
-- ---------------------------------------------------------------------------
-- 以下是通过 Mason 安装的 LSP 服务器和工具：
--   ◍ biome              - JS/TS/JSON 格式化和 lint
--   ◍ css-lsp            - CSS 语言服务器
--   ◍ gofumpt            - Go 格式化（stricter than gofmt）
--   ◍ goimports          - Go 导入整理
--   ◍ golangci-lint      - Go linter
--   ◍ gopls              - Go 语言服务器
--   ◍ html-lsp           - HTML 语言服务器
--   ◍ kotlin-lsp         - Kotlin 语言服务器
--   ◍ lua-language-server- Lua 语言服务器
--   ◍ prettier           - 通用代码格式化器
--   ◍ rust-analyzer      - Rust 语言服务器
--   ◍ stylua             - Lua 格式化器
--   ◍ svelte-language-server - Svelte 语言服务器
--   ◍ taplo              - TOML 工具
--   ◍ vtsls              - TypeScript 语言服务器（VS Code 的 TS 服务端移植）

-- 启用指定的 LSP 服务器
vim.lsp.enable({
	"html", -- HTML 语言支持
	"cssls", -- CSS/SCSS/Less 语言支持
	"gopls", -- Go 语言支持
	"vtsls", -- TypeScript/JavaScript 支持（推荐替代 tsserver）
	"rust_analyzer", -- Rust 语言支持
	"lua_ls", -- Lua 语言支持
	"taplo", -- TOML 支持
	"svelte", -- Svelte 框架支持
	"dartls", -- Dart/Flutter 支持
	"kotlin_lsp", -- Kotlin 支持
})

-- ---------------------------------------------------------------------------
-- LSP 键位映射
-- ---------------------------------------------------------------------------
-- 使用函数包装器包裹 LSP 调用，延迟加载 vim.lsp / vim.diagnostic 模块，
-- 避免在启动时预加载这些重型模块。

-- gd - Go to Definition：跳转到定义位置
vim.keymap.set("n", "gd", function()
	vim.lsp.buf.definition()
end, { desc = "跳转到定义" })

-- gh - Hover：显示光标下符号的文档悬浮窗
vim.keymap.set("n", "gh", function()
	vim.lsp.buf.hover()
end, { desc = "悬停查看文档" })

-- <leader>fm - 手动格式化当前 buffer
vim.keymap.set("n", "<leader>fm", function()
	lazy.load("conform", setup_conform)
	require("conform").format({ lsp_fallback = true })
end, { desc = "格式化当前 Buffer" })

-- df - 显示当前行的诊断浮动窗口
vim.keymap.set("n", "df", function()
	vim.diagnostic.open_float()
end, { desc = "显示行诊断" })

-- <leader>ca - Code Action：显示可用的代码操作（如自动修复、重构）
vim.keymap.set("n", "<leader>ca", function()
	vim.lsp.buf.code_action()
end, { desc = "代码操作" })

-- ---------------------------------------------------------------------------
-- 诊断导航
-- ---------------------------------------------------------------------------
-- 辅助函数：创建诊断跳转的闭包。
-- 参数：
--   next     - true 表示向后跳，false 表示向前跳
--   severity - 可选的严重性过滤（"ERROR", "WARN", "INFO", "HINT"）
--
-- vim.v.count1 是计数前缀的默认值（无数字时为 1），
-- 支持 3]d 跳转到第 3 个诊断。
local diagnostic_goto = function(next, severity)
	return function()
		vim.diagnostic.jump({
			count = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float = true, -- 跳转时显示诊断浮动窗口
		})
	end
end

-- ]d / [d - 下一个 / 上一个诊断（所有级别）
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "下一个诊断" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "上一个诊断" })

-- ]e / [e - 下一个 / 上一个错误
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "下一个错误" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "上一个错误" })

-- ]w / [w - 下一个 / 上一个警告
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "下一个警告" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "上一个警告" })

-- ---------------------------------------------------------------------------
-- 诊断显示配置
-- ---------------------------------------------------------------------------
-- 在代码行右侧显示诊断文本（virtual text）。
vim.diagnostic.config({ virtual_text = true })
