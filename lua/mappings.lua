require("nvchad.mappings")

local map = vim.keymap.set
-- disable
local nomap = vim.keymap.del
--[[ nomap("t", "<ESC>") ]]
nomap("n", "<leader>x")

-- rust
map("n", "<leader>cu", function()
	require("crates").upgrade_all_crates()
end, { desc = "Update crates" })

-- dap
--[[ map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>") ]]
--[[ map("n", "<leader>dr", "<cmd> DapContinue <CR>", { desc = "Run or continue the debugger" }) ]]
--[[ map("n", "<leader>dus", function() ]]
--[[   local widgets = require("dap.ui.widgets") ]]
--[[   local sidebar = widgets.sidebar(widgets.scopes) ]]
--[[   sidebar.open() ]]
--[[ end, { desc = "Open debugging sidebar" }) ]]
--[[ map("n", "<leader>drr", "<cmd> RustLsp debuggables <CR>", { desc = "Run rust debug on current file" }) ]]
--[[ map("n", "<leader>dgr", function() ]]
--[[   require("dap-go").debug_test() ]]
--[[ end, { desc = "Open debugging sidebar" }) ]]
--[[ map("n", "<leader>dgl", function() ]]
--[[   require("dap-go").debug_last() ]]
--[[ end, { desc = "Debug last go test" }) ]]

-- golang
map("n", "<leader>gsj", "<cmd> GoTagAdd json <CR>", { desc = "Add json struct tags" })
map("n", "<leader>gsy", "<cmd> GoTagAdd yaml <CR>", { desc = "Add yaml struct tags" })

-- lsp
map("n", "gh", function()
	vim.lsp.buf.hover()
	--[[ require("pretty_hover").hover() ]]
end, { desc = "󱙼 Hover lsp" })
map("n", "gr", "<CMD>Telescope lsp_references<CR>", { desc = " Lsp references" })
map("n", "<leader>ls", "<CMD>LspRestart<CR>", { desc = " Restart lsp" })
--[[ map("n", "gr", "<CMD>Telescope lsp_definitions <CR>", { desc = " Lsp definitions" }) ]]

-- rua
map("n", "<leader>tn", "<CMD> tabNext <CR>", { desc = "Goto next tab" })
map("n", "<leader>tp", "<CMD> tabprevious <CR>", { desc = "Goto prev tab" })
map("n", "<leader>tc", "<CMD> tabclose <CR>", { desc = "Close tab" })
--[[ map({ "n" }, "<S-l>", function()
	require("nvchad.tabufline").next()
end, { desc = "Goto next buffer" })
map({ "n" }, "<S-h>", function()
	require("nvchad.tabufline").prev()
end, { desc = "Goto prev buffer" }) ]]
map("n", "<S-l>", "<CMD> bn <CR>", { desc = "Goto next buffer" })
map("n", "<S-h>", "<CMD> bp <CR>", { desc = "Goto prev buffer" })
map("n", "<leader>la", "<CMD> silent! %bd|e#|bd# <CR>", { desc = "Close all other buffers" })
map("n", "<leader>x", "<CMD> bp|bd # <CR>", { desc = "Close current buffer" })
map("t", "<leader>x", "<CMD> silent! bp|bd # <CR>", { desc = "Close current terminal buffer" })
map("n", "<C-a>", "gg<S-v>G")
map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")
-- move lines
--[[ map("n", "<A-j>", ":m .+1<CR>==") ]]
--[[ map("n", "<A-k>", ":m .-2<CR>==") ]]
--[[ map("i", "<A-j>", "<Esc>:m .+1<CR>==gi") ]]
--[[ map("i", "<A-k>", "<Esc>:m .-2<CR>==gi") ]]
--[[ map("v", "<A-j>", ":m '>+1<CR>gv=gv") ]]
--[[ map("v", "<A-k>", ":m '<-2<CR>gv=gv") ]]
map({ "n", "v" }, "f", function()
	local hop = require("hop")
	local directions = require("hop.hint").HintDirection
	hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line after cursor" })
map({ "n", "v" }, "F", function()
	local hop = require("hop")
	local directions = require("hop.hint").HintDirection
	hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line before cursor" })
map({ "n", "v" }, "<leader><leader>", function()
	local hop = require("hop")
	hop.hint_words({ current_line_only = false })
end, { desc = "Hop motion search words after cursor" })

-- format
map("n", "<leader>tf", "<cmd> FormatToggle <cr>", { desc = "Re-enable autoformat-on-save" })

--term
map({ "n", "t" }, "<A-u>", function()
	require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm", size = 0.4 })
end, { desc = "Terminal Toggleable vertical term" })
map({ "n", "t" }, "<A-o>", function()
	require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm", size = 0.3 })
end, { desc = "Terminal New horizontal term" })
map({ "n", "t" }, "<A-i>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm", float_opts = { width = 0.9, height = 0.8, row = 0.05, col = 0.05 } })
end, { desc = "Terminal Toggle Floating term" })
map({ "n", "t" }, "<D-u>", function()
	require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm", size = 0.4 })
end, { desc = "Terminal Toggleable vertical term" })
map({ "n", "t" }, "<D-o>", function()
	require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm", size = 0.3 })
end, { desc = "Terminal New horizontal term" })
map({ "n", "t" }, "<D-i>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle Floating term" })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "switch window down" })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "switch window up" })
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "switch window left" })
--[[ map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "switch window right" }) ]]
map({ "n" }, "<leader>tt", "<CMD> term <CR>", { desc = "Open new terminal in new buffer" })

