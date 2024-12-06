return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  opts = {
    ensure_installed = {
      -- defaults
      "vim",
      "vimdoc",
      "lua",
      -- web dev
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "json5",
      "vue",
      "markdown",
      "markdown_inline",
      "jsdoc",
      "scss",
      "styled", -- styled components
      -- low level
      "rust",
      "ron",
      "toml",
      "go",
      "gomod",
      "gowork",
      "gosum",
      "sql",
      -- git
      "git_config",
      "gitcommit",
      "git_rebase",
      "gitignore",
      "gitattributes",
    },
    auto_install = true,
    highlight = {
      enable = function()
        return not vim.b.large_buf
      end,
      disable = function()
        return vim.b.large_buf
      end,
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
