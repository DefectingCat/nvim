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
--   2. 如果有 fn，执行 fn() 完成插件 setup
--   3. 仅在 fn() 成功执行后，标记为已加载
--
-- 使用场景：
--   在按键回调中手动触发加载，或在 on_event 回调中延迟初始化。
M.load = function(name, fn)
	if M._loaded[name] then
		return true
	end
	if fn then
		local ok, err = pcall(fn)
		if not ok then
			vim.notify("[lazy] 加载 " .. name .. " 失败: " .. tostring(err), vim.log.levels.ERROR)
			return false
		end
	end
	M._loaded[name] = true
	return true
end

-- 仅标记模块为已加载，不执行 setup（用于直接加载的插件）。
M.track = function(name)
	if M._loaded[name] then
		return true
	end
	M._loaded[name] = true
	return true
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
--   2. 如果 M.load 失败，直接返回，不执行 action
--   3. 如果提供了 action 且加载成功，执行 action()
--   4. 后续按键直接执行 action（因为 _loaded 已标记）
--
-- 注意：
--   此设计使得首次按键稍慢（需要 setup），后续按键与直接映射无异。
--   适合重型插件如 mini.pick、vim-fugitive。
M.on_keys = function(name, keys, mode, fn, action, opts)
	mode = mode or "n"
	opts = opts or {}
	vim.keymap.set(mode, keys, function()
		if not M.load(name, fn) then
			return
		end
		if action then
			action()
		end
	end, { desc = opts.desc, buffer = opts.buffer })
end

-- ---------------------------------------------------------------------------
-- 命令触发懒加载
-- ---------------------------------------------------------------------------
-- 参数：
--   name    - 模块标识名
--   cmd     - 命令名（如 "ExColors"）
--   fn      - 初始化函数，在首次执行命令时调用
--   opts    - 用户命令选项（bang, nargs, range, desc 等）
--
-- 原理：
--   创建一个同名的临时用户命令，首次执行时：
--   1. 调用 M.load(name, fn) 完成插件初始化
--   2. 如果加载失败，保留临时命令，让用户可以重试
--   3. 加载成功后删除临时命令，避免与插件注册的命令冲突
--   4. 按用户输入的完整形式（mods/range/bang/args）重新执行命令
--
-- 注意：
--   插件初始化后通常会注册同名命令并覆盖临时命令；
--   如果插件不注册命令，需要用 fn 手动处理命令逻辑。
M.on_cmd = function(name, cmd, fn, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(cmd, function(cmd_opts)
		-- 先加载；只有加载成功才删除临时命令，否则保留重试机会
		if not M.load(name, fn) then
			return
		end
		vim.api.nvim_del_user_command(cmd)

		-- 还原用户最初输入的完整命令（mods/range/cmd/bang/args）
		local parts = {}
		if cmd_opts.mods and cmd_opts.mods ~= "" then
			table.insert(parts, cmd_opts.mods)
		end
		if cmd_opts.range == 2 then
			table.insert(parts, cmd_opts.line1 .. "," .. cmd_opts.line2)
		elseif cmd_opts.range == 1 then
			table.insert(parts, cmd_opts.line1)
		end
		table.insert(parts, cmd)
		if cmd_opts.bang then
			table.insert(parts, "!")
		end
		if cmd_opts.args and cmd_opts.args ~= "" then
			table.insert(parts, " " .. cmd_opts.args)
		end

		local full = table.concat(parts, "")
		local ok, err = pcall(vim.cmd, full)
		if not ok then
			vim.notify("[lazy] 执行 " .. full .. " 失败: " .. tostring(err), vim.log.levels.ERROR)
		end
	end, {
		bang = opts.bang,
		nargs = opts.nargs,
		range = opts.range,
		desc = opts.desc,
	})
end

return M
