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

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
