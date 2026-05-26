require("nvchad.options")

-- add yours here!

local o = vim.o
o.cursorline = true -- 启用 cursorline
o.cursorlineopt = "both" -- 同时高亮行和行号
vim.opt.fillchars = { vert = " " } -- 隐藏垂直窗口分隔线
vim.o.autoread = true -- 全局启用自动读取
vim.opt.tabstop = 4

-- 格式化开关
vim.g.autoformat = true -- 全局自动格式化开关（默认启用）

-- 延迟初始化 clipboard（Windows 下查询 provider 较慢）
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Treesitter 折叠已移至 autocmds.lua（BufEnter 延迟设置）
vim.o.foldlevel = 99 -- 打开文件时默认展开所有折叠
