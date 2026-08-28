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

-- <leader>fr ：恢复上次搜索（重开最近的 picker，输入框清空）
lazy.on_keys("pick", "<leader>fr", "n", M.load_pick, function()
	require("mini.pick").builtin.resume()
end, { desc = "恢复上次搜索" })

-- ---------------------------------------------------------------------------
-- Buffer Picker（<leader><leader>）
-- ---------------------------------------------------------------------------
-- 显示当前打开的 buffer 列表，按最近使用时间排序。
-- 特殊功能：
--   - <C-d>：删除当前选中的 buffer（删除后光标停在原位置对应的下一项）
--   - 支持 mini.icons 图标显示
lazy.on_keys("pick", "<leader><leader>", "n", M.load_pick, function()
	local MiniPick = require("mini.pick")

	local delete_buf = function()
		local matches = MiniPick.get_picker_matches()
		local item = matches and matches.current
		if not item or not item.bufnr then
			return
		end
		-- 删除前：当前 item 在 items 中的绝对索引
		-- 删除后该槽位由原"下一项"占据；删末项则退到新末项
		local cur_abs_ind = matches.current_ind
		local bufnr = item.bufnr
		local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, {})
		if not ok then
			vim.notify("无法删除 Buffer: " .. tostring(err), vim.log.levels.WARN)
			return
		end
		if not MiniPick.is_picker_active() then
			return
		end

		local items = vim.tbl_filter(function(i)
			return i.bufnr and vim.api.nvim_buf_is_valid(i.bufnr)
		end, MiniPick.get_picker_items() or {})

		-- 目标绝对索引：删中间项→原下一项落入该槽位；删末项→退到新末项
		local target = math.min(cur_abs_ind, #items)

		-- set_picker_items 内部 picker_set_items 末尾的 picker_set_match_inds 会把
		-- current_ind 重置为 1。此处 picker_set_items 同步返回（其协程内部 poke_picker
		-- 只返回布尔不 yield），故直接在其后用 set_picker_match_inds 恢复即可。
		--
		-- 前提：action 名必须不以 "delete" 开头（见下方 mappings.wipeout）。picker_advance
		-- 主循环对名字以 "delete" 开头的 action 会在下一轮强制 picker_update(do_match=true)
		-- → picker_match → picker_set_match_inds → 再次重置 current_ind=1，覆盖这里的恢复。
		MiniPick.set_picker_items(items, { do_match = false })

		if target >= 1 then
			-- pcall：target 若不在当前 query 匹配中（被过滤），上游 H.error，
			-- 吞掉以保持第 1 项（合理降级）
			pcall(MiniPick.set_picker_match_inds, { target }, "current")
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
			-- 名字必须不以 "delete" 开头：picker_advance 主循环对 delete* action 会在
			-- 下一轮强制 picker_update(do_match=true)，触发 picker_match →
			-- picker_set_match_inds → 重置 current_ind=1，覆盖 delete_buf 里的光标恢复。
			-- 与 mini.pick 官方 buffers 示例保持一致用 "wipeout"。
			wipeout = { char = "<C-d>", func = delete_buf },
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
