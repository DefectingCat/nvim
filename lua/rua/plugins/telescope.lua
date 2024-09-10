return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-p>"] = actions.move_selection_previous, -- move to prev result
            ["<C-n>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local map = vim.keymap.set

    map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    -- map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    map("n", "<leader>gm", "<cmd> Telescope git_commits <CR>", { desc = "Git commits" })
    map("n", "<leader>fc", function()
      require("telescope.builtin").command_history()
    end, { desc = "Search command history" })
    map("n", "<leader>fr", function()
      require("telescope.builtin").resume()
    end, { desc = "Resume last search" })
    map("n", "<leader>ct", function()
      require("telescope.builtin").filetypes()
    end, { desc = "Set current filetype" })
    map("n", "<leader>fd", function()
      require("telescope.builtin").diagnostics()
    end, { desc = "Find Diagnostics" })
    map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
  end,
}
