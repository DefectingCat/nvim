return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "VeryLazy" },
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
      "json",
      "vue",
      "markdown",
      "markdown_inline",
      "jsdoc",
      "scss",
      "styled", -- styled components
      -- low level
      "rust",
      "toml",
      "go",
      "gomod",
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
      enable = true,
      disable = function(_, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
