return {
  "rmagatti/auto-session",
  lazy = true,
  cmd = {
    "SessionRestore",
  },
  -- event = "VeryLazy",
  -- dependencies = {
  --   "nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
  -- },
  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    auto_restore = false,
    -- log_level = 'debug',
  },
}
