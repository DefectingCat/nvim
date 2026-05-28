local M = {}

M._loaded = {}

M.load = function(name, fn)
    if M._loaded[name] then
        return
    end
    M._loaded[name] = true
    if fn then
        fn()
    end
end

M.on_event = function(name, event, pattern, fn)
    vim.api.nvim_create_autocmd(event, {
        pattern = pattern or "*",
        once = true,
        callback = function()
            M.load(name, fn)
        end,
    })
end

M.on_keys = function(name, keys, mode, fn, action, opts)
    mode = mode or "n"
    opts = opts or {}
    vim.keymap.set(mode, keys, function()
        M.load(name, fn)
        if action then
            action()
        end
    end, { desc = opts.desc, buffer = opts.buffer })
end

return M
