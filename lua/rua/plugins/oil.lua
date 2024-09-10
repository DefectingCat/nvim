return {
  "stevearc/oil.nvim",
  event = "BufReadPost",
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
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
      },
      skip_confirm_for_simple_edits = true,
    })
    local map = vim.keymap.set
    map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}
