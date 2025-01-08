local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.dap_virtual_text = true
vim.g.trouble_lualine = true
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
-- Hide deprecation warnings
vim.g.deprecation_warnings = false

vim.fn.sign_define("DapBreakpoint", { text = "", numhl = "DapBreakpoint", texthl = "DapBreakpoint" })
vim.fn.sign_define("DagLogPoint", { text = "", numhl = "DapLogPoint", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "", numhl = "DapStopped", texthl = "DapStopped" })
vim.fn.sign_define(
  "DapBreakpointRejected",
  { text = "", numhl = "DapBreakpointRejected", texthl = "DapBreakpointRejected" }
)

vim.o.cursorlineopt = "number,line"

opt.termguicolors = true
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 20
opt.ignorecase = true
opt.wildignore:append({ "*/node_modules/*" })
opt.wildignore:append("*/node_modules/*")
-- opt.clipboard:append({ "unnamedplus" })
-- opt.iskeyword:append("-")
opt.termguicolors = true -- True color support
opt.autoindent = true --- Good auto indent
opt.scrolloff = 3
opt.encoding = "utf8"
opt.fileencoding = "utf8"
opt.cursorline = true
opt.autowrite = true -- Enable auto write
opt.autoread = true
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0

if not vim.env.SSH_TTY then
  opt.clipboard = "unnamedplus"
end
-- opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
-- opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.spelloptions:append("noplainbuffer")
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
