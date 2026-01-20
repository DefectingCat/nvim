local user_command = vim.api.nvim_create_user_command

-- 定义 Difft 命令
user_command("Difft", function()
  vim.cmd("windo diffthis")
end, {
  desc = "windo Diffthis",
})

-- 定义 Diffo 命令
user_command("Diffo", function()
  vim.cmd("windo diffoff")
end, {
  desc = "windo Diffoff",
})

-- 定义 CPRelative 命令：复制当前缓冲区文件的相对路径
user_command("CPRelative", function()
  local absolute_path = vim.api.nvim_buf_get_name(0)
  local relative_path = vim.fn.fnamemodify(absolute_path, ":~:.")
  vim.fn.setreg("+", relative_path)
  vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
end, {
  desc = "Copy current buffer file relative path to clipboard",
})

-- 定义 CPAbsolute 命令：复制当前缓冲区文件的绝对路径
user_command("CPAbsolute", function()
  local absolute_path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg("+", absolute_path)
  vim.notify("Copied absolute path: " .. absolute_path, vim.log.levels.INFO)
end, {
  desc = "Copy current buffer file absolute path to clipboard",
})
