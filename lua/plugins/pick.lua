-- =============================================================================
-- mini.pick 封装 (lua/plugins/pick.lua)
-- =============================================================================
-- 本模块封装 mini.pick 和 mini.extra 的初始化逻辑，
-- 提供统一的懒加载入口和自定义 picker。
--
-- 所有 pick 键位统一使用 lazy.on_keys 懒加载，确保 mini.pick 和 mini.extra
-- 只在首次按键时初始化。
--
-- 主要功能：
--   1. 文件查找、实时 grep、帮助搜索等（<leader>f* 系列）
--   2. Buffer picker（<leader><leader>）— 自定义 buffer 列表
--   3. Filetype picker（<leader>ft）— 快速切换文件类型
-- =============================================================================

local lazy = require("lazy")

local M = {}

-- ---------------------------------------------------------------------------
-- 懒加载入口
-- ---------------------------------------------------------------------------
-- 通过 lazy.load 确保 mini.pick 和 mini.extra 只初始化一次。
M.load_pick = function()
	lazy.load("pick", function()
		require("mini.pick").setup()
	end)
	lazy.load("extra", function()
		require("mini.extra").setup()
	end)
end

-- ---------------------------------------------------------------------------
-- 内置 Pickers（<leader>f* 系列）
-- ---------------------------------------------------------------------------

-- <leader>ff ：文件查找
lazy.on_keys("pick", "<leader>ff", "n", M.load_pick, function()
	require("mini.pick").builtin.cli({
		command = { "rg", "--files", "--hidden", "--glob", "!.git/", "--color=never" },
	})
end, { desc = "文件查找" })

-- <leader>fw ：实时 grep（在项目中搜索文本）
lazy.on_keys("pick", "<leader>fw", "n", M.load_pick, function()
	require("mini.pick").builtin.grep_live()
end, { desc = "项目内实时搜索" })

-- <leader>sk ：键位映射搜索
lazy.on_keys("pick", "<leader>sk", "n", M.load_pick, function()
	require("mini.extra").pickers.keymaps()
end, { desc = "搜索键位映射" })

-- <leader>fa ：查找所有文件（含隐藏和忽略的文件）
lazy.on_keys("pick", "<leader>fa", "n", M.load_pick, function()
	require("mini.pick").builtin.cli({
		command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!.git/", "--color=never" },
	})
end, { desc = "查找所有文件（含隐藏/忽略）" })

-- <leader>fh ：帮助标签搜索
lazy.on_keys("pick", "<leader>fh", "n", M.load_pick, function()
	require("mini.pick").builtin.help()
end, { desc = "搜索帮助标签" })

-- <leader>fo ：最近打开的文件
lazy.on_keys("pick", "<leader>fo", "n", M.load_pick, function()
	require("mini.extra").pickers.oldfiles()
end, { desc = "最近打开的文件" })

-- <leader>fz ：当前缓冲区行内搜索
lazy.on_keys("pick", "<leader>fz", "n", M.load_pick, function()
	require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "当前缓冲区行内搜索" })

-- ---------------------------------------------------------------------------
-- Buffer Picker（<leader><leader>）
-- ---------------------------------------------------------------------------
-- 显示当前打开的 buffer 列表，按最近使用时间排序。
-- 特殊功能：
--   - <C-d>：删除当前选中的 buffer
--   - 支持 mini.icons 图标显示
lazy.on_keys("pick", "<leader><leader>", "n", M.load_pick, function()
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
end, { desc = "Buffer 列表" })

-- ---------------------------------------------------------------------------
-- Filetype Picker（<leader>ft）
-- ---------------------------------------------------------------------------
-- 显示所有可用的文件类型列表，选择后设置当前 buffer 的 filetype。
lazy.on_keys("pick", "<leader>ft", "n", M.load_pick, function()
	local MiniPick = require("mini.pick")
	-- mini.pick 会把 item 规范化后再传给 choose，不能直接用原始字符串。
	-- 这里显式构造 { text = ft } 形态的 item，choose 中取 .text 拿到 filetype 字符串。
	local filetypes = vim.fn.getcompletion("", "filetype")
	local items = vim.tbl_map(function(ft)
		return { text = ft }
	end, filetypes)
	MiniPick.start({
		source = {
			name = "Filetypes",
			items = items,
			choose = function(item)
				-- choose 执行时 picker 浮窗仍是当前窗口，vim.bo 默认作用于 picker 自己的 buffer。
				-- 必须用 picker_state.windows.target 拿到用户原本的窗口，在其 buffer 上设 filetype。
				local state = MiniPick.get_picker_state()
				local win = state and state.windows and state.windows.target
				local target_buf = win and vim.api.nvim_win_get_buf(win) or 0
				vim.bo[target_buf].filetype = item.text
			end,
		},
	})
end, { desc = "切换文件类型" })

return M
