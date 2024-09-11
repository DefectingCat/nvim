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
