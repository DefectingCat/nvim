return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  -- event = "VeryLazy",
  cmd = {
    "NvimTreeFindFileToggle",
  },
  keys = {
    { "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle file explorer on current file" },
  },
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 35,
        relativenumber = false,
        number = false,
        side = "right",
      },
      update_focused_file = {
        enable = true,
        update_root = {
          enable = false,
        },
      },
      -- change folder arrow icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              -- arrow_closed = "", -- arrow when folder is closed
              -- arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      -- filters = {
      --   custom = { ".DS_Store" },
      -- },
      git = {
        ignore = false,
      },
    })
  end,
}
