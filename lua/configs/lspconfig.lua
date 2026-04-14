require("nvchad.configs.lspconfig").defaults()

  -- Installed
  --     biome (keywords: json, javascript, typescript)
  --     prettierd (keywords: angular, css, flow, graphql, html, json, jsx, javascript, less, markdown, scss, typescript, vue, yaml)
  --     vtsls (keywords: javascript, typescript)
  --     gofumpt (keywords: go)
  --     gopls (keywords: go)
  --     goimports (keywords: go)
  --     stylua (keywords: lua, luau)

local servers = { "html", "cssls", "gopls", "vtsls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
