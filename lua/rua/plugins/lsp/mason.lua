return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  event = "VeryLazy",
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

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

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "gopls",
        "lua_ls",
        "rust_analyzer",
        "html",
        "volar",
        "vtsls",
        "tailwindcss",
        "eslint-lsp",
        "cssls",
        "cssmodules_ls",
        "jsonls",
        "yamlls",
        "docker_compose_language_service",
        "dockerls",
        "bashls",
        "clangd",
        "lemminx",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua",   -- lua formatter
        "isort",    -- python formatter
        "black",    -- python formatter
        "pylint",
        "stylua",
        "shfmt",
        "goimports",
        "goimports-reviser",
        "golines",
        "clang-format",
        "taplo",
      },
    })
  end,
}
