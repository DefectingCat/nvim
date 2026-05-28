local lazy = require("lazy")

-- conform.nvim - BufWritePre 懒加载
local function setup_conform()
	local function biome_or_prettier()
		if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
			return { "biome-check", "biome", stop_after_first = true }
		end
		return { "prettier" }
	end

	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "gofumpt", "goimports" },
			javascript = biome_or_prettier,
			typescript = biome_or_prettier,
			javascriptreact = biome_or_prettier,
			typescriptreact = biome_or_prettier,
			json = biome_or_prettier,
			css = { "prettier" },
			html = { "prettier" },
			markdown = { "prettier" },
			toml = { "taplo" },
		},
		format_on_save = function(bufnr)
			if vim.b[bufnr].autoformat == false or vim.g.autoformat == false then
				return nil
			end
			return { timeout_ms = 500, lsp_fallback = true }
		end,
	})
end

lazy.on_event("conform", "BufWritePre", "*", function()
	setup_conform()
	-- conform 的 setup 注册了 BufWritePre，但新 autocmd 不会在同一次事件中触发
	-- 所以这里手动调用 format 补偿第一次保存
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr].autoformat ~= false and vim.g.autoformat ~= false then
		require("conform").format({ bufnr = bufnr, timeout_ms = 500, lsp_fallback = true })
	end
end)

-- mason + LSP 配置延迟到 VimEnter，避免启动时加载
lazy.on_event("lsp", "VimEnter", "*", function()
	require("mason").setup()

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

	vim.lsp.config("*", { capabilities = capabilities })

	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
			},
		},
	})

	vim.lsp.enable({
		"html",
		"cssls",
		"gopls",
		"vtsls",
		"rust_analyzer",
		"lua_ls",
		"taplo",
		"svelte",
		"dartls",
		"kotlin_lsp",
	})
end)

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<leader>fm", function()
	lazy.load("conform", setup_conform)
	require("conform").format({ lsp_fallback = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "df", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

local diagnostic_goto = function(next, severity)
	return function()
		vim.diagnostic.jump({
			count = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float = true,
		})
	end
end

vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

vim.diagnostic.config({ virtual_text = true })
