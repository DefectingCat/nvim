vim.g.mapleader = " "

local map = vim.keymap.set

map("x", "p", [[_dP]], { desc = "Paste over selection without losing yanked text" })

map("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

map("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word cursor is on globally" })
map("v", "<leader>ss", ":s/\\%V", { desc = "Search and replace in visual selection" })

-- general
map("n", "$", "g_")
map("v", "$", "g_")
map("v", ">", ">gv")
map("v", "<", "<gv")

-- native undotree
vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle Builtin Undotree" })

map("t", "<C-x>", "<c-\\><c-n>", { desc = "Escape termainl" })
map("n", "<leader>tt", ":term<CR>", { desc = "Open new terminal" })

-- tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>]", ":tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>[", ":tabprevious<CR>", { desc = "Previous tab" })

-- yank path
map("n", "<leader>yp", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify("Copied relative path: " .. path, vim.log.levels.INFO)
end, { desc = "Yank relative file path" })

map("n", "<leader>yP", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify("Copied absolute path: " .. path, vim.log.levels.INFO)
end, { desc = "Yank absolute file path" })

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
