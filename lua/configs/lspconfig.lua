require("nvchad.configs.lspconfig").defaults()

local servers =
  { "html", "cssls", "gopls", "vtsls", "rust_analyzer", "lua_ls", "taplo", "svelte", "dartls", "kotlin_lsp" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
