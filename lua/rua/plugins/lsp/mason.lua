return {
  "williamboman/mason.nvim",
  -- dependencies = {
  --   "williamboman/mason-lspconfig.nvim",
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  -- },
  event = "VeryLazy",
  config = function()
    local mason = require("mason")
    -- local mason_lspconfig = require("mason-lspconfig")
    -- local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- create install all command
    local ensure_installed = {
      "gopls",
      "lua-language-server",
      "rust-analyzer",
      "html-lsp",
      "vue-language-server", -- vue
      "vtsls", -- typescript
      "tailwindcss-language-server",
      "eslint-lsp",
      "css-lsp",
      "cssmodules-language-server",
      "json-lsp",
      "yaml-language-server",
      "docker-compose-language-service",
      "dockerfile-language-server",
      "bash-language-server",
      "clangd",
      "lemminx", -- xml svg
      "deno",
      -- tools
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      "isort", -- python formatter
      -- "black", -- python formatter
      "pylint",
      "shfmt",
      "goimports",
      "gofumpt",
      "golines",
      "gomodifytags",
      "impl", -- go
      "clang-format",
      "taplo", -- toml
      "delve", -- golang debug adapter
    }
    -- Create user command to synchronously install all Mason tools in `opts.ensure_installed`.
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      for _, tool in ipairs(ensure_installed) do
        vim.cmd("MasonInstall " .. tool)
      end
    end, {})
  end,
}
