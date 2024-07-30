local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local function organize_imports()
	local params = {
		command = "typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
	}
	vim.lsp.buf.execute_command(params)
end


local mason_registry = require("mason-registry")
local has_volar, volar = pcall(mason_registry.get_package, "vue-language-server")

-- npm i -g @vue/typescript-plugin
local vue_language_server_path
if has_volar then
	vue_language_server_path = volar:get_install_path() .. "/node_modules/@vue/language-server"
end

local M = {
	filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
	settings = {
		vtsls = {
			-- autoUseWorkspaceTsdk = true,
			tsserver = {
				globalPlugins = {
					{
						name = '@vue/typescript-plugin',
						location = vue_language_server_path,
						languages = { 'vue' },
						configNamespace = "typescript",
						enableForWorkspaceTypeScriptVersions = true,
					},
				},
			},
		},
	},
	single_file_support = true,
	commands = {
		OrganizeImports = {
			organize_imports,
			description = "Organize Imports",
		},
	},
	on_attach = on_attach,
	capabilities = capabilities,
}

return M
