return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        sql = { "sqlfluff" },
        lua = { "stylua" },
        go = { "goimports", "gofumpt" },
        sh = { "shfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        less = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        graphql = { "prettier" },
        python = { "isort", "black" },
        php = { "intelephense" },
        c = { "clang-format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Use the "*" filetype to run formatters on all filetypes.
        -- ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
      -- If this is set, Conform will run the formatter asynchronously after save.
      -- It will pass the table to conform.format().
      -- This can also be a function that returns the table.
      format_after_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return { lsp_fallback = false }
        end
        return { lsp_fallback = true }
      end,
      notify_on_error = true,
      lang_to_ext = {
        bash = "sh",
        sql = "sql",
        c_sharp = "cs",
        elixir = "exs",
        latex = "tex",
        markdown = "md",
        python = "py",
        ruby = "rb",
        teal = "tl",
      },
      options = {
        -- Use a specific prettier parser for a filetype
        -- Otherwise, prettier will try to infer the parser from the file name
        ft_parsers = {
          --     javascript = "babel",
          --     javascriptreact = "babel",
          --     typescript = "typescript",
          --     typescriptreact = "typescript",
          --     vue = "vue",
          --     css = "css",
          --     scss = "scss",
          --     less = "less",
          --     html = "html",
          --     json = "json",
          --     jsonc = "json",
          --     yaml = "yaml",
          --     markdown = "markdown",
          --     ["markdown.mdx"] = "mdx",
          --     graphql = "graphql",
          --     handlebars = "glimmer",
        },
        -- Use a specific prettier parser for a file extension
        ext_parsers = {
          -- qmd = "markdown",
        },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
            lang_to_formatters = {
              sql = { "sqlfluff" },
            },
            lang_to_ext = {
              sql = "sql",
            },
          },
        },
        sqlfluff = {
          command = "sqlfluff",
          args = {
            "fix",
            "--dialect",
            "sqlite",
            "--disable-progress-bar",
            "-f",
            "-n",
            "-",
          },
          stdin = true,
        },
        rustfmt = {
          options = {
            -- The default edition of Rust to use when no Cargo.toml file is found
            default_edition = "2021",
          },
        },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>fm", function()
      conform.format({
        lsp_fallback = true,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
    vim.keymap.set("n", "<leader>tf", "<cmd> FormatToggle <cr>", { desc = "Re-enable autoformat-on-save" })
  end,
}
