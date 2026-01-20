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
local myAutoGroup = vim.api.nvim_create_augroup("myAutoGroup", {
  clear = true,
})
autocmd("BufEnter", {
  group = myAutoGroup,
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
