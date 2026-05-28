-- =============================================================================
-- mini.pick 封装 (lua/pick.lua)
-- =============================================================================
-- 本模块封装 mini.pick 和 mini.extra 的初始化逻辑，
-- 提供统一的懒加载入口和自定义 picker。
--
-- 主要功能：
--   1. load_pick() — 懒加载 mini.pick 和 mini.extra
--   2. Buffer picker（<leader><leader>）— 自定义 buffer 列表，支持 <C-d> 删除
--   3. Filetype picker（<leader>ft）— 快速切换文件类型
-- =============================================================================
local lazy = require("lazy")

local M = {}

-- ---------------------------------------------------------------------------
-- 懒加载入口
-- ---------------------------------------------------------------------------
-- 通过 lazy.load 确保 mini.pick 和 mini.extra 只初始化一次。
-- 此函数被 pack.lua 中所有 pick 相关的 on_keys 映射共用。
M.load_pick = function()
	lazy.load("pick", function()
		require("mini.pick").setup()
	end)
	lazy.load("extra", function()
		require("mini.extra").setup()
	end)
end

-- ---------------------------------------------------------------------------
-- Buffer Picker（<leader><leader>）
-- ---------------------------------------------------------------------------
-- 显示当前打开的 buffer 列表，按最近使用时间排序。
-- 特殊功能：
--   - <C-d>：删除当前选中的 buffer（带图标过滤）
--   - 支持 mini.icons 图标显示
vim.keymap.set("n", "<leader><leader>", function()
	M.load_pick()
	local MiniPick = require("mini.pick")

	-- 删除当前选中 buffer 的回调函数
	local delete_buf = function()
		local matches = MiniPick.get_picker_matches()
		local item = matches and matches.current
		if not item or not item.bufnr then
			return
		end
		local bufnr = item.bufnr

		-- 安全删除 buffer（force = true 跳过未保存确认）
		pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

		-- 如果 picker 仍活跃，刷新列表以移除已删除的 buffer
		if MiniPick.is_picker_active() then
			local items = vim.tbl_filter(function(i)
				return i.bufnr and vim.api.nvim_buf_is_valid(i.bufnr)
			end, MiniPick.get_picker_items() or {})
			MiniPick.set_picker_items(items)
		end
	end

	-- 获取所有普通 buffer（排除特殊 buffer 如终端、quickfix）
	local bufs = vim.tbl_filter(function(b)
		return vim.bo[b.bufnr].buftype == "" and b.listed == 1
	end, vim.fn.getbufinfo())

	-- 按最后使用时间降序排列（最近使用的在前）
	table.sort(bufs, function(a, b)
		return a.lastused > b.lastused
	end)

	-- 构建 picker items
	local items = {}
	for _, info in ipairs(bufs) do
		-- 相对路径显示（当前工作目录为基准）
		local name = info.name ~= "" and vim.fn.fnamemodify(info.name, ":.") or "[No Name]"
		table.insert(items, {
			text = name,
			bufnr = info.bufnr,
		})
	end

	-- 启动 picker
	MiniPick.start({
		source = {
			name = "Buffers",
			items = items,
			show = function(buf_id, items_arr, query)
				-- 使用默认显示函数，启用图标
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
-- 常用于打开无扩展名文件或纠正错误的文件类型检测。
vim.keymap.set("n", "<leader>ft", function()
	M.load_pick()
	local MiniPick = require("mini.pick")
	-- 获取所有可用的文件类型名称
	local filetypes = vim.fn.getcompletion("", "filetype")
	MiniPick.start({
		source = {
			name = "Filetypes",
			items = filetypes,
			choose = function(item)
				-- 选择后将当前 buffer 的 filetype 设为选中值
				vim.bo.filetype = item
			end,
		},
	})
end, { desc = "切换文件类型" })

return M
