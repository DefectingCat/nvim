vim.g.mapleader = " "

local map = vim.keymap.set

map("x", "p", [["_dP]], { desc = "Paste over selection without losing yanked text" })
-- map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

map("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

map("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word cursor is on globally" })
-- search
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

-- mini.pick buffer picker (telescope buffers equivalent)
map("n", "<leader><leader>", function()
    local MiniPick = require("mini.pick")

    local delete_buf = function()
        local matches = MiniPick.get_picker_matches()
        local item = matches and matches.current
        if not item or not item.bufnr then return end
        local bufnr = item.bufnr

        -- 先删除 buffer（pcall 保护，避免删除当前窗口 buffer 时出错）
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

        -- 刷新列表：只保留仍然有效的 buffer
        if MiniPick.is_picker_active() then
            local items = vim.tbl_filter(function(i)
                return i.bufnr and vim.api.nvim_buf_is_valid(i.bufnr)
            end, MiniPick.get_picker_items() or {})
            MiniPick.set_picker_items(items)
        end
    end

    -- 收集所有 buffer，过滤特殊类型和未列出的，按最近使用排序
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b.bufnr].buftype == "" and b.listed == 1
    end, vim.fn.getbufinfo())
    table.sort(bufs, function(a, b)
        return a.lastused > b.lastused
    end)

    local items = {}
    for _, info in ipairs(bufs) do
        local name = info.name ~= "" and vim.fn.fnamemodify(info.name, ":.") or "[No Name]"
        table.insert(items, {
            text = name,
            bufnr = info.bufnr,
        })
    end

    MiniPick.start({
        source = {
            name = "Buffers",
            items = items,
            show = function(buf_id, items_arr, query)
                MiniPick.default_show(buf_id, items_arr, query, { show_icons = true })
            end,
        },
        mappings = {
            delete_buffer = { char = "<C-d>", func = delete_buf },
        },
    })
end, { desc = "Buffers" })

-- mini.pick filetype picker
map("n", "<leader>ft", function()
    local MiniPick = require("mini.pick")
    local filetypes = vim.fn.getcompletion("", "filetype")
    MiniPick.start({
        source = {
            name = "Filetypes",
            items = filetypes,
            choose = function(item)
                vim.bo.filetype = item
            end,
        },
    })
end, { desc = "Change filetype" })
