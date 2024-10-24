local rok, rust_settings = pcall(require, "rua.config.rust-analyzer")

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
    version = "^4", -- Recommended
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>da", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = rust_settings,
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
