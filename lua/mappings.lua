require("nvchad.mappings")

local map = vim.keymap.set

-- rust
map("n", "<leader>rcu", function()
  require("crates").upgrade_all_crates()
end, { desc = "Update crates" })

-- dap
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>")
map("n", "<leader>dr", "<cmd> DapContinue <CR>", { desc = "Run or continue the debugger" })
map("n", "<leader>dus", function()
  local widgets = require("dap.ui.widgets")
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, { desc = "Open debugging sidebar" })
map("n", "<leader>drr", "<cmd> RustLsp debuggables <CR>", { desc = "Run rust debug on current file" })
map("n", "<leader>dgr", function()
  require("dap-go").debug_test()
end, { desc = "Open debugging sidebar" })
map("n", "<leader>dgl", function()
  require("dap-go").debug_last()
end, { desc = "Debug last go test" })

-- golang
map("n", "<leader>gsj", "<cmd> GoTagAdd json <CR>", { desc = "Add json struct tags" })
map("n", "<leader>gsy", "<cmd> GoTagAdd yaml <CR>", { desc = "Add yaml struct tags" })

-- lsp
map("n", "gh", function()
  vim.lsp.buf.hover()
  --[[ require("pretty_hover").hover() ]]
end, { desc = "󱙼 Hover lsp" })
map("n", "gr", "<CMD>Telescope lsp_references<CR>", { desc = " Lsp references" })
--[[ map("n", "gr", "<CMD>Telescope lsp_definitions <CR>", { desc = " Lsp definitions" }) ]]

-- rua
map("n", "<tab>", "<CMD> tabNext <CR>", { desc = "Goto next tab" })
map("n", "<S-tab>", "<CMD> tabprevious <CR>", { desc = "Goto prev tab" })
map("n", "<S-l>", function()
  require("nvchad.tabufline").next()
end, { desc = "Goto next buffer" })
map("n", "<S-h>", function()
  require("nvchad.tabufline").prev()
end, { desc = "Goto prev buffer" })
map("n", "<leader>la", "<CMD> %bd|e#|bd# <CR>", { desc = "Close all other buffers" })
map("n", "<C-a>", "gg<S-v>G")
map("n", "$", "g_")
map("v", "$", "g_")
map("n", "f", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line after cursor" })
map("n", "F", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line before cursor" })
map("n", "<leader>w", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { desc = "Hop motion search words after cursor" })
map("n", "<leader>b", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_words({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { desc = "Hop motion search words before cursor" })
map("v", "f", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line after cursor" })
map("v", "F", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { desc = "Hop motion search in current line before cursor" })
map("v", "<leader>w", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { desc = "Hop motion search words after cursor" })
map("v", "<leader>b", function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection
  hop.hint_words({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { desc = "Hop motion search words before cursor" })
--term
map({ "n", "t" }, "<A-u>", function()
  require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm", size = 0.3 })
end, { desc = "Terminal Toggleable vertical term" })
map({ "n", "t" }, "<A-o>", function()
  require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm", size = 0.3 })
end, { desc = "Terminal New horizontal term" })
map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle Floating term" })
map({ "n", "t" }, "<D-u>", function()
  require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm", size = 0.3 })
end, { desc = "Terminal Toggleable vertical term" })
map({ "n", "t" }, "<D-o>", function()
  require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm", size = 0.3 })
end, { desc = "Terminal New horizontal term" })
map({ "n", "t" }, "<D-i>", function()
  require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle Floating term" })
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
-- notify
map("n", "<leader>un", function()
  require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Dismiss all Notifications" })
-- markdown preview
map("n", "<leader>pm", "<cmd> MarkdownPreview <CR>", { desc = "Preview Markdown file" })
-- window split
map("n", "<leader>|", "<cmd> vs <CR>", { desc = "Split window vertically" })
map("n", "<leader>_", "<cmd> sp <CR>", { desc = "Split window horizontally" })
-- spectre search
map("n", "<leader>ss", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
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
map(
  "v",
  "<leader>sw",
  '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
  { desc = "Spectre search current word" }
)
map(
  "v",
  "<leader>sp",
  '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
  { desc = "Spectre search on current file" }
)
-- none-ls
map("n", "<leader>tf", function()
  vim.g.auto_format = not vim.g.auto_format
  vim.notify("Auto format " .. tostring(vim.g.auto_format))
end, { desc = "Toggle auto format" })

-- trobule
map("n", "<leader>tx", "<cmd>TroubleToggle<CR>")
map("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<CR>")
map("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<CR>")
map("n", "<leader>tq", "<cmd>TroubleToggle quickfix<CR>")
map("n", "<leader>tl", "<cmd>TroubleToggle loclist<CR>")
map("n", "gR", "<cmd>TroubleToggle lsp_references<CR>")

-- telescope
map("n", "<leader>gm", "<cmd> Telescope git_commits <CR>", { desc = "Git commits" })
map("n", "<leader>gd", "<cmd> DiffviewOpen <CR>", { desc = "Open diff view" })
map("n", "<leader>gg", "<cmd> LazyGit <CR>", { desc = "Open LazyGit" })
map("n", "<leader>gf", "<cmd> LazyGitFilterCurrentFile <CR>", { desc = "Open LazyGit fitler current file" })
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
map("n", "<leader>fn", function()
  require("telescope").extensions.notify.notify()
end, { desc = "View notify history" })

-- lspconfig
map("n", "<leader>co", "<cmd> OrganizeImports <CR>", { desc = "Organize imports" })

-- disable
local nomap = vim.keymap.del

nomap("t", "<ESC>")
