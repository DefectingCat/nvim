-- =============================================================================
-- Neovim 配置文件入口 (init.lua)
-- =============================================================================
-- 本文件是 Neovim 启动时第一个加载的配置文件。
-- 设计目标：最小化启动开销，所有重模块均通过自定义懒加载框架延迟加载。
--
-- 文件加载顺序：
--   1. init.lua      → 禁用内置插件、设置 colorscheme、加载核心模块
--   2. options.lua   → 全局选项 (number, indent, clipboard 等)
--   3. keymaps.lua   → 键位映射 (leader = space)
--  4. autocmds.lua  → 自动命令 (恢复光标位置、折叠、yank 高亮等)
--  5. usercmds.lua  → 自定义命令 (:PackAdd, :PackDel, :PackUpdate)
--  6. pack.lua      → 插件声明与懒加载配置
-- =============================================================================

-- 记录启动时间点，用于在 starter 页脚展示启动耗时。
-- vim.uv (Neovim 0.10+) 是 libuv 的绑定，提供高性能计时器；
-- vim.loop 是旧版兼容名，在 0.10 之前使用。
_G.nvim_start_time = (vim.uv or vim.loop).hrtime()

-- =============================================================================
-- 禁用不需要的内置插件
-- =============================================================================
-- Neovim 默认会加载大量内置插件（netrw、tar、zip 等），
-- 这些插件会在 startup 阶段 source 对应的 plugin/*.vim 文件，增加启动时间。
-- 通过设置 loaded_* 全局变量为 1（真值），可以跳过这些插件的加载。
--
-- 注意：loaded_syntax 设为 1 是为了避免旧版 Vim 兼容的 syntax 加载路径；
-- 实际语法高亮由 treesitter 接管，不受影响。
vim.g.loaded_2html_plugin = 1 -- :TOhtml 命令（将 buffer 导出为 HTML）
vim.g.loaded_getscript = 1 -- GetScript 插件（自动下载脚本）
vim.g.loaded_getscriptPlugin = 1 -- GetScript 插件主体
vim.g.loaded_gzip = 1 -- Gzip 压缩文件读写支持
vim.g.loaded_logipat = 1 -- LogiPat 逻辑模式匹配
vim.g.loaded_matchit = 1 -- % 匹配扩展（由 treesitter 或 mini.pairs 替代）
vim.g.loaded_matchparen = 1 -- 括号匹配高亮（由 treesitter 替代）
vim.g.loaded_netrw = 1 -- Netrw 文件浏览器（由 mini.files 替代）
vim.g.loaded_netrwFileHandlers = 1 -- Netrw 文件处理器
vim.g.loaded_netrwPlugin = 1 -- Netrw 插件主体
vim.g.loaded_netrwSettings = 1 -- Netrw 设置
vim.g.loaded_rrhelper = 1 -- RRHelper（R 语言相关）
vim.g.loaded_spellfile_plugin = 1 -- 拼写文件自动下载
vim.g.loaded_tar = 1 -- Tar 归档支持
vim.g.loaded_tarPlugin = 1 -- Tar 插件主体
vim.g.loaded_tutor_mode_plugin = 1 -- Vim Tutor 教程模式
vim.g.loaded_vimball = 1 -- Vimball 归档格式
vim.g.loaded_vimballPlugin = 1 -- Vimball 插件主体
vim.g.loaded_zip = 1 -- Zip 归档支持
vim.g.loaded_zipPlugin = 1 -- Zip 插件主体
vim.g.loaded_rplugin = 1 -- 远程插件框架
vim.g.loaded_tohtml = 1 -- :TOhtml 的另一入口
vim.g.loaded_syntax = 1 -- 旧版 syntax 自动加载
vim.g.loaded_synmenu = 1 -- Syntax 菜单
vim.g.loaded_optwin = 1 -- 选项窗口 (:options)
vim.g.loaded_compiler = 1 -- 编译器插件自动加载
vim.g.loaded_bugreport = 1 -- Bug 报告生成
vim.g.loaded_ftplugin = 1 -- 文件类型插件（手动管理）

-- =============================================================================
-- 启用 Neovim 0.12+ 内置 UI 增强
-- =============================================================================
-- vim._core.ui2 是 Neovim 0.12 实验性的 UI 增强模块，
-- 启用后提供更现代的默认界面行为（如更好的消息处理）。
require("vim._core.ui2").enable({})

-- =============================================================================
-- 加载核心配置模块
-- =============================================================================
-- 这些模块按顺序加载，后续模块可以依赖前面模块的设置。
-- 例如 pack.lua 中使用的键位映射依赖于 keymaps.lua 中设置的 leader 键。
require("options") -- 全局 vim 选项设置
require("keymaps") -- 键位映射定义
require("autocmds") -- 自动命令（autocmd）
require("usercmds") -- 用户自定义命令
require("pack") -- 插件管理与懒加载配置

-- =============================================================================
-- Colorscheme 设置
-- =============================================================================
-- moonflyTransparent：使 moonfly 主题的背景透明，
-- 即使当前使用 catppuccin-mocha，此变量仍保留以备切换主题。
vim.g.moonflyTransparent = true

-- 应用 colorscheme。catppuccin-mocha 的定义在 colors/catppuccin-mocha.lua 中。
-- 该文件是一个精简版，只包含 Mocha 变体的调色板和高亮组定义。
vim.cmd("colorscheme ex-catppuccin-mocha")

-- 记录 init.lua 执行完成时间（含 colorscheme），供启动页展示更接近 --startuptime 的耗时。
-- pack.lua 中的 footer 优先使用 VimEnter 时间，回退到此时间点。
_G.nvim_init_done = (vim.uv or vim.loop).hrtime()
