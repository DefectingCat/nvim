local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt", "goimports" },
    -- biome/prettier 智能选择
    javascript = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    typescript = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    javascriptreact = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    typescriptreact = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    json = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    css = function()
      if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
        return { "prettier" }
      end
      return { "biome-check", "biome", stop_after_first = true }
    end,
    html = { "prettier" },
    markdown = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
