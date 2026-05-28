local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- 恢复上次编辑位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local row = mark[1]
    local ft = vim.bo.filetype

    if row > 1 and row <= vim.fn.line("$") then
      if ft ~= "commit" and ft ~= "gitcommit" and not ft:match("xxd") and not ft:match("gitrebase") then
        vim.api.nvim_win_set_cursor(0, mark)
      end
    end
  end,
})

-- 注释延续行为
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function()
    vim.opt_local.formatoptions:remove("o") -- o/O 换行不延续注释
    vim.opt_local.formatoptions:append("r") -- 回车延续注释
  end,
})

-- 延迟设置 Treesitter 折叠（避免启动时加载 treesitter 模块）
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  once = true,
  callback = function()
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
