local autocmd = vim.api.nvim_create_autocmd
-- local augroup = vim.api.nvim_create_augroup

-- set markdown highlight for mdx file
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.mdx" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  end,
})

-- set env files to sh
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { ".env.example", ".env.local", ".env.development", ".env.production" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "sh")
  end,
})

-- remove relative line number when open terminal
autocmd({ "TermOpen" }, {
  callback = function()
    vim.api.nvim_buf_set_option(0, "relativenumber", false)
    vim.api.nvim_buf_set_option(0, "number", false)
  end,
})

-- Automatically update changed file in Vim
-- Triger `autoread` when files changes on disk
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
-- autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
--   command = [[silent! if mode() != 'c' && !bufexists("[Command Line]") | checktime | endif]],
-- })

-- Notification after file change
-- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd("FileChangedShellPost", {
  command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
})

---- 用o换行不要延续注释
local myAutoGroup = vim.api.nvim_create_augroup("myAutoGroup", {
  clear = true,
})
autocmd("BufEnter", {
  group = myAutoGroup,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
      - "o" -- O and o, don't continue comments
      + "r" -- But do continue when pressing enter.
  end,
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- This autocmd will restore cursor position on file open
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if
      line > 1
      and line <= vim.fn.line("$")
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  local relative_filepath = vim.fn.expand("%:.")
  return relative_filepath
end
-- Function to get the number of open buffers using vim.fn.getbufinfo()
local function get_buffer_count()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  return #buffers
end
-- Function to get the hostname with error handling
local function get_hostname()
  local hostname = vim.fn.systemlist("hostname")
  if #hostname > 0 then
    return hostname[1]
  else
    return "unknown"
  end
end
-- Using different colors, defining the colors in this file
-- local colors = require("config.colors").load_colors()
-- vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
-- vim.cmd(string.format([[highlight WinBar2 guifg=%s]], colors["linkarzu_color02"]))
-- Function to update the winbar
local function update_winbar()
  local home_replaced = get_winbar_path()
  local buffer_count = get_buffer_count()
  local ft = vim.bo.filetype
  local hostname = get_hostname()
  if ft == "NvimTree" then
    vim.opt.winbar = "RUA"
    return
  else
    local winbar_prefix = "%#WinBar1#%m "
    local buffer_count_str = "%#WinBar2#(" .. buffer_count .. ") "
    local winbar_suffix = "%*%=%#WinBar2#" .. hostname
    vim.opt.winbar = winbar_prefix .. buffer_count_str .. "%#WinBar1#" .. home_replaced .. winbar_suffix
  end
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = update_winbar,
})

-- large file detection
local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  callback = function()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
    -- 100 KB
    if ok and stats and (stats.size > 100 * 1024) then
      vim.b.large_buf = true
      -- vim.cmd("syntax off")
      -- vim.cmd("IlluminatePauseBuf") -- disable vim-illuminate
      -- vim.cmd("IndentBlanklineDisable") -- disable indent-blankline.nvim
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
    else
      vim.b.large_buf = false
    end
  end,
  group = aug,
  pattern = "*",
})
