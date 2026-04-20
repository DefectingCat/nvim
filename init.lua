vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require("configs.lazy")

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require("options")
require("autocmds")

vim.schedule(function()
  require("mappings")
end)

-- treesitter user commands
local parsers = {
  "lua",
  "vim",
  "vimdoc",
  -- Web
  "javascript",
  "typescript",
  "tsx",
  "jsdoc",
  "json",
  "jsonc",
  "html",
  "css",
  "yaml",
  -- Backend
  "c",
  "rust",
  "toml",
  "go",
  "gomod",
  "gosum",
  "gowork",
  -- Infra
  "dockerfile",
  "make",
}

vim.api.nvim_create_user_command("TSInstallAll", function()
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  vim.cmd("TSInstall " .. table.concat(parsers, " "))
end, { desc = "Install listed Treesitter parsers" })

vim.api.nvim_create_user_command("TSUpdateAll", function()
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  vim.cmd("TSUpdate " .. table.concat(parsers, " "))
end, { desc = "Update listed Treesitter parsers" })
