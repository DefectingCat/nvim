-- Temporarily intercept vim.keymap.set to skip NvChad's <C-n> binding
local original_keymap_set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  if lhs == "<C-n>" then
    return
  end
  return original_keymap_set(mode, lhs, rhs, opts)
end
require("nvchad.mappings")
vim.keymap.set = original_keymap_set

-- disable default mappings
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  once = true,
  callback = function()
    pcall(vim.keymap.del, "n", "<leader>b")
  end,
})

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("t", "<C-x>", "<c-\\><c-n>", { desc = "Escape termainl" })
map("n", "<leader>tt", ":term<CR>", { desc = "Open new terminal" })

-- tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>]", ":tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>[", ":tabprevious<CR>", { desc = "Previous tab" })

-- lsp
map("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- search
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- general
map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")

-- nvimtree: override NvChad defaults (use <leader>e for toggle)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- telescope
-- telescope git status (override NvChad default with normal mode)
map("n", "<leader>gt", function()
  require("telescope.builtin").git_status({ initial_mode = "normal" })
end, { desc = "Telescope git status" })
map("n", "<leader>gl", function()
  require("telescope.builtin").git_commits({ initial_mode = "normal" })
end, { desc = "Git log" })
map("n", "<leader>gf", function()
  require("telescope.builtin").git_bcommits({ initial_mode = "normal" })
end, { desc = "Git file history" })

map("n", "<leader>ft", function()
  local filetypes = vim.fn.getcompletion("", "filetype")
  require("telescope.pickers")
    .new({}, {
      prompt_title = "Filetypes",
      finder = require("telescope.finders").new_table({
        results = filetypes,
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        require("telescope.actions").select_default:replace(function()
          local selection = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(prompt_bufnr)
          if selection then
            vim.bo.filetype = selection[1]
          end
        end)
        return true
      end,
    })
    :find()
end, { desc = "Telescope change filetype" })

map("n", "<leader>fr", function()
  require("telescope.builtin").resume()
end, { desc = "Telescope resume last search" })

-- format toggle
map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle auto format (global)" })

map("n", "<leader>uF", function()
  vim.b.autoformat = not vim.b.autoformat
  local status = vim.b.autoformat
  if status == nil then
    status = vim.g.autoformat
  end
  vim.notify("Buffer autoformat " .. (status and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle auto format (buffer)" })

-- buffer
map("n", "<leader>x", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    vim.ui.select({ "Yes", "No" }, {
      prompt = "Buffer has unsaved changes. Close without saving?",
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if choice == "Yes" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  else
    vim.cmd.bdelete()
  end
end, { desc = "Close current buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "Buffer new" })
map("n", "<leader><leader>", function()
  require("telescope.builtin").buffers({
    initial_mode = "normal",
    show_all_buffers = true,
    ignore_current_buffer = false,
    sort_lastused = true,
    attach_mappings = function(_, map_inner)
      local actions = require("telescope.actions")
      map_inner("n", "d", actions.delete_buffer)
      return true
    end,
  })
end, { desc = "Buffers" })

map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  local skipped_ft = { "NvimTree", "oil", "aerial" }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if not vim.tbl_contains(skipped_ft, ft) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end, { desc = "Close other buffers" })
