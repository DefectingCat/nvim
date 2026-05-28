local lazy = require("lazy")

local M = {}

M.load_pick = function()
	lazy.load("pick", function()
		require("mini.pick").setup()
	end)
	lazy.load("extra", function()
		require("mini.extra").setup()
	end)
end

-- Buffer picker (<leader><leader>) — supports <C-d> to delete buffer
vim.keymap.set("n", "<leader><leader>", function()
	M.load_pick()
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

-- Filetype picker (<leader>ft)
vim.keymap.set("n", "<leader>ft", function()
	M.load_pick()
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

return M
