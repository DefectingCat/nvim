local lazy = require("lazy")

vim.pack.add({
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/rafamadriz/friendly-snippets",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/tpope/vim-fugitive",
})

-- mini.files - 按键触发
lazy.on_keys("files", "<leader>-", "n", function()
    require("mini.files").setup({
        mappings = {
            go_in = "<CR>",
            go_in_plus = "L",
            go_out = "_",
            go_out_plus = "H",
        },
    })
end, function()
    require("mini.files").open()
end, { desc = "Toggle mini file explorer" })

lazy.on_keys("files", "-", "n", function()
    require("mini.files").setup({
        mappings = {
            go_in = "<CR>",
            go_in_plus = "L",
            go_out = "_",
            go_out_plus = "H",
        },
    })
end, function()
    local MiniFiles = require("mini.files")
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" })

-- mini.notify - 启动时加载
lazy.load("notify", function()
    require("mini.notify").setup({
        content = {
            format = function(notif)
                return notif.msg
            end,
        },
    })
end)

-- mini.cmdline - 启动时加载
lazy.load("cmdline", function()
    require("mini.cmdline").setup({
        autocorrect = { enable = false },
    })
end)

-- mini.surround - BufReadPost
lazy.on_event("surround", "BufReadPost", "*", function()
    require("mini.surround").setup()
end)

-- mini.pick + mini.extra - 按键触发
local load_pick = function()
    lazy.load("pick", function()
        require("mini.pick").setup()
    end)
    lazy.load("extra", function()
        require("mini.extra").setup()
    end)
end

lazy.on_keys("pick", "<leader>ff", "n", load_pick, function()
    require("mini.pick").builtin.files()
end, { desc = "Mini File Picker" })

lazy.on_keys("pick", "<leader>fw", "n", load_pick, function()
    require("mini.pick").builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word/Search word" })

lazy.on_keys("pick", "<leader>vh", "n", load_pick, function()
    require("mini.pick").builtin.help()
end, { desc = "Mini Help" })

lazy.on_keys("pick", "<leader>ds", "n", load_pick, function()
    require("mini.extra").pickers.diagnostic()
end, { desc = "Mini Picker Diagnostics" })

lazy.on_keys("pick", "<leader>sk", "n", load_pick, function()
    require("mini.extra").pickers.keymaps()
end, { desc = "Search keymaps" })

-- mini.completion - InsertEnter
lazy.on_event("completion", "InsertEnter", "*", function()
    require("mini.completion").setup({
        lsp_completion = {
            auto_setup = true,
        },
    })
end)

-- mini.snippets - InsertEnter
lazy.on_event("snippets", "InsertEnter", "*", function()
    local MiniSnippets = require("mini.snippets")
    MiniSnippets.setup({
        snippets = {
            MiniSnippets.gen_loader.from_lang(),
        },
    })
    MiniSnippets.start_lsp_server({ match = false })
end)

-- mini.diff - BufReadPost
lazy.on_event("diff", "BufReadPost", "*", function()
    require("mini.diff").setup({
        source = require("mini.diff").gen_source.git({ index = false }),
    })
end)

-- vim-fugitive - 按键触发
lazy.on_keys("fugitive", "<leader>gg", "n", nil, function()
    vim.cmd("tabnew | Git | only")
end, { desc = "Fugitive Full Page New Tab" })

lazy.on_keys("fugitive", "<leader>gd", "n", nil, function()
    vim.cmd("Gvdiffsplit")
end, { desc = "Git diff split" })

-- mini.pick buffer picker (telescope buffers equivalent)
lazy.on_keys("pick", "<leader><leader>", "n", load_pick, function()
    local MiniPick = require("mini.pick")

    local delete_buf = function()
        local matches = MiniPick.get_picker_matches()
        local item = matches and matches.current
        if not item or not item.bufnr then
            return
        end
        local bufnr = item.bufnr

        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

        if MiniPick.is_picker_active() then
            local items = vim.tbl_filter(function(i)
                return i.bufnr and vim.api.nvim_buf_is_valid(i.bufnr)
            end, MiniPick.get_picker_items() or {})
            MiniPick.set_picker_items(items)
        end
    end

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
lazy.on_keys("pick", "<leader>ft", "n", load_pick, function()
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
