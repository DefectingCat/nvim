return {
  "stevearc/oil.nvim",
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    {
      "_",
      function()
        require("oil").open(vim.fn.getcwd())
      end,
      desc = "Open parent directory",
    },
  },
  cmd = { "Oil" },
  -- lazy = false,
  -- event = "VimEnter",
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = false,
      view_options = {
        show_hidden = true,
      },
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = false,
        --[[ ["<C-h>"] = { "actions.select", opts = { horizontal = true } }, ]]
        ["<C-h>"] = false,
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = false,
        ["q"] = "actions.close",
        ["<C-l>"] = false,
        ["<C-r>"] = { "actions.refresh" },
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = { "actions.cd", opts = { scope = "tab" } },
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        -- Mappings can be a string
        -- ["~"] = "<cmd>edit $HOME<CR>",
        -- Mappings can be a function
        -- ["gd"] = function()
        --   require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
        -- end,
        -- You can pass additional opts to vim.keymap.set by using
        -- a table with the mapping as the first element.
        ["<leader>ff"] = {
          function()
            require("snacks").dashboard.pick("files", {
              supports_live = true,
              layout = {
                preview = "main",
                preset = "ivy",
              },
              hidden = true,
              cwd = require("oil").get_current_dir(),
            })
          end,
          mode = "n",
          nowait = true,
          desc = "Find files in the current directory",
        },
        ["<leader>fw"] = {
          function()
            require("snacks").dashboard.pick("live_grep", {
              supports_live = true,
              layout = {
                preview = "main",
                preset = "ivy",
              },
              hidden = true,
              cwd = require("oil").get_current_dir(),
            })
          end,
          mode = "n",
          nowait = true,
          desc = "Find files in the current directory",
        },
      },
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
    })
  end,
}
