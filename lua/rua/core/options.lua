-- 获取 vim.opt 引用，方便后续使用
local opt = vim.opt

-- 设置全局变量
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.dap_virtual_text = true
vim.g.trouble_lualine = true

-- 修复 Markdown 缩进设置
vim.g.markdown_recommended_style = 0

-- 隐藏弃用警告
vim.g.deprecation_warnings = false

-- 定义调试相关的符号
vim.fn.sign_define("DapBreakpoint", { text = "", numhl = "DapBreakpoint", texthl = "DapBreakpoint" })
vim.fn.sign_define("DagLogPoint", { text = "", numhl = "DapLogPoint", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "", numhl = "DapStopped", texthl = "DapStopped" })
vim.fn.sign_define(
  "DapBreakpointRejected",
  { text = "", numhl = "DapBreakpointRejected", texthl = "DapBreakpointRejected" }
)

-- 设置光标行选项
vim.o.cursorlineopt = "number,line"

-- 设置基本选项
opt.termguicolors = true -- 启用真彩色支持
opt.foldmethod = "expr" -- 使用表达式进行折叠
opt.foldexpr = "nvim_treesitter#foldexpr()" -- 使用 Treesitter 折叠表达式
opt.foldlevel = 20 -- 初始折叠级别
opt.ignorecase = true -- 忽略大小写
opt.wildignore:append({ "*/node_modules/*" }) -- 忽略 node_modules 目录

-- 可选设置
-- opt.clipboard:append({ "unnamedplus" })
-- opt.iskeyword:append("-")

-- 自动缩进和滚动设置
opt.autoindent = true -- 自动缩进
opt.scrolloff = 3 -- 滚动时保留的行数
opt.encoding = "utf8" -- 文件编码为 UTF-8
opt.fileencoding = "utf8"
opt.cursorline = true -- 高亮当前行
opt.autowrite = true -- 自动保存
opt.autoread = true -- 自动读取文件更改

-- 根据是否在 SSH 会话中设置剪贴板选项
if not vim.env.SSH_TTY then
  opt.clipboard = "unnamedplus" -- 同步系统剪贴板
end

-- 其他选项设置
opt.completeopt = "menu,menuone,noselect" -- 补全选项
opt.conceallevel = 2 -- 隐藏 * 标记用于粗体和斜体，但不隐藏带有替换的标记
opt.confirm = true -- 退出修改过的缓冲区时确认保存
opt.expandtab = true -- 使用空格代替制表符
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99 -- 折叠级别
opt.formatoptions = "jcroqlnt" -- 格式化选项
opt.grepformat = "%f:%l:%c:%m" -- 搜索结果格式
opt.grepprg = "rg --vimgrep" -- 搜索命令
opt.inccommand = "nosplit" -- 预览增量替换
opt.jumpoptions = "view" -- 跳转选项
opt.laststatus = 3 -- 全局状态栏
opt.linebreak = true -- 在合适的位置换行
-- opt.list = true -- 显示一些不可见字符（如制表符等）
opt.mouse = "a" -- 启用鼠标模式
opt.number = true -- 显示行号
opt.pumblend = 10 -- 弹出菜单透明度
opt.pumheight = 10 -- 弹出菜单最大条目数
opt.relativenumber = true -- 显示相对行号
opt.scrolloff = 4 -- 滚动时保留的行数
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- 缩进取整
opt.shiftwidth = 2 -- 缩进大小
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- 不显示模式，因为有状态栏
opt.sidescrolloff = 8 -- 水平滚动时保留的列数
opt.signcolumn = "yes" -- 始终显示符号列
opt.smartcase = true -- 包含大写字母时不忽略大小写
opt.smartindent = true -- 自动插入缩进
opt.spelllang = { "en" } -- 拼写检查语言
opt.spelloptions:append("noplainbuffer")
opt.splitbelow = true -- 新窗口在当前窗口下方打开
opt.splitkeep = "screen"
opt.splitright = true -- 新窗口在当前窗口右侧打开
opt.tabstop = 2 -- 制表符宽度
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- 快速触发 which-key
opt.undofile = true -- 启用撤销文件
opt.undolevels = 10000 -- 撤销级别
opt.updatetime = 200 -- 保存交换文件并触发 CursorHold
opt.virtualedit = "block" -- 允许光标在视觉块模式下移动到无文本处
opt.wildmode = "longest:full,full" -- 命令行补全模式
opt.winminwidth = 5 -- 最小窗口宽度
opt.wrap = false -- 禁用换行
