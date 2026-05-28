-- =============================================================================
-- 自定义懒加载框架 (lua/lazy.lua)
-- =============================================================================
-- 本模块与 lazy.nvim 插件管理器完全无关，
-- 是一个约 35 行的轻量级懒加载原语封装，用于延迟加载重型插件模块。
--
-- 核心设计：
--   - 通过 _loaded 表跟踪已加载模块，避免重复初始化
--   - on_event：通过 autocmd 在特定事件（如 InsertEnter、BufReadPost）触发加载
--   - on_keys：通过键位映射触发加载，首次按键时初始化插件
--   - load：直接加载，用于手动触发或内部调用
-- =============================================================================

local M = {}

-- 已加载模块的标记表。
-- 键为模块标识名（如 "treesitter", "lsp", "completion"），
-- 值为 true 表示该模块已完成初始化。
-- 此表用于防止重复加载和重复执行 setup()。
M._loaded = {}

-- ---------------------------------------------------------------------------
-- 直接加载模块
-- ---------------------------------------------------------------------------
-- 参数：
--   name  - 模块标识名（自定义字符串，用于 _loaded 去重）
--   fn    - 可选的初始化函数，在首次加载时执行
--
-- 行为：
--   1. 检查 _loaded[name] 是否为真，是则直接返回（幂等）
--   2. 标记为已加载
--   3. 如果有 fn，执行 fn() 完成插件 setup
--
-- 使用场景：
--   在按键回调中手动触发加载，或在 on_event 回调中延迟初始化。
M.load = function(name, fn)
	if M._loaded[name] then
		return
	end
	M._loaded[name] = true
	if fn then
		fn()
	end
end

-- 仅标记模块为已加载，不执行 setup（用于直接加载的插件）。
M.track = function(name)
	M._loaded[name] = true
end

-- ---------------------------------------------------------------------------
-- 事件触发懒加载
-- ---------------------------------------------------------------------------
-- 参数：
--   name    - 模块标识名
--   event   - Neovim autocmd 事件名（如 "InsertEnter", "BufReadPost", "VimEnter"）
--   pattern - autocmd 匹配模式，默认为 "*"
--   fn      - 初始化函数
--
-- 原理：
--   创建一个一次性的 autocmd（once = true），
--   当指定事件首次触发时，调用 M.load(name, fn) 完成初始化。
--   由于 once = true，autocmd 在触发后自动销毁，不会重复执行。
--
-- 典型用法：
--   lazy.on_event("completion", "InsertEnter", "*", function()
--       require("mini.completion").setup({ ... })
--   end)
M.on_event = function(name, event, pattern, fn)
	vim.api.nvim_create_autocmd(event, {
		pattern = pattern or "*",
		once = true,
		callback = function()
			M.load(name, fn)
		end,
	})
end

-- ---------------------------------------------------------------------------
-- 按键触发懒加载
-- ---------------------------------------------------------------------------
-- 参数：
--   name   - 模块标识名
--   keys   - 键位序列（如 "<leader>ff", "<leader>gg"）
--   mode   - 映射模式，默认为 "n"（normal）
--   fn     - 初始化函数，在首次按键时执行
--   action - 可选的额外动作函数，在 fn 之后执行
--   opts   - 键位映射选项（desc, buffer 等）
--
-- 原理：
--   创建一个键位映射，首次按下时：
--   1. 调用 M.load(name, fn) 完成插件初始化
--   2. 如果提供了 action，执行 action()
--   3. 后续按键直接执行 action（因为 _loaded 已标记）
--
-- 注意：
--   此设计使得首次按键稍慢（需要 setup），后续按键与直接映射无异。
--   适合重型插件如 mini.pick、vim-fugitive。
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
