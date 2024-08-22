local cmp = require("cmp")
local overrides = require("configs.overrides")

local plugins = {
	-- LSP, formatter, linter
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
			require("nvchad.configs.lspconfig").defaults()
		end,
	},
	--[[ {
    "jay-babu/mason-nvim-dap.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "codelldb",
        },
        automatic_installation = true,
      })
    end,
  }, ]]
	--[[ {
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"prettierd",
					"ymlfmt",
					"shellharden",
					"shfmt",
					"goimports",
					"goimports-reviser",
					"golines",
				},
				automatic_installation = true,
			})
		end,
	}, ]]
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"gopls",
				"lua_ls",
				"rust_analyzer",
				"html",
				"volar",
				"vtsls",
				"tailwindcss",
				"eslint",
				"cssls",
				"cssmodules_ls",
				"jsonls",
				"yamlls",
				"docker_compose_language_service",
				"dockerls",
				"bashls",
				"clangd",
				"lemminx",
				--[[ "intelephense", ]]
			},
			automatic_installation = true,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},
	{
		"williamboman/mason.nvim",
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				-- defaults
				"vim",
				"vimdoc",
				"lua",
				-- web dev
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"vue",
				"markdown",
				"markdown_inline",
				"jsdoc",
				"scss",
				-- low level
				"rust",
				"toml",
				"go",
				"gomod",
				"sql",
			},
			highlight = {
				disable = function(_, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = function()
			return require("configs.conform")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
		},
		opts = function()
			---@diagnostic disable-next-line: different-requires
			local M = require("nvchad.configs.cmp")
			M.completion.completeopt = "menu,menuone,noselect"
			M.mapping["<CR>"] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = true,
			})
			table.insert(M.sources, { name = "crates" })
			-- original LazyVim kind icon formatter
			local format_kinds = M.formatting.format
			M.formatting.format = function(entry, item)
				format_kinds(entry, item) -- add icons
				return require("tailwindcss-colorizer-cmp").formatter(entry, item)
			end
			return M
		end,
	},
	-- rust
	--[[ {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = "rust",
    config = function()
      require("configs.rust")
    end,
  }, ]]
	{
		"saecki/crates.nvim",
		ft = { "toml" },
		config = function(_, opts)
			local crates = require("crates")
			crates.setup(opts)
			require("cmp").setup.buffer({
				sources = { { name = "crates" } },
			})
			crates.show()
			--[[ require("core.utils").load_mappings("crates") ]]
		end,
	},
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	-- golang
	{
		"olexsmir/gopher.nvim",
		ft = "go",
		config = function(_, opts)
			require("gopher").setup(opts)
		end,
		build = function()
			vim.cmd([[silent! GoInstallDeps]])
		end,
	},
	{
		"David-Kunz/gen.nvim",
		event = "BufReadPost",
		opts = {
			model = "deepseek-coder", -- The default model to use.
			quit_map = "q",        -- set keymap for close the response window
			retry_map = "<c-r>",   -- set keymap to re-send the current prompt
			accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
			host = "localhost",    -- The host running the Ollama service.
			port = "11434",        -- The port on which the Ollama service is listening.
			display_mode = "split", -- The display mode. Can be "float" or "split" or "horizontal-split".
			show_prompt = false,   -- Shows the prompt submitted to Ollama.
			show_model = false,    -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			hidden = false,        -- Hide the generation window (if true, will implicitly set `prompt.replace = true`)
			init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
			-- Function to initialize Ollama
			command = function(options)
				local body = { model = options.model, stream = true }
				return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
			end,
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a command string.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			-- list_models = '<omitted lua function>', -- Retrieves a list of model names
			debug = false -- Prints errors and the command which is run.
		}
	},
	--[[ {
    "dreamsofcode-io/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  }, ]]
	{
		"b0o/schemastore.nvim",
	},
	-- database
	{
		"tpope/vim-dadbod",
		event = "BufReadPre",
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		event = "BufReadPre",
	},
	{
		"kristijanhusak/vim-dadbod-completion",
		event = "BufReadPre",
	},

	-- debug
	--[[ {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dapui").setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  }, ]]
	--[[ {
    "mfussenegger/nvim-dap",
    config = function()
      require("configs.dap")
    end,
  }, ]]
	--[[ {
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup(opts)
    end,
  }, ]]

	-- telescope, code action ui
	--[[ { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, ]]
	{
		"nvim-telescope/telescope.nvim",
		opts = function()
			require("configs.telescope")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		--[[ build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build", ]]
		build = "make",
	},
	{
		"nvim-pack/nvim-spectre",
		event = "BufRead",
	},
	{
		"stevearc/oil.nvim",
		event = "VeryLazy",
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				view_options = {
					show_hidden = true,
				},
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-s>"] = false,
					--[[ ["<C-h>"] = { "actions.select", opts = { horizontal = true } }, ]]
					["<C-h>"] = false,
					["<C-t>"] = { "actions.select", opts = { tab = true } },
					["<C-p>"] = "actions.preview",
					["<C-c>"] = false,
					["q"] = "actions.close",
					["<C-l>"] = false,
					["<C-r>"] = { "actions.refresh" },
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = { "actions.cd", opts = { scope = "tab" } },
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
					["g\\"] = "actions.toggle_trash",
				},
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
			})
		end,
	},
	-- motion, UI and others
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			local hop = require("hop")
			hop.setup({ keys = "etovxqpdygfblzhckisuran" })
		end,
	},
	{
		"mg979/vim-visual-multi",
		event = "BufReadPost",
	},
	{
		"jxnblk/vim-mdx-js",
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({})
		end,
		lazy = true,
		event = "BufReadPre",
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "BufReadPre",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	-- comment string
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	{
		"numToStr/Comment.nvim",
		event = "BufReadPre",
		opts = {
			-- pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			pre_hook = function(ctx)
				local U = require("Comment.utils")

				local location = nil
				if ctx.ctype == U.ctype.block then
					location = require("ts_context_commentstring.utils").get_cursor_location()
				elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
					location = require("ts_context_commentstring.utils").get_visual_start_location()
				end

				return require("ts_context_commentstring.internal").calculate_commentstring({
					key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
					location = location,
				})
			end,
		},
	},
	-- ui
	{
		"mistricky/codesnap.nvim",
		build = "make",
		event = "BufRead",
		opts = {
			mac_window_bar = true,
			title = "RUA",
			code_font_family = "JetBrains Mono NL",
			watermark = "RUA",
			bg_color = "#535c68",
		},
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>tX",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>tx",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>ts",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>tl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>tL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>tQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
		opts = {},
	},
	{
		"NvChad/nvim-colorizer.lua",
		opts = {
			user_default_options = {
				tailwind = true,
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
		opts = {},
	},
	{
		"RRethy/vim-illuminate",
		event = "BufRead",
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		--[[ build = function() ]]
		--[[ 	vim.fn["mkdp#util#install"]() ]]
		--[[ end, ]]
		build = function(plugin)
			if vim.fn.executable "npx" then
				vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
			else
				vim.cmd [[Lazy load markdown-preview.nvim]]
				vim.fn["mkdp#util#install"]()
			end
		end,
		init = function()
			if vim.fn.executable "npx" then vim.g.mkdp_filetypes = { "markdown" } end
		end,
	},
	-- git
	{
		"sindrets/diffview.nvim",
		opts = {
			enhanced_diff_hl = true,
			view = {
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true,
				},
			},
			keymaps = {
				view = {
					["<tab>"] = false,
				},
				file_panel = {
					["<tab>"] = false,
				},
				file_history_panel = {
					["<tab>"] = false,
				},
				option_panel = {
					["<tab>"] = false,
				},
			},
		},
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",      -- required
			"sindrets/diffview.nvim",     -- optional - Diff integration
			"nvim-telescope/telescope.nvim", -- optional
		},
		event = { "BufRead" },
		opts = function()
			return require("configs.neogit")
		end,
		--[[ config = true, ]]
		config = function(_, opts)
			require("neogit").setup(opts)
		end,
	},

	--[[ overrides ]]
	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},
}

return plugins
