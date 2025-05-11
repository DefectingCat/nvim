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
