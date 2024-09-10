local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

local M = {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      standalone = true,
      checkOnSave = {
        command = "clippy",
      },
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = {
          enable = true,
        },
      },
      files = {
        excludeDirs = {
          ".flatpak-builder",
          "_build",
          ".dart_tool",
          ".flatpak-builder",
          ".git",
          ".gitlab",
          ".gitlab-ci",
          ".gradle",
          ".idea",
          ".next",
          ".project",
          ".scannerwork",
          ".settings",
          ".venv",
          "archetype-resources",
          "bin",
          "docs",
          "hooks",
          "node_modules",
          "po",
          "screenshots",
          "target",
          "out",
          "examples/node_modules",
          "../out",
          "../node_modules",
          "../.next",
        },
      },
    },
    procMacro = {
      enable = true,
      ignored = {
        ["async-trait"] = { "async_trait" },
        ["napi-derive"] = { "napi" },
        ["async-recursion"] = { "async_recursion" },
      },
    },
  },
}

return M
