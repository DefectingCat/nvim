local user_command = vim.api.nvim_create_user_command

-- 定义 Difft 命令
user_command("Difft", function()
  vim.cmd("windo diffthis")
end, {
  desc = "windo Diffthis",
})

-- 定义 Diffo 命令
user_command("Diffo", function()
  vim.cmd("windo diffoff")
end, {
  desc = "windo Diffoff",
})

-- 处理格式化相关命令的辅助函数
local function toggle_formatting(disable_buffer_only, notify)
  if disable_buffer_only then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
  if notify then
    vim.notify("autoformat disabled")
  end
end

local function enable_formatting()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end

-- 定义 FormatDisable 命令
user_command("FormatDisable", function(args)
  toggle_formatting(args.bang, args.bang)
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

-- 定义 FormatEnable 命令
user_command("FormatEnable", enable_formatting, {
  desc = "Re-enable autoformat-on-save",
})

-- 定义 FormatToggle 命令
user_command("FormatToggle", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  if vim.g.disable_autoformat then
    vim.notify("autoformat disabled")
  else
    vim.notify("autoformat enabled")
  end
end, {
  desc = "Toggle autoformat-on-save",
})

-- mason install command
-- create install all command
-- 优化点：将需要安装的工具列表按照语言或类型分组，提高可读性
local ensure_installed = {
  -- LSP servers
  lsp_servers = {
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
  },
  -- Formatters
  formatters = {
    "prettierd", -- prettier formatter
    "stylua", -- lua formatter
    "isort", -- python formatter
    -- "black", -- python formatter
    -- "shfmt",
    "goimports",
    "gofumpt",
    "golines",
    "clang-format",
    "taplo", -- toml
  },
  -- Linters
  linters = {
    "pylint",
  },
  -- Tools
  tools = {
    "gomodifytags",
    "impl", -- go
    "delve", -- golang debug adapter
  },
}

-- 扁平化 ensure_installed 列表
local flattened_ensure_installed = {}
for _, group in pairs(ensure_installed) do
  for _, tool in ipairs(group) do
    table.insert(flattened_ensure_installed, tool)
  end
end

-- Create user command to synchronously install all Mason tools in `opts.ensure_installed`.
vim.api.nvim_create_user_command("MasonInstallAll", function()
  -- 使用 pcall 引入 mason-registry
  local success, registry = pcall(require, "mason-registry")
  if not success then
    vim.notify("Failed to load mason-registry: " .. registry, vim.log.levels.ERROR)
    return
  end

  for _, tool in ipairs(flattened_ensure_installed) do
    local pkg = registry.get_package(tool)
    if not pkg:is_installed() then
      vim.cmd("MasonInstall " .. tool)
    else
      vim.notify(tool .. " is already installed", vim.log.levels.INFO)
    end
  end
end, {})
