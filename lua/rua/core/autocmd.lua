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

-- This add the bar that shows the file path on the top right
-- vim.opt.winbar = "%=%m %f"
--
-- Modified version of the bar, shows pathname on right, hostname left
-- vim.opt.winbar = "%=" .. vim.fn.systemlist("hostname")[1] .. "            %m %f"
--
-- This shows pathname on the left and hostname on the right
-- vim.opt.winbar = "%m %f%=" .. vim.fn.systemlist("hostname")[1]
--
-- Using different colors, defining the colors in this file
-- local colors = require("config.colors").load_colors()
-- vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
-- vim.cmd(string.format([[highlight WinBar2 guifg=%s]], colors["linkarzu_color02"]))
-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  -- local filename = vim.fn.expand("%:t")
  -- local absolute_filepath = vim.fn.expand("%:p")
  local relative_filepath = vim.fn.expand("%:.")
  -- local full_path = vim.fn.expand("%:p")
  -- return full_path:gsub(vim.fn.expand("$HOME"), "~")
  return relative_filepath
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
  local buffers = vim.fn.execute("ls")
  local count = 0
  -- Match only lines that represent buffers, typically starting with a number followed by a space
  for line in string.gmatch(buffers, "[^\r\n]+") do
    if string.match(line, "^%s*%d+") then
      count = count + 1
    end
  end
  return count
end
-- Function to update the winbar
local function update_winbar()
  local home_replaced = get_winbar_path()
  local buffer_count = get_buffer_count()
  local ft = vim.bo.filetype
  if ft == "NvimTree" then
    return
  else
    vim.opt.winbar = "%#WinBar1#%m "
      .. "%#WinBar2#("
      .. buffer_count
      .. ") "
      .. "%#WinBar1#"
      .. home_replaced
      .. "%*%=%#WinBar2#"
      .. vim.fn.systemlist("hostname")[1]
  end
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = update_winbar,
})
