-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- terminal
map("t", "<C-x>", "<c-\\><c-n>")
-- map("n", "<leader>tt", ":term<CR>", { desc = "Open new terminal" })

-- buffers
-- map("n", "<S-l>", "<CMD>bn<CR>")
-- map("n", "<S-h>", "<CMD>bp<CR>")
map("n", "<leader>x", "<CMD>bd<CR>")
-- map("n", "<C-s>", "<CMD>w<CR>")
map("n", "<leader>la", "<CMD>%bd|e#|bd#<CR>")

-- tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })

-- search
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- copy
-- map({ "n", "v" }, "y", '"+y', { desc = "Copy to system clipboard" })

-- lsp
map("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>")
