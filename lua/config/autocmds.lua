-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 加载用户命令
require("config.usercmd")

-- 封装设置文件类型的函数
local function set_filetype(patterns, filetype)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = patterns,
    callback = function(args)
      vim.bo[args.buf].filetype = filetype
    end,
  })
end

-- 设置文件类型关联
set_filetype({ "*.mdx" }, "markdown")
set_filetype({ ".env.example", ".env.local", ".env.development", ".env.production" }, "sh")
set_filetype({ "*.json" }, "jsonc")

-- 创建自动命令组
local my_group = vim.api.nvim_create_augroup("MyAutoGroup", { clear = true })
local terminal_group = vim.api.nvim_create_augroup("TerminalConfig", { clear = true })
local snacks_group = vim.api.nvim_create_augroup("SnacksConfig", { clear = true })
local avante_group = vim.api.nvim_create_augroup("AvanteConfig", { clear = true })
local grugfar_group = vim.api.nvim_create_augroup("GrugFarConfig", { clear = true })
local oil_group = vim.api.nvim_create_augroup("OilConfig", { clear = true })
local large_buf_group = vim.api.nvim_create_augroup("LargeBufferConfig", { clear = true })

-- 用 o 换行不要延续注释
vim.api.nvim_create_autocmd("BufEnter", {
  group = my_group,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - "o" + "r"
  end,
})

-- 复制文本后高亮显示
vim.api.nvim_create_autocmd("TextYankPost", {
  group = my_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- 恢复光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = my_group,
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    local filetype = vim.bo.filetype
    if line > 1 and line <= vim.fn.line("$") and filetype ~= "commit" and not filetype:match("xxd") and not filetype:match("gitrebase") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- 窗口类型检测函数
local function is_terminal_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  return vim.bo[buf].buftype == "terminal" or vim.api.nvim_buf_get_name(buf):match("^term://")
end

local function is_snacks_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  return vim.bo[buf].filetype:match("^snacks_") ~= nil
end

local function is_avante_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  return vim.bo[buf].filetype:match("^Avante") ~= nil
end

local function is_grugfar_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local filetype = vim.bo[buf].filetype
  return buf_name:match("grug%-far") ~= nil or filetype:match("grug%-far") ~= nil
end

local function is_oil_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local filetype = vim.bo[buf].filetype
  local buf_name = vim.api.nvim_buf_get_name(buf)
  return filetype == "oil" or buf_name:match("^oil://") ~= nil
end

-- 窗口选项设置函数
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

-- 检查并设置所有可见窗口的状态
local function check_all_visible_windows()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      if is_terminal_window(win) or is_snacks_window(win) or is_avante_window(win) or is_grugfar_window(win) or is_oil_window(win) then
        set_terminal_window_options(win)
      else
        set_normal_window_options(win)
      end
    end
  end
end

-- 异步检查窗口状态
local function check_all_visible_windows_async()
  vim.schedule(check_all_visible_windows)
end

-- 终端配置自动命令
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = terminal_group,
  pattern = "term://*",
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
    vim.bo.buftype = "terminal"
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = terminal_group,
  pattern = "term://*",
  callback = check_all_visible_windows_async,
})

vim.api.nvim_create_autocmd("WinEnter", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if is_terminal_window(win) or is_snacks_window(win) or is_avante_window(win) or is_grugfar_window(win) or is_oil_window(win) then
      set_terminal_window_options(win)
    else
      set_normal_window_options(win)
    end
  end,
})

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

vim.api.nvim_create_autocmd("VimResized", {
  group = terminal_group,
  pattern = "*",
  callback = check_all_visible_windows_async,
})

-- 其他插件窗口配置
vim.api.nvim_create_autocmd("FileType", {
  group = snacks_group,
  pattern = { "snacks_*" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = avante_group,
  pattern = { "Avante*" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = grugfar_group,
  pattern = { "*grug*-*far*" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  group = oil_group,
  pattern = { "oil" },
  callback = function()
    set_terminal_window_options(vim.api.nvim_get_current_win())
  end,
})

-- 大文件检测
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

-- 拼写检查配置
vim.api.nvim_create_autocmd("FileType", {
  group = my_group,
  pattern = { "markdown" },
  callback = function()
    vim.opt.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = my_group,
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.opt.spelllang = { "en", "cjk" }
  end,
})