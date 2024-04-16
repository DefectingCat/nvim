local map = vim.keymap.set
local rust_config = require("configs.rust_config")

vim.g.rustaceanvim = function()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("codelldb")
  local extension_path = codelldb:get_install_path() .. "/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = ""

  if vim.loop.os_uname().sysname:find("Windows") then
    liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
  elseif vim.fn.has("mac") == 1 then
    liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
  else
    liblldb_path = extension_path .. "lldb/lib/liblldb.so"
  end

  -- keymap
  local bufnr = vim.api.nvim_get_current_buf()
  map({ "n", "v" }, "<leader>ca", function()
    vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
    --[[ vim.lsp.buf.code_action() ]]
  end, { silent = true, buffer = bufnr }, "Lsp Code action")
  --[[ map("n", "[d", vim.diagnostic.goto_prev, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "]d", vim.diagnostic.goto_next, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "gD", vim.lsp.buf.declaration, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "gd", vim.lsp.buf.definition, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "gi", vim.lsp.buf.implementation, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "gr", vim.lsp.buf.references, { silent = false, buffer = bufnr }) ]]
  --[[ map("n", "<leader>D", vim.lsp.buf.type_definition, { silent = false, buffer = bufnr }) ]]
  map("n", "gd", "<CMD>Telescope lsp_definitions<CR>", { silent = false, buffer = bufnr })
  map("n", "gr", "<CMD>Telescope lsp_references<CR>", { silent = false, buffer = bufnr })

  local cfg = require("rustaceanvim.config")
  return {
    tools = {},
    server = rust_config,
    dap = {
      adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
    },
  }
end
