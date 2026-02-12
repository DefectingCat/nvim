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
  local autocmd = vim.api.nvim_create_autocmd
  autocmd({ "BufNewFile", "BufRead" }, {
    pattern = patterns,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      -- vim.api.nvim_buf_set_option(buf, "filetype", filetype)
      vim.bo[buf].filetype = filetype
    end,
  })
end

-- 设置 markdown 高亮用于 mdx 文件
set_filetype({ "*.mdx" }, "markdown")

-- 设置 env 文件为 sh 类型
set_filetype({ ".env.example", ".env.local", ".env.development", ".env.production" }, "sh")

-- 设置 json 文件夹为 jsonc 类型
set_filetype({ "*.json" }, "jsonc")

local autocmd = vim.api.nvim_create_autocmd

-- 用 o 换行不要延续注释
local ruaGroup = vim.api.nvim_create_augroup("myAutoGroup", {
  clear = true,
})
autocmd("BufEnter", {
  group = ruaGroup,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
      - "o" -- O 和 o，不延续注释
      + "r" -- 按回车键时延续注释
  end,
})

-- 复制文本后高亮显示
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- 恢复光标位置
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    local filetype = vim.bo.filetype
    if
      line > 1
      and line <= vim.fn.line("$")
      and filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, filetype) == -1
    then
      vim.cmd('normal! g`"')
    end
  end,
})

-- 函数：获取窗口栏路径
local function get_winbar_path()
  return vim.fn.expand("%:.")
end

-- 函数：获取主机名，添加错误日志
local function get_hostname()
  local hostname = vim.fn.systemlist("hostname")
  if #hostname > 0 then
    return hostname[1]
  else
    vim.notify("Failed to get hostname", vim.log.levels.ERROR)
    return "unknown"
  end
end

-- 函数：更新指定缓冲区的窗口栏
local function update_winbar(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local old_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_buf(bufnr)
  local home_replaced = get_winbar_path()
  if home_replaced == "" then
    return
  end
  -- local buffer_count = get_buffer_count()
  local ft = vim.bo.filetype
  local hostname = get_hostname()
  local winbar

  if ft == "NvimTree" then
    winbar = "RUA"
  else
    local winbar_prefix = "%#WinBar1#%m "
    local winbar_suffix = "%*%=%#WinBar2#" .. hostname
    winbar = winbar_prefix .. "%#WinBar1#" .. home_replaced .. winbar_suffix
  end

  -- vim.opt.winbar = winbar
  -- 检查缓冲区是否支持设置 winbar
  if vim.api.nvim_buf_is_valid(bufnr) then
    -- vim.bo[bufnr].winbar = winbar
    vim.api.nvim_buf_set_option(bufnr, "winbar", winbar)
  end
  -- 检查 old_buf 是否有效
  if vim.api.nvim_buf_is_valid(old_buf) then
    vim.api.nvim_set_current_buf(old_buf)
  end
end

-- 自动命令：在 BufEnter 和 WinEnter 事件时更新窗口栏
autocmd({ "BufEnter", "WinEnter" }, {
  callback = function(args)
    update_winbar(args.buf)
  end,
})

-- 启动时更新所有现有缓冲区的窗口栏
local all_buffers = vim.api.nvim_list_bufs()
for _, buf in ipairs(all_buffers) do
  if vim.api.nvim_buf_is_valid(buf) then
    update_winbar(buf)
  end
end

-- 判断窗口是否是终端窗口
local function is_terminal_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local buf_type = vim.bo[buf].buftype
  local buf_name = vim.api.nvim_buf_get_name(buf)
  return buf_type == "terminal" or buf_name:match("^term://")
end

-- 判断窗口是否是 Snacks 窗口
local function is_snacks_window(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local filetype = vim.bo[buf].filetype
  return filetype:match("^snacks_") ~= nil
end

-- 设置终端窗口选项（隐藏行号）
local function set_terminal_window_options(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
end

-- 设置普通窗口选项（显示行号）
local function set_normal_window_options(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  vim.wo[win].number = true
  vim.wo[win].relativenumber = true
  vim.wo[win].signcolumn = "yes"
  vim.wo[win].foldcolumn = "0"
end

-- 检查并设置所有可见窗口的状态
local function check_all_visible_windows()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      if is_terminal_window(win) or is_snacks_window(win) then
        set_terminal_window_options(win)
      else
        set_normal_window_options(win)
      end
    end
  end
end

-- 使用异步执行防止闪烁（可选）
local function check_all_visible_windows_async()
  vim.schedule(function()
    check_all_visible_windows()
  end)
end

-- 终端配置自动命令组
local terminal_group = vim.api.nvim_create_augroup("TerminalConfig", { clear = true })

-- 进入终端时设置终端选项（隐藏行号）
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = terminal_group,
  pattern = "term://*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    set_terminal_window_options(win)
    -- 同时设置缓冲区的本地选项作为默认值
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "terminal"
  end,
})

-- 当终端关闭时，检查所有可见窗口的状态
vim.api.nvim_create_autocmd("TermClose", {
  group = terminal_group,
  pattern = "term://*",
  callback = function()
    check_all_visible_windows()
  end,
})

-- 当窗口进入时，根据显示的内容设置对应的选项
vim.api.nvim_create_autocmd("WinEnter", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if is_terminal_window(win) or is_snacks_window(win) then
      set_terminal_window_options(win)
    else
      set_normal_window_options(win)
    end
  end,
})

-- 当切换 buffer 时，检查所有可见窗口的状态
vim.api.nvim_create_autocmd("BufEnter", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    -- 如果进入的不是终端 buffer，则检查所有可见窗口的状态
    local win = vim.api.nvim_get_current_win()
    if not is_terminal_window(win) then
      check_all_visible_windows()
    end
  end,
})

-- 窗口调整大小时，确保所有终端窗口的状态正确
vim.api.nvim_create_autocmd("VimResized", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    check_all_visible_windows()
  end,
})

-- Snacks 配置自动命令组
local snacks_group = vim.api.nvim_create_augroup("SnacksConfig", { clear = true })

-- 为 Snacks 相关窗口隐藏行号
vim.api.nvim_create_autocmd("FileType", {
  group = snacks_group,
  pattern = { "snacks_*" },
  callback = function()
    local win = vim.api.nvim_get_current_win()
    set_terminal_window_options(win)
  end,
})

-- 大文件检测
local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })
autocmd({ "BufReadPre" }, {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
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
  group = aug,
  pattern = "*",
})

-- 拼写检查导致的问题
vim.api.nvim_create_autocmd("FileType", {
  group = ruaGroup,
  pattern = { "markdown" },
  callback = function()
    vim.opt.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ruaGroup,
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.opt.spelllang = { "en", "cjk" }
  end,
})
