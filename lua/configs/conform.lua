local function biome_or_prettier()
  if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, stop = vim.uv.os_homedir() })[1] then
    return { "biome-check", "biome", stop_after_first = true }
  end
  return { "prettier" }
end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofumpt", "goimports" },
    javascript = biome_or_prettier,
    typescript = biome_or_prettier,
    javascriptreact = biome_or_prettier,
    typescriptreact = biome_or_prettier,
    json = biome_or_prettier,
    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
    toml = { "taplo" },
  },

  format_on_save = function(bufnr)
    local buf_autoformat = vim.b[bufnr].autoformat
    if buf_autoformat == false then
      return nil
    end
    if vim.g.autoformat == false then
      return nil
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

return options
