-- 禁用 markdownlint-cli2 诊断
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      markdown = {}, -- 清空 markdown 文件类型的 linter 配置
    },
  },
}

