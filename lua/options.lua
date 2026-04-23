require("nvchad.options")

-- add yours here!

local o = vim.o
o.cursorline = true -- 启用 cursorline
o.cursorlineopt = "both" -- 同时高亮行和行号
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars = { vert = " " } -- 隐藏垂直窗口分隔线
vim.o.autoread = true -- 全局启用自动读取
vim.opt.tabstop = 4

-- 格式化开关
vim.g.autoformat = true -- 全局自动格式化开关（默认启用）

-- Treesitter 折叠
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99 -- 打开文件时默认展开所有折叠
