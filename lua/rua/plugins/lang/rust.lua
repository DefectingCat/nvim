local rok, rust_settings = pcall(require, "rua.config.rust-analyzer")

if not rok then
  return {}
else
  return {
    {
      "Saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      keys = {
        {
          "<leader>cu",
          function()
            require("crates").upgrade_all_crates()
          end,
          desc = "Update crates",
        },
      },
      opts = {
        completion = {
          cmp = { enabled = true },
        },
      },
    },
    {
      "mrcjkb/rustaceanvim",
      version = "^6", -- Recommended
      ft = { "rust" },
      opts = {
        server = {
          on_attach = function(_, bufnr)
            local map = vim.keymap.set
            local opts = { buffer = bufnr, silent = true }
            map("n", "<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
            end, { desc = "Code Action", buffer = bufnr })
            map("n", "<leader>da", function()
              vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust Debuggables", buffer = bufnr })
            map("n", "gh", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { silent = true, buffer = bufnr })
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
          end,
          default_settings = rust_settings.settings,
        },
      },
      config = function(_, opts)
        vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
        if vim.fn.executable("rust-analyzer") == 0 then
          print("**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/")
          -- LazyVim.error(
          --   "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          --   { title = "rustaceanvim" }
          -- )
        end
      end,
    },
  }
end
