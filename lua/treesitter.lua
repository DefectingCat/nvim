local treesitter = require("nvim-treesitter")

local ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    -- Web
    "javascript",
    "typescript",
    "tsx",
    "jsdoc",
    "json",
    "html",
    "css",
    "yaml",
    -- Backend
    "c",
    "rust",
    "toml",
    "go",
    "gomod",
    "gosum",
    "gowork",
    -- Infra
    "dockerfile",
    "make",
}

-- 延迟安装 parser，避免启动时阻塞
vim.defer_fn(function()
    treesitter.install(ensure_installed)
end, 100)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end

        local ok_add = pcall(vim.treesitter.language.add, lang)
        if not ok_add then
            return
        end

        pcall(vim.treesitter.start, buf, lang)
    end,
})
