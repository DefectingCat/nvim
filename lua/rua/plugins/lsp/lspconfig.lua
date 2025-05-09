return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      -- { "antosha417/nvim-lsp-file-operations", config = true },
      -- { "folke/neodev.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
    },
    event = "VeryLazy",
    opts = { document_highlight = { enabled = false } },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      -- local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local map = vim.keymap.set -- for conciseness

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          opts.desc = "Show LSP references"
          map("n", "gr", function()
            require("telescope.builtin").lsp_references()
          end, opts) -- show definition, references

          opts.desc = "Go to declaration"
          map("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

          opts.desc = "Show LSP definitions"
          -- map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
          -- map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- show lsp definitions
          map("n", "gd", function()
            require("telescope.builtin").lsp_definitions()
          end, opts) -- show lsp definitions

          opts.desc = "Show LSP implementations"
          -- map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
          map("n", "gi", function()
            require("telescope.builtin").lsp_implementations()
          end, opts) -- show lsp implementations

          opts.desc = "Show LSP type definitions"
          -- map("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
          map("n", "<leader>gt", function()
            require("telescope.builtin").lsp_type_definitions()
          end, opts) -- show lsp type definitions

          opts.desc = "See available code actions"
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

          opts.desc = "Smart rename"
          map("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

          opts.desc = "Show buffer diagnostics"
          -- map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
          map("n", "<leader>D", function()
            require("telescope.builtin").diagnostics()
          end, opts) -- show  diagnostics for file

          -- opts.desc = "Show line diagnostics"
          -- map("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

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

      -- local capabilities = cmp_nvim_lsp.default_capabilities()

      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      mason_lspconfig.setup({
        automatic_enable = {
          exclude = {
            "biome",
            "dockerls",
            "tailwindcss",
            "rust_analyzer",
            "taplo",
            "denols",
            "vtsls",
            "jsonls",
            "lua_ls",
          },
        },
      })
      vim.lsp.enable("biome")
      vim.lsp.config("biome", {
        settings = {
          cmd = { "biome", "lsp-proxy" },
          filetypes = {
            "astro",
            "css",
            "graphql",
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "svelte",
            "typescript",
            "typescript.tsx",
            "typescriptreact",
            "vue",
            "markdown",
          },
          single_file_support = true,
        },
      })
      vim.lsp.enable("dockerls")
      vim.lsp.config("dockerls", {
        settings = {
          docker = {
            languageserver = {
              formatter = {
                ignoreMultilineInstructions = true,
              },
            },
          },
        },
      })
      vim.lsp.enable("tailwindcss")
      vim.lsp.config("tailwindcss", {
        settings = require("rua.config.tailwindcss"),
      })
      -- vim.lsp.config("rust_analyzer", {})
      vim.lsp.enable("taplo")
      vim.lsp.config("taplo", {
        settings = {
          keys = {
            {
              "gh",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      })
      vim.lsp.enable("denols")
      vim.lsp.config("denols", {
        settings = {
          root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
        },
      })
      local vtsls_settings = require("rua.config.vtsls")
      vim.lsp.enable("vtsls")
      vim.lsp.config("vtsls", vtsls_settings)
      vim.lsp.enable("jsonls")
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
        end,
      })
      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            completion = {
              callSnippet = "Replace",
            },
          },
          Luau = {
            diagnostics = {
              globals = { "vim" },
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      -- Nvim 0.11+ (see vim.lsp.config)
      -- vim.lsp.config('rust_analyzer', {
      --   -- Server-specific settings. See `:help lsp-quickstart`
      --   settings = {
      --     ['rust-analyzer'] = {},
      --   },
      -- })
      -- Nvim 0.10 (legacy, not supported)
      -- local lspconfig = require('lspconfig')
      -- lspconfig.rust_analyzer.setup {
      --   -- Server-specific settings. See `:help lspconfig-setup`
      --   settings = {
      --     ['rust-analyzer'] = {},
      --   },
      -- }
      -- mason_lspconfig.setup_handlers({
      --   -- default handler for installed servers
      --   function(server_name)
      --     lspconfig[server_name].setup({
      --       capabilities = capabilities,
      --     })
      --   end,
      --   ["biome"] = function()
      --     lspconfig["biome"].setup({
      --       capabilities = capabilities,
      --       settings = {
      --         cmd = { "biome", "lsp-proxy" },
      --         filetypes = {
      --           "astro",
      --           "css",
      --           "graphql",
      --           "javascript",
      --           "javascriptreact",
      --           "json",
      --           "jsonc",
      --           "svelte",
      --           "typescript",
      --           "typescript.tsx",
      --           "typescriptreact",
      --           "vue",
      --           "markdown",
      --         },
      --         single_file_support = true,
      --       },
      --     })
      --   end,
      --   ["dockerls"] = function()
      --     lspconfig["dockerls"].setup({
      --       settings = {
      --         docker = {
      --           languageserver = {
      --             formatter = {
      --               ignoreMultilineInstructions = true,
      --             },
      --           },
      --         },
      --       },
      --     })
      --   end,
      --   ["tailwindcss"] = function()
      --     lspconfig["tailwindcss"].setup(require("rua.config.tailwindcss"))
      --   end,
      --   ["rust_analyzer"] = function()
      --     -- lspconfig["rust_analyzer"].setup(require("rua.config.rust-analyzer"))
      --   end,
      --   ["taplo"] = function()
      --     lspconfig["taplo"].setup({
      --       keys = {
      --         {
      --           "gh",
      --           function()
      --             if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
      --               require("crates").show_popup()
      --             else
      --               vim.lsp.buf.hover()
      --             end
      --           end,
      --           desc = "Show Crate Documentation",
      --         },
      --       },
      --     })
      --   end,
      --   ["denols"] = function()
      --     lspconfig["denols"].setup({
      --       -- on_attach = on_attach,
      --       capabilities = capabilities,
      --       root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      --     })
      --   end,
      --   ["vtsls"] = function()
      --     lspconfig["vtsls"].setup(require("rua.config.vtsls"))
      --     map("n", "<leader>co", "<cmd> OrganizeImports <CR>", { desc = "Organize imports" })
      --   end,
      --   ["jsonls"] = function()
      --     lspconfig["jsonls"].setup({
      --       -- lazy-load schemastore when needed
      --       on_new_config = function(new_config)
      --         new_config.settings.json.schemas = new_config.settings.json.schemas or {}
      --         vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
      --       end,
      --       settings = {
      --         json = {
      --           format = {
      --             enable = true,
      --           },
      --           validate = { enable = true },
      --         },
      --       },
      --     })
      --   end,
      --   ["lua_ls"] = function()
      --     lspconfig["lua_ls"].setup({
      --       capabilities = capabilities,
      --       settings = {
      --         Lua = {
      --           diagnostics = {
      --             globals = { "vim" },
      --           },
      --           completion = {
      --             callSnippet = "Replace",
      --           },
      --         },
      --       },
      --     })
      --   end,
      -- })
    end,
  },
}
