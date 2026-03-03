-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ============================================
-- 用户自定义自动命令配置
-- ============================================

-- 加载用户命令
require("config.usercmd")

-- ============================================
-- 文件类型检测与关联
-- ============================================

-- 封装设置文件类型的通用函数
-- 功能: 为指定模式的文件设置文件类型
-- 参数:
--   patterns - 文件名匹配模式 (字符串或字符串数组)
--   filetype - 要设置的文件类型
local function set_filetype(patterns, filetype)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = patterns,
    callback = function(args)
      vim.bo[args.buf].filetype = filetype
    end,
  })
end

-- 定义文件类型关联
-- MDX 文件使用 Markdown 高亮
set_filetype({ "*.mdx" }, "markdown")
-- 环境变量文件使用 Shell 高亮
set_filetype({ ".env.example", ".env.local", ".env.development", ".env.production" }, "sh")
-- JSON 文件默认使用 JSONC (支持注释)
set_filetype({ "*.json" }, "jsonc")

-- ============================================
-- 自动命令组定义
-- ============================================

-- 主要自动命令组
local my_group = vim.api.nvim_create_augroup("MyAutoGroup", { clear = true })
-- 终端窗口配置组
local terminal_group = vim.api.nvim_create_augroup("TerminalConfig", { clear = true })
-- Snacks.nvim 插件窗口配置组
local snacks_group = vim.api.nvim_create_augroup("SnacksConfig", { clear = true })
-- Avante 插件窗口配置组
local avante_group = vim.api.nvim_create_augroup("AvanteConfig", { clear = true })
-- Grug Far 搜索工具窗口配置组
local grugfar_group = vim.api.nvim_create_augroup("GrugFarConfig", { clear = true })
-- Oil.nvim 文件浏览器窗口配置组
local oil_group = vim.api.nvim_create_augroup("OilConfig", { clear = true })
-- Lazy.nvim 插件管理器窗口配置组
local lazy_group = vim.api.nvim_create_augroup("LazyConfig", { clear = true })
-- Mason 插件管理器窗口配置组
local mason_group = vim.api.nvim_create_augroup("MasonConfig", { clear = true })
-- 大文件检测配置组
local large_buf_group = vim.api.nvim_create_augroup("LargeBufferConfig", { clear = true })

-- ============================================
-- 通用编辑器行为配置
-- ============================================

-- 配置换行行为
-- 功能: 用 o 换行时不延续注释，但保留 r (回车键延续注释)
vim.api.nvim_create_autocmd("BufEnter", {
  group = my_group,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - "o" + "r"
  end,
})