-- arrange buffer
map("n", "<leader>ll", function()
	require("nvchad.tabufline").move_buf(1)
end, {
	desc = "Move buffer right",
})
map("n", "<leader>lh", function()
	require("nvchad.tabufline").move_buf(-1)
end, { desc = "Move buffer left" })
-- markdown preview
map("n", "<leader>pm", "<cmd> MarkdownPreview <CR>", { desc = "Preview Markdown file" })
-- window split
map("n", "<leader>|", "<cmd> vs <CR>", { desc = "Split window vertically" })
map("n", "<leader>_", "<cmd> sp <CR>", { desc = "Split window horizontally" })
-- spectre search
map("n", "<leader>ss", '<cmd>lua require("spectre").open()<CR>', { desc = "Toggle Spectre" })
map(
	"n",
	"<leader>sw",
	'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
	{ desc = "Spectre search current word" }
)
map(
	"n",
	"<leader>sp",
	'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
	{ desc = "Spectre search on current file" }
)
map("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Spectre search current word" })
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- telescope
map("n", "<leader>gm", "<cmd> Telescope git_commits <CR>", { desc = "Git commits" })
map("n", "<leader>gd", "<cmd> DiffviewOpen <CR>", { desc = "Open diff view" })
map("n", "<leader>gg", "<cmd> Neogit <CR>", { desc = "Open Neogit" })
map({ "n" }, "<leader>gl", function()
	require("nvchad.term").toggle({ pos = "float", id = "lazygit", cmd = "lazygit", float_opts = { width = 0.9, height = 0.8, row = 0.05, col = 0.05 } })
end, { desc = "Toggle Floating lazygit" })
--[[ map("n", "<leader>gf", "<cmd> LazyGitFilterCurrentFile <CR>", { desc = "Open LazyGit fitler current file" }) ]]
map("n", "<leader>gh", "<cmd> DiffviewFileHistory % <CR>", { desc = "Open current file history" })
map("n", "<leader>gc", "<cmd> DiffviewClose <CR>", { desc = "Close Diffview" })
map("n", "<leader>fc", function()
	require("telescope.builtin").command_history()
end, { desc = "Search command history" })
map("n", "<leader>fr", function()
	require("telescope.builtin").resume()
end, { desc = "Resume last search" })
map("n", "<leader>ft", function()
	require("telescope.builtin").filetypes()
end, { desc = "Set current filetype" })
map("n", "<leader>fd", function()
	require("telescope.builtin").diagnostics()
end, { desc = "Find Diagnostics" })

-- lspconfig
map("n", "<leader>co", "<cmd> OrganizeImports <CR>", { desc = "Organize imports" })
-- nvim tree
map("n", "<leader>e", "<cmd> NvimTreeToggle <CR>", { desc = "Toggle nvim tree" })
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- database
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Toggle DBUI" })
