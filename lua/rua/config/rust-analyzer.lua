local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

-- vim.lsp.set_log_level("DEBUG")

capabilities.workspace = { didChangeWatchedFiles = { dynamicRegistration = false } }

local M = {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      standalone = true,
      checkOnSave = {
        command = "clippy",
      },
      rustfmt = {
        overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
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
          ".direnv",
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
        },
        watcherExclude = {
          "**/_build",
          "**/.classpath",
          "**/.dart_tool",
          "**/.factorypath",
          "**/.flatpak-builder",
          "**/.git/objects/**",
          "**/.git/subtree-cache/**",
          "**/.idea",
          "**/.project",
          "**/.scannerwork",
          "**/.settings",
          "**/.venv",
          "**/node_modules",
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