-- 配置复制高亮
-- 功能: 复制文本后高亮显示选中的区域，提高可视性
vim.api.nvim_create_autocmd("TextYankPost", {
  group = my_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- 配置光标位置恢复
-- 功能: 打开文件时恢复到上次编辑的位置
-- 排除: commit 信息文件、xxd 二进制查看、gitrebase 编辑
vim.api.nvim_create_autocmd("BufReadPost", {
  group = my_group,
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    local filetype = vim.bo.filetype
    if
      line > 1
      and line <= vim.fn.line("$")
      and filetype ~= "commit"
      and not filetype:match("xxd")
      and not filetype:match("gitrebase")
    then
      vim.cmd('normal! g`"')
    end
  end,
})

-- ============================================
-- 窗口类型检测系统
-- ============================================

-- 通用窗口信息获取函数
-- 功能: 获取窗口和对应的缓冲区信息，处理有效性检查
-- 参数: win - 窗口 ID (可选，默认当前窗口)
-- 返回: 包含 buf, buftype, filetype, buf_name 的表，或 nil
local function get_window_buffer_info(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return nil
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end
  return {
    buf = buf,
    buftype = vim.bo[buf].buftype,
    filetype = vim.bo[buf].filetype,
    buf_name = vim.api.nvim_buf_get_name(buf),
  }
end

-- 窗口类型检测函数集合

-- 判断是否是终端窗口
-- 通过缓冲区类型或名称前缀检测
local function is_terminal_window(win)
  local info = get_window_buffer_info(win)
  return info and (info.buftype == "terminal" or info.buf_name:match("^term://"))
end

-- 判断是否是 Snacks.nvim 插件窗口
-- 通过文件类型前缀检测
local function is_snacks_window(win)
  local info = get_window_buffer_info(win)
  return info and info.filetype:match("^snacks_") ~= nil
end

-- 判断是否是 Avante 插件窗口
-- 通过文件类型前缀检测
local function is_avante_window(win)
  local info = get_window_buffer_info(win)
  return info and info.filetype:match("^Avante") ~= nil
end

-- 判断是否是 Grug Far 搜索工具窗口
-- 通过文件名或文件类型匹配检测
local function is_grugfar_window(win)
  local info = get_window_buffer_info(win)
  return info and (info.buf_name:match("grug%-far") ~= nil or info.filetype:match("grug%-far") ~= nil)
end

-- 判断是否是 Oil.nvim 文件浏览器窗口
-- 通过文件类型或缓冲区名称前缀检测
local function is_oil_window(win)
  local info = get_window_buffer_info(win)
  return info and (info.filetype == "oil" or info.buf_name:match("^oil://"))
end

-- 判断是否是 Lazy.nvim 插件管理器窗口
-- 只通过文件类型检测，避免匹配文件名包含 lazy 的普通文件（如 lazy.lua）
local function is_lazy_window(win)
  local info = get_window_buffer_info(win)
  return info and info.filetype == "lazy"
end

-- 判断是否是 Mason 插件管理器窗口
-- 只通过文件类型检测，避免匹配文件名包含 mason 的普通文件（如 mason.lua）
local function is_mason_window(win)
  local info = get_window_buffer_info(win)
  return info and info.filetype == "mason"
end

-- ============================================
-- 窗口选项管理
-- ============================================

-- 终端窗口选项配置
-- 功能: 为终端窗口设置特定选项 (隐藏行号、折叠栏等)
local function set_terminal_window_options(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local opts = {
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
  }
  for opt, value in pairs(opts) do
    vim.wo[win][opt] = value
  end
end

-- 普通窗口选项配置
-- 功能: 为普通编辑器窗口设置默认选项 (显示行号、折叠栏等)
local function set_normal_window_options(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local opts = {
    number = true,
    relativenumber = true,
    signcolumn = "yes",
    foldcolumn = "0",
  }
  for opt, value in pairs(opts) do
    vim.wo[win][opt] = value
  end
end

-- ============================================
-- 窗口状态管理
-- ============================================

-- 检查并更新所有可见窗口状态
-- 功能: 遍历所有有效窗口，根据窗口类型设置对应的选项
local function check_all_visible_windows()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local info = get_window_buffer_info(win)
      local is_preview = info and info.filetype == "snacks_picker_preview"

      if is_preview then
        -- 预览窗口应该显示行号
        local opts = {
          number = true,
          relativenumber = false,
          signcolumn = "yes",
          foldcolumn = "0",
        }
        for opt, value in pairs(opts) do
          vim.wo[win][opt] = value
        end
      elseif
        is_terminal_window(win)
        or is_snacks_window(win)
        or is_avante_window(win)
        or is_grugfar_window(win)
        or is_oil_window(win)
        or is_lazy_window(win)
        or is_mason_window(win)
      then
        set_terminal_window_options(win)
      else
        set_normal_window_options(win)
      end
    end
  end
end

-- 异步检查窗口状态
-- 功能: 使用 vim.schedule 异步执行窗口检查，避免阻塞
local function check_all_visible_windows_async()
  vim.schedule(check_all_visible_windows)
end

-- ============================================
-- 终端窗口自动命令
-- ============================================

-- 终端窗口创建和进入
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = terminal_group,
  pattern = "term://*",
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
    vim.bo.buftype = "terminal"
  end,
})

-- 终端窗口关闭
vim.api.nvim_create_autocmd("TermClose", {
  group = terminal_group,
  pattern = "term://*",
  callback = check_all_visible_windows_async,
})

-- 窗口进入时设置选项
vim.api.nvim_create_autocmd("WinEnter", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if
      is_terminal_window(win)
      or is_snacks_window(win)
      or is_avante_window(win)
      or is_grugfar_window(win)
      or is_oil_window(win)
      or is_lazy_window(win)
      or is_mason_window(win)
    then
      set_terminal_window_options(win)
    else
      set_normal_window_options(win)
    end
  end,
})

-- Buffer 进入时检查窗口状态
vim.api.nvim_create_autocmd("BufEnter", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if not is_terminal_window(win) then
      check_all_visible_windows_async()
    end
  end,
})

-- 窗口调整大小时更新
vim.api.nvim_create_autocmd("VimResized", {
  group = terminal_group,
  pattern = "*",
  callback = check_all_visible_windows_async,
})

-- ============================================
-- 插件窗口配置
-- ============================================

-- Snacks.nvim 插件窗口配置
vim.api.nvim_create_autocmd("FileType", {
  group = snacks_group,
  pattern = { "snacks_*" },
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local info = get_window_buffer_info(win)

    -- 对于预览窗口，保持行号显示；其他 snacks 窗口隐藏行号
    if info and info.filetype == "snacks_picker_preview" then
      -- 预览窗口应该显示行号，所以不设置终端选项
      local opts = {
        number = true, -- 显示行号
        relativenumber = false, -- 不显示相对行号
        signcolumn = "yes",
        foldcolumn = "0",
      }
      for opt, value in pairs(opts) do
        vim.wo[win][opt] = value
      end
    else
      -- 其他 snacks 窗口继续使用终端选项
      set_terminal_window_options(win)
    end
  end,
})

-- Avante 插件窗口配置
vim.api.nvim_create_autocmd("FileType", {
  group = avante_group,
  pattern = { "Avante*" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- Grug Far 搜索工具窗口配置
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = grugfar_group,
  pattern = { "*grug*-*far*" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- Oil.nvim 文件浏览器窗口配置
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = oil_group,
  pattern = { "oil" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- Lazy.nvim 插件管理器窗口配置
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = lazy_group,
  pattern = { "lazy" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- Mason 插件管理器窗口配置
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = mason_group,
  pattern = { "mason" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- ============================================
-- 文件处理优化
-- ============================================

-- 大文件检测和优化
-- 功能: 检测大于 100KB 的文件，禁用自动折叠和拼写检查
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  group = large_buf_group,
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local ok, stats = pcall(vim.loop.fs_stat, bufname)
    local large_file_size = 100 * 1024 -- 100 KB

    if ok and stats and stats.size > large_file_size then
      vim.b.large_buf = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
    else
      vim.b.large_buf = false
    end
  end,
})

-- ============================================
-- 拼写检查配置
-- ============================================

-- 禁用 Markdown 文件拼写检查
vim.api.nvim_create_autocmd("FileType", {
  group = my_group,
  pattern = { "markdown" },
  callback = function()
    vim.opt.spell = false
  end,
})

-- 配置特定文件类型的拼写语言
-- 支持: 英语、中日韩语
vim.api.nvim_create_autocmd("FileType", {
  group = my_group,
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.opt.spelllang = { "en", "cjk" }
  end,
})

