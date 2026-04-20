-- Treesitter user commands
local parsers = {
  "lua",
  "vim",
  "vimdoc",
  -- Web
  "javascript",
  "typescript",
  "tsx",
  "jsdoc",
  "json",
  "jsonc",
  "html",
  "css",
  "yaml",
  -- Backend
  "c",
  "rust",
  "toml",
  "go",
  "gomod",
  "gosum",
  "gowork",
  -- Infra
  "dockerfile",
  "make",
}

vim.api.nvim_create_user_command("TSInstallAll", function()
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  vim.cmd("TSInstall " .. table.concat(parsers, " "))
end, { desc = "Install listed Treesitter parsers" })

vim.api.nvim_create_user_command("TSUpdateAll", function()
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  vim.cmd("TSUpdate " .. table.concat(parsers, " "))
end, { desc = "Update listed Treesitter parsers" })

-- Mason user command
local mason_packages = {
  -- LSP
  "lua-language-server",
  "gopls",
  "vtsls",
  "css-lsp",
  "yaml-language-server",
  "html-lsp",
  -- Linter
  "golangci-lint",
  "biome",
  -- Formatter
  "stylua",
  "prettier",
  "gofumpt",
  "goimports",
}

vim.api.nvim_create_user_command("MasonInstallAll", function()
  require("lazy").load({ plugins = { "mason.nvim" } })
  local registry = require("mason-registry")
  local to_install = {}
  local to_update = {}

  for _, name in ipairs(mason_packages) do
    local pkg = registry.get_package(name)
    if pkg:is_installed() then
      local installed = pkg:get_installed_version()
      local latest = pkg:get_latest_version()
      if installed ~= latest then
        to_update[#to_update + 1] = name
      end
    else
      to_install[#to_install + 1] = name
    end
  end

  if #to_install > 0 then
    vim.cmd("MasonInstall " .. table.concat(to_install, " "))
  end

  if #to_update > 0 then
    vim.cmd("MasonInstall " .. table.concat(to_update, " "))
  end

  if #to_install == 0 and #to_update == 0 then
    vim.notify("All packages are up-to-date", vim.log.levels.INFO)
  end
end, { desc = "Install/Update Mason packages (skip installed)" })