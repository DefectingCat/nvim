require("nvchad.options")

local opt = vim.opt

vim.g.dap_virtual_text = true
vim.wo.relativenumber = true
vim.wo.wrap = false
vim.o.cursorlineopt = "number,line"
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 20
opt.ignorecase = true
opt.wildignore:append({ "*/node_modules/*" })
opt.clipboard:append({ "unnamedplus" })
--[[ opt.iskeyword:append("-") ]]
opt.termguicolors = true -- True color support
opt.autoindent = true --- Good auto indent
opt.scrolloff = 3
opt.encoding = utf8
opt.fileencoding = utf8
