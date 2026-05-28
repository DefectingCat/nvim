local lazy = require("lazy")
local pick = require("pick")
require("git")

vim.pack.add({
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/tpope/vim-fugitive",
}, { load = false })

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
	"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
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

-- mini.icons - 首次需要时加载（VimEnter 后延迟）
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("mini.icons").setup()
		lazy._loaded["icons"] = true
	end,
})

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

vim.keymap.set("n", "<leader>ds", function()
	vim.diagnostic.setloclist()
end, { desc = "LSP diagnostic loclist" })

-- finders
lazy.on_keys("pick", "<leader>ff", "n", pick.load_pick, function()
	require("mini.pick").builtin.files()
end, { desc = "Mini File Picker" })
lazy.on_keys("pick", "<leader>fw", "n", pick.load_pick, function()
	require("mini.pick").builtin.grep_live()
end, { desc = "Live grep in project" })
lazy.on_keys("pick", "<leader>sk", "n", pick.load_pick, function()
	require("mini.extra").pickers.keymaps()
end, { desc = "Search keymaps" })
lazy.on_keys("pick", "<leader>fa", "n", pick.load_pick, function()
	require("mini.pick").builtin.cli({ command = { "rg", "--files", "--hidden", "--no-ignore", "--color=never" } })
end, { desc = "Find all files (including hidden/ignored)" })
lazy.on_keys("pick", "<leader>fh", "n", pick.load_pick, function()
	require("mini.pick").builtin.help()
end, { desc = "Search help tags" })
lazy.on_keys("pick", "<leader>fo", "n", pick.load_pick, function()
	require("mini.extra").pickers.oldfiles()
end, { desc = "Search oldfiles" })
lazy.on_keys("pick", "<leader>fz", "n", pick.load_pick, function()
	require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "Search in current buffer" })

-- vim-fugitive - 按键触发
local function load_fugitive()
	vim.cmd.packadd("vim-fugitive")
end
lazy.on_keys("fugitive", "<leader>gg", "n", load_fugitive, function()
	vim.cmd("tabnew | Git | only")
end, { desc = "Fugitive Full Page New Tab" })
lazy.on_keys("fugitive", "<leader>gd", "n", load_fugitive, function()
	vim.cmd("Gvdiffsplit")
end, { desc = "Git diff split" })

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

-- mini.surround - BufReadPost
lazy.on_event("surround", "BufReadPost", "*", function()
	require("mini.surround").setup()
end)

-- 延迟加载 heavy 模块
lazy.on_event("treesitter", "VimEnter", "*", function()
	require("treesitter").setup()
end)
lazy.on_event("lsp", "VimEnter", "*", function()
	require("lsp")
end)
