return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Fuzzy find files in cwd" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Fuzzy find recent files" },
    { "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Find string in cwd" },
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find todos" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
    -- { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Find marks" },
    { "<leader>fh", "<cmd>Telescope search_history<cr>", desc = "Find search history" },
    { "<leader>gm", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    {
      "<leader>fc",
      function()
        require("telescope.builtin").command_history()
      end,
      desc = "Search command history",
    },
    {

      "<leader>fr",
      function()
        require("telescope.builtin").resume()
      end,
      desc = "Resume last search",
    },
    {

      "<leader>ct",
      function()
        require("telescope.builtin").filetypes()
      end,
      desc = "Set current filetype",
    },
    {

      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "Find Diagnostics",
    },
    { "<leader>b", "<cmd>Telescope buffers initial_mode=normal<CR>", desc = "telescope find buffers" },
  },
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
          n = {
            ["d"] = require("telescope.actions").delete_buffer,
          },
          i = {
            ["<C-p>"] = actions.move_selection_previous, -- move to prev result
            ["<C-n>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
      pickers = {
        buffers = {
          theme = "ivy",
        },
        git_files = {
          theme = "ivy",
        },
        oldfiles = {
          theme = "ivy",
        },
        find_files = {
          theme = "ivy",
        },
        colorscheme = {
          theme = "ivy",
        },
        marks = {
          theme = "ivy",
        },
        lsp_document_symblos = {
          theme = "ivy",
        },
        lsp_dynamic_workspace_symbols = {
          theme = "ivy",
        },
        lsp_references = {
          theme = "ivy",
        },
      },
    })
    telescope.load_extension("fzf")
  end,
}
