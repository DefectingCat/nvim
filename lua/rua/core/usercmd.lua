local user_command = vim.api.nvim_create_user_command

user_command("Difft", function()
  vim.cmd("windo diffthis")
end, {
  desc = "windo Diffthis",
})
user_command("Diffo", function()
  vim.cmd("windo diffoff")
end, {
  desc = "windo Diffoff",
})

-- Toggle conform format on save
user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
user_command("FormatToggle", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  if vim.g.disable_autoformat then
    vim.notify("autoformat disabled")
  else
    vim.notify("autoformat enabled")
  end
end, {
  desc = "Re-enable autoformat-on-save",
})

-- mason install command
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
user_command("MasonInstallAll", function()
  for _, tool in ipairs(ensure_installed) do
    vim.cmd("MasonInstall " .. tool)
  end
end, {})
