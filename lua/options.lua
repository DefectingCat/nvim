require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorline = true -- 启用 cursorline
o.cursorlineopt = "both" -- 同时高亮行和行号
vim.opt.clipboard = "unnamedplus"
vim.o.autoread = true -- 全局启用自动读取
vim.opt.tabstop = 4
