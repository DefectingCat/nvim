local lazy = require("lazy")

vim.pack.add({
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/tpope/vim-fugitive",
})

-- mini.starter 启动页
local starter = require("mini.starter")

local function get_total_plugins()
	local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt"
	local paths = vim.fn.glob(pack_dir .. "/*", false, true)
	local count = 0
	for _, path in ipairs(paths) do
		if vim.fn.isdirectory(path) == 1 then
			count = count + 1
		end
	end
	return count
end

local header_lines = {
	"",
	"    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
	"",
}

local max_header_width = 0
for _, line in ipairs(header_lines) do
	max_header_width = math.max(max_header_width, vim.fn.strdisplaywidth(line))
end

starter.setup({
	autoopen = true,
	evaluate_single = false,
	items = { { name = " ", action = "", section = "" } },
	header = table.concat(header_lines, "\n"),
	footer = function()
		local uv = vim.uv or vim.loop
		local ms = (uv:hrtime() - _G.nvim_start_time) / 1e6
		local loaded = vim.tbl_count(require("lazy")._loaded)
		local total = get_total_plugins()
		local text = string.format("  Loaded %d/%d plugins in %.0f ms", loaded, total, ms)
		local text_width = vim.fn.strdisplaywidth(text)
		local pad = math.floor((max_header_width - text_width) / 2)
		return string.rep(" ", pad) .. text
	end,
	content_hooks = {
		starter.gen_hook.aligning("center", "center"),
	},
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

-- mini.icons - 启动时加载
lazy.load("icons", function()
	require("mini.icons").setup()
end)

-- mini.notify - 首次 vim.notify 调用时加载
vim.notify = function(msg, level, opts)
	require("mini.notify").setup({
		content = {
			format = function(notif)
				return notif.msg
			end,
		},
	})
	vim.notify = require("mini.notify").make_notify()
	return vim.notify(msg, level, opts)
end

-- mini.cmdline - 首次按 : 时加载
vim.keymap.set("n", ":", function()
	vim.keymap.del("n", ":")
	require("mini.cmdline").setup({
		autocorrect = { enable = false },
	})
	return ":"
end, { expr = true, noremap = true })

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
	require("mini.pick").builtin.grep_live()
end, { desc = "Live grep in project" })

vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

lazy.on_keys("pick", "<leader>sk", "n", load_pick, function()
	require("mini.extra").pickers.keymaps()
end, { desc = "Search keymaps" })

lazy.on_keys("pick", "<leader>fa", "n", load_pick, function()
	require("mini.pick").builtin.cli({ command = { "rg", "--files", "--hidden", "--no-ignore", "--color=never" } })
end, { desc = "Find all files (including hidden/ignored)" })

lazy.on_keys("pick", "<leader>fh", "n", load_pick, function()
	require("mini.pick").builtin.help()
end, { desc = "Search help tags" })

lazy.on_keys("pick", "<leader>fo", "n", load_pick, function()
	require("mini.extra").pickers.oldfiles()
end, { desc = "Search oldfiles" })

lazy.on_keys("pick", "<leader>fz", "n", load_pick, function()
	require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "Search in current buffer" })

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
		view = {
			style = "sign",
			signs = { add = "│", change = "│", delete = "│" },
		},
		mappings = {
			apply = "gs",
			textobject = "",
		},
	})
end)

-- mini.diff extra: preview hunk, blame line, select hunk textobject
local function get_cursor_hunk()
	local buf = vim.api.nvim_get_current_buf()
	local data = require("mini.diff").get_buf_data(buf)
	if not data or not data.hunks or #data.hunks == 0 then
		return nil
	end
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	for _, h in ipairs(data.hunks) do
		local start_line = math.max(h.buf_start, 1)
		local end_line = h.buf_start + h.buf_count - 1
		if h.buf_count == 0 then
			end_line = start_line
		end
		if cursor_line >= start_line and cursor_line <= end_line then
			return h, data.ref_text
		end
	end
	return nil
end

local function preview_hunk()
	local hunk, ref_text = get_cursor_hunk()
	if not hunk then
		vim.notify("Cursor not on a hunk", vim.log.levels.WARN)
		return
	end
	local lines = {}
	table.insert(lines, "Hunk type: " .. hunk.type)
	table.insert(lines, string.format("Buffer lines: %d-%d", hunk.buf_start, hunk.buf_start + hunk.buf_count - 1))
	table.insert(lines, string.format("Reference lines: %d-%d", hunk.ref_start, hunk.ref_start + hunk.ref_count - 1))
	table.insert(lines, "---")
	local buf = vim.api.nvim_get_current_buf()
	local ref_lines = vim.split(ref_text or "", "\n")
	if hunk.type == "delete" then
		table.insert(lines, "Deleted lines (from reference):")
		for i = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
			table.insert(lines, "- " .. (ref_lines[i] or ""))
		end
	elseif hunk.type == "add" then
		table.insert(lines, "Added lines:")
		for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
			table.insert(lines, "+ " .. (vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] or ""))
		end
	else
		table.insert(lines, "Before (reference):")
		for i = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
			table.insert(lines, "- " .. (ref_lines[i] or ""))
		end
		table.insert(lines, "After (buffer):")
		for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
			table.insert(lines, "+ " .. (vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] or ""))
		end
	end
	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(#lines + 2, vim.o.lines - 4)
	local preview_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = preview_buf })
	vim.api.nvim_set_option_value("filetype", "diff", { buf = preview_buf })
	local win = vim.api.nvim_open_win(preview_buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " Hunk Preview ",
		title_pos = "center",
	})
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = preview_buf })
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = preview_buf })
end

local function blame_line()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("No file name", vim.log.levels.WARN)
		return
	end
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local cmd = { "git", "blame", "-L", line .. "," .. line, "--porcelain", file }
	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("git blame failed", vim.log.levels.ERROR)
		return
	end
	local hash = output:match("^(%x+)%s") or "?"
	local author = output:match("author ([^\n]+)") or "?"
	local email = output:match("author%-mail ([^\n]+)") or "?"
	local time = output:match("author%-time (%d+)")
	local summary = output:match("summary ([^\n]+)") or "?"
	local time_str = time and os.date("%Y-%m-%d %H:%M", tonumber(time)) or "?"
	vim.notify(
		string.format("%s | %s %s | %s\n%s", hash:sub(1, 8), author, email, time_str, summary),
		vim.log.levels.INFO
	)
end

vim.keymap.set("n", "<leader>ghp", preview_hunk, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>ghb", blame_line, { desc = "Blame line" })
vim.keymap.set("n", "<leader>gB", function()
	vim.cmd("Git blame")
end, { desc = "Blame buffer" })

vim.keymap.set("n", "<leader>gD", function()
	vim.cmd("Git log -p -- %")
end, { desc = "Git file history" })

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
