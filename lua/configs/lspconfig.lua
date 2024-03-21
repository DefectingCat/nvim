local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
--[[ local lspconfig_configs = require("lspconfig.configs") ]]
local util = require("lspconfig/util")

local function organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
	}
	vim.lsp.buf.execute_command(params)
end

--[[ local tspath = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/typescript/lib/" ]]
local mason_registry = require("mason-registry")
local has_volar, volar = pcall(mason_registry.get_package, "vue-language-server")

local vue_ts_plugin_path
if has_volar then
	vue_ts_plugin_path = volar:get_install_path()
		.. "/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin"
end
-- after volar 2.0.7
-- npm i -g @vue/typescript-plugin
-- local vue_ts_plugin_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/typescript-plugin'

require("mason-lspconfig").setup_handlers({
	function(server)
		local server_config = {
			on_attach = on_attach,
			capabilities = capabilities,
		}
		if server == "rust_analyzer" then
			return nil
		end
		lspconfig[server].setup(server_config)
	end,
})

lspconfig.volar.setup({
	filetypes = { "vue" },
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_ts_plugin_path,
				languages = { "vue" },
			},
		},
		preferences = {
			disableSuggestions = true,
		},
	},
	commands = {
		OrganizeImports = {
			organize_imports,
			description = "Organize Imports",
		},
	},
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
