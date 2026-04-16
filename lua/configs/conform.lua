local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofumpt", "goimports" },
    -- biome/prettier 智能选择：默认 prettier，有 biome 配置时使用 biome
    javascript = function()
      if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "biome-check", "biome", stop_after_first = true }
      end
      return { "prettier" }
    end,
    typescript = function()
      if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "biome-check", "biome", stop_after_first = true }
      end
      return { "prettier" }
    end,
    javascriptreact = function()
      if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "biome-check", "biome", stop_after_first = true }
      end
      return { "prettier" }
    end,
    typescriptreact = function()
      if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "biome-check", "biome", stop_after_first = true }
      end
      return { "prettier" }
    end,
    json = function()
      if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "biome-check", "biome", stop_after_first = true }
      end
      return { "prettier" }
    end,
    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
  },

  format_on_save = function(bufnr)
    -- 检查格式化开关：buffer 局部优先，然后是全局
    local buf_autoformat = vim.b[bufnr].autoformat
    if buf_autoformat == false then
      return nil -- buffer 局部禁用
    end
    if vim.g.autoformat == false then
      return nil -- 全局禁用
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

return options
