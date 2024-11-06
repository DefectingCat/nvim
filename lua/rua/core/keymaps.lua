local map = vim.keymap.set

map("n", "<ESC>", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- increment/decrement numbers
-- map("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
-- map("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
map("n", "<leader>|", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
map("n", "<leader>_", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height

-- move lines
map("n", "<A-j>", ":m .+1<CR>==")
map("n", "<A-k>", ":m .-2<CR>==")
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
map("v", "<A-j>", ":m '>+1<CR>gv=gv")
map("v", "<A-k>", ":m '<-2<CR>gv=gv")

map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")

-- terminal
map("t", "<C-x>", "<c-\\><c-n>")
map("n", "<leader>tt", ":term<CR>", { desc = "Open new terminal" })

-- buffers
map("n", "<S-l>", "<CMD>bn<CR>")
map("n", "<S-h>", "<CMD>bp<CR>")
map("n", "<leader>x", "<CMD>bd<CR>")
map("n", "<C-s>", "<CMD>w<CR>")
map("n", "<leader>la", "<CMD>%bd|e#|bd#<CR>")

-- tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })

map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })
