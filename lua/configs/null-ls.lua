local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")

-- auto format mark
vim.g.auto_format = true

local formatting = null_ls.builtins.formatting   -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters
local code_actions = null_ls.builtins.code_actions

local eslint_condition = function(utils)
  return utils.root_has_file({
    ".eslintcache",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
  })
end

local opts = {
  sources = {
    -- Golang
    formatting.gofmt,
    formatting.goimports_reviser,
    formatting.golines,
    -- JavaScript
    formatting.prettierd.with({
      prefer_local = "node_modules/.bin",
      extra_filetypes = { "toml" },
    }),
    -- Lua
    formatting.stylua,
    -- Bash
    formatting.shfmt,
    -- sql
    diagnostics.sqlfluff.with({
      extra_args = { "--dialect", "postgres" }, -- change to your dialect
    }),
    formatting.sqlfluff.with({
      extra_args = { "--dialect", "postgres" }, -- change to your dialect
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          if vim.bo.filetype == "vue" then
            return
          end
          if vim.g.auto_format == false then
            return
          end
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
      --[[ if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            if vim.g.auto_format == false then
              return
            end
            vim.lsp.buf.format({ async = true, bufnr = bufnr })
          end,
        })
      elseif client.server_capabilities.documentRangeFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            if vim.g.auto_format == false then
              return
            end
            vim.lsp.formatexpr()
          end,
        })
      end ]]
    end
  end,
}

return opts
