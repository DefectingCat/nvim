-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set
local usercmd = require("config.usercmd")

-- terminal
map("t", "<C-x>", "<c-\\><c-n>", { desc = "Escape termainl" })
map("n", "<leader>tt", ":term<CR>", { desc = "Open new terminal" })

-- buffers
-- map("n", "<S-l>", "<CMD>bn<CR>")
-- map("n", "<S-h>", "<CMD>bp<CR>")
map("n", "<leader>x", "<CMD>bd<CR>", { desc = "Close current buffer" })
-- map("n", "<C-s>", "<CMD>w<CR>")
map("n", "<leader>la", "<CMD>%bd|e#|bd#<CR>", { desc = "Close all other buffers" })

-- tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>]", ":tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>[", ":tabprevious<CR>", { desc = "Previous tab" })

-- search
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- copy
-- map({ "n", "v" }, "y", '"+y', { desc = "Copy to system clipboard" })

-- lsp
map("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })

-- trouble
map("n", "<leader>tx", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
-- map("n", "<leader>tX", "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics" })
map("n", "<leader>tL", "<CMD>Trouble loclist toggle<CR>", { desc = "Location List" })
map("n", "<leader>tQ", "<CMD>Trouble qflist toggle<CR>", { desc = "Quickfix List" })

-- general
map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")

-- snacks picker
map("n", "<leader><leader>", function()
  Snacks.picker.buffers({
    finder = "buffers",
    format = "buffer",
    hidden = false,
    unloaded = true,
    current = false,
    sort_lastused = true,
    layout = {
      preview = "main",
      preset = "ivy",
    },
    on_show = function()
      vim.cmd.stopinsert()
    end,
    win = {
      input = {
        keys = {
          ["d"] = { "bufdelete", mode = { "n" } },
        },
      },
      list = { keys = { ["d"] = "bufdelete" } },
    },
  })
end, { desc = "Buffers" })
map("n", "<leader>ff", function()
  Snacks.picker.files({
    finder = "files",
    format = "file",
    show_empty = true,
    hidden = true,
    ignored = false,
    follow = false,
    supports_live = true,
    layout = {
      preview = "main",
      preset = "ivy",
    },
  })
end, {
  desc = "Find Files",
})
map("n", "<leader>fw", function()
  Snacks.picker.grep({
    hidden = true,
    layout = {
      preview = "main",
      preset = "ivy",
    },
  })
end, { desc = "Grep" })
map("n", "<leader>fb", function()
  Snacks.picker.grep({
    layout = {
      preview = "main",
      preset = "ivy",
    },
  })
end, { desc = "Grep Open Buffers" })
map("n", "<leader>ct", function()
  Snacks.picker.pick({
    source = "filetypes",
    layout = {
      preview = "main",
      preset = "ivy",
    },
  })
end, { desc = "Change file type" })
map("n", "<leader>fi", usercmd.select_image, { desc = "Select image with snacks" })

-- File path
map("n", "<leader>tf", usercmd.copy_relative_path, { desc = "Copy relative path to clipboard" })

-- crates
map("n", "<leader>cu", function()
  require("crates").upgrade_all_crates()
end, { desc = "Upgrade all crates" })
