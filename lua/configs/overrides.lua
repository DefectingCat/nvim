local M = {}

-- git support in nvimtree
M.nvimtree = {
	disable_netrw = false,
	git = {
		enable = true,
		ignore = false,
		timeout = 500,
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		show_on_open_dirs = false,
		severity = {
			min = vim.diagnostic.severity.HINT,
			max = vim.diagnostic.severity.ERROR,
		},
	},
	modified = {
		enable = true,
		show_on_open_dirs = false,
	},
	actions = {
		change_dir = {
			enable = true,
			global = true,
		},
		open_file = {
			resize_window = true,
		},
		remove_file = {
			close_window = false,
		},
	},
	notify = {
		absolute_path = false,
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 50,
		ignore_dirs = {
			"node_modules",
			".next",
			".venv",
			"target",
			"out",
			"dist",
			"build",
		},
	},
	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
	view = {
		side = "left",
	},
}

return M
