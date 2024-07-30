local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

require("mason-lspconfig").setup_handlers({
	function(server)
		local server_config = {
			on_attach = on_attach,
			capabilities = capabilities,
		}
		if
				server == "rust_analyzer"
				or server == "clangd"
				or server == "tsserver"
				or server == "vtsls"
				or server == "pylsp"
				or server == "gopls"
				or server == "jsonls"
				or server == "yamlls"
		--[[ or server == "intelephense" ]]
		then
			return nil
		end
		lspconfig[server].setup(server_config)
	end,
})

local rust_config = require("configs.rust_config")
lspconfig["rust_analyzer"].setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = rust_config,
})

local vtsls_config = require("configs.vtsls")
lspconfig.vtsls.setup(vtsls_config)

lspconfig.clangd.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

lspconfig.pylsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "python" },
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { "W391" },
					maxLineLength = 100,
				},
			},
		},
	},
})

lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "gopls" },
	cmd_env = {
		GOFLAGS = "-tags=test,e2e_test,integration_test,acceptance_test",
	},
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})

lspconfig.jsonls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

lspconfig.yamlls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require("schemastore").yaml.schemas(),
		},
	},
})
