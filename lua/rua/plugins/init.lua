return {
  "nvim-lua/plenary.nvim", -- lua functions that many plugins use
  "christoomey/vim-tmux-navigator", -- tmux & split window navigation
  "b0o/schemastore.nvim", -- json schema store

  -- search
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
  },
}
