return {
  { "b0o/schemastore.nvim", lazy = true }, -- json schema store
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
      { "antosha417/nvim-lsp-file-operations", config = true, lazy = true },
      { "folke/neodev.nvim", opts = {}, lazy = true },
    },
    opts = { document_highlight = { enabled = false } },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local map = vim.keymap.set -- for conciseness

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          opts.desc = "Show LSP references"
          map("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

          opts.desc = "Go to declaration"
          map("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

          opts.desc = "Show LSP definitions"
          map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

          opts.desc = "Show LSP implementations"
          map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

          opts.desc = "Show LSP type definitions"
          map("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

          opts.desc = "See available code actions"
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

          opts.desc = "Smart rename"
          map("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

          opts.desc = "Show buffer diagnostics"
          map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

          opts.desc = "Show line diagnostics"
          map("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

          opts.desc = "Go to previous diagnostic"
          map("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

          opts.desc = "Go to next diagnostic"
          map("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

          opts.desc = "Show documentation for what is under cursor"
          opts.silent = true
          map("n", "gh", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

          opts.desc = "Restart LSP"
          map("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
        end,
      })

      local capabilities = cmp_nvim_lsp.default_capabilities()

      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      mason_lspconfig.setup_handlers({
        -- default handler for installed servers
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
        ["vtsls"] = function()
          lspconfig["vtsls"].setup(require("rua.config.vtsls"))
          map("n", "<leader>co", "<cmd> OrganizeImports <CR>", { desc = "Organize imports" })
        end,
        ["lua_ls"] = function()
          lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          })
        end,
      })
    end,
  },
}
