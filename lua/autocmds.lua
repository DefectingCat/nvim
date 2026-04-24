require("nvchad.autocmds")

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

-- winbar 显示相对路径
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TermOpen", "BufModifiedSet", "BufWritePost", "BufFilePost" }, {
  group = group,
  callback = function()
    -- 浮动窗口、nofile 类型不显示 winbar
    local win_config = vim.api.nvim_win_get_config(0)
    if (win_config.relative and win_config.relative ~= "") or vim.bo.buftype == "nofile" then
      vim.opt_local.winbar = ""
      return
    end

    -- 特殊 filetype 不显示 winbar
    if vim.tbl_contains({ "NvimTree", "oil", "aerial", "TelescopePrompt", "qf" }, vim.bo.filetype) then
      vim.opt_local.winbar = ""
      return
    end

    -- 设置 winbar
    local path = vim.fn.expand("%:~:.") or "[No Name]"
    if path == "" and vim.bo.buftype == "terminal" then
      path = vim.b.term_title or "[Terminal]"
    end
    vim.opt_local.winbar = path .. (vim.bo.modified and " [+]" or "")
  end,
})
