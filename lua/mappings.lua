require "nvchad.mappings"

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

-- search
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- general
map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")

-- telescope
map("n", "<leader>ft", function()
  local filetypes = vim.fn.getcompletion("", "filetype")
  require("telescope.pickers").new({}, {
    prompt_title = "Filetypes",
    finder = require("telescope.finders").new_table {
      results = filetypes,
    },
    sorter = require("telescope.config").values.generic_sorter {},
    attach_mappings = function(prompt_bufnr, map)
      require("telescope.actions").select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if selection then
          vim.bo.filetype = selection[1]
        end
      end)
      return true
    end,
  }):find()
end, { desc = "Telescope change filetype" })
