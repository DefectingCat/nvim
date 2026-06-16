-- =============================================================================
-- Git 工具封装 (lua/plugins/git.lua)
-- =============================================================================
-- 本模块提供三层 Git 工具栈，职责无重叠（对齐 nvchad 分支设计）：
--
--   1. buffer 级（实时）— gitsigns.nvim
--      signcolumn gutter 标记 + hunk stage/reset/preview/blame + diffthis
--      键位：ghs/ghr/ghp/ghb/ghB/ghd/ghD + ]h/[h hunk 导航
--
--   2. 仓库级（交互式）— neogit
--      Magit 风格 status 界面，commit/push/pull/log
--      键位：<leader>gg
--
--   3. 文件级（可视化）— codediff.nvim
--      VSCode 风格 side-by-side diff + 文件历史
--      键位：<leader>gd / <leader>gD
--
-- 依赖：
--   - gitsigns.nvim（本文件通过 BufReadPost 懒加载）
--   - neogit（依赖 plenary.nvim，按键触发懒加载）
--   - codediff.nvim（按键触发懒加载）
-- =============================================================================

local lazy = require("lazy")

-- ---------------------------------------------------------------------------
-- gitsigns.nvim — buffer 级 Git 集成（BufReadPost 懒加载）
-- ---------------------------------------------------------------------------
-- 在 signcolumn 中显示 add/change/delete 标记，并提供 hunk 级操作。
-- on_attach 回调中注册 buffer-local 键位映射，仅对已 attach 的 buffer 生效。
local function load_gitsigns()
	vim.cmd.packadd("gitsigns.nvim")
	require("gitsigns").setup({
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signcolumn = true,
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = desc })
			end

			-- hunk 导航（diff 模式下降级为原生 ]c/[c）
			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "下一个 hunk")
			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "上一个 hunk")
			map("n", "]H", function()
				gs.nav_hunk("last")
			end, "最后一个 hunk")
			map("n", "[H", function()
				gs.nav_hunk("first")
			end, "第一个 hunk")

			-- hunk 操作（Normal + Visual）
			-- stylua: ignore start
			map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
			map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
			map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
			map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
			map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
			map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
			map("n", "<leader>ghb", function()
				gs.blame_line({ full = true })
			end, "Blame 当前行")
			map("n", "<leader>ghB", gs.blame, "Blame 整个文件")
			map("n", "<leader>ghd", gs.diffthis, "Diff This")
			map("n", "<leader>ghD", function()
				gs.diffthis("~")
			end, "Diff This ~")
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns Select Hunk")
			-- stylua: ignore end
		end,
	})
end

lazy.on_event("gitsigns", "BufReadPost", "*", load_gitsigns)

-- ---------------------------------------------------------------------------
-- neogit — 仓库级 Git 客户端（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- Magit 风格的交互式 status 界面，集成 commit/push/pull/log/rebase 等。
-- 依赖 plenary.nvim，加载 neogit 前需确保 plenary 已在 runtimepath。
local function load_neogit()
	vim.cmd.packadd("plenary.nvim")
	vim.cmd.packadd("neogit")
	require("neogit").setup({})
end

-- <leader>gg — 打开 Neogit status（新标签页）
lazy.on_keys("neogit", "<leader>gg", "n", load_neogit, function()
	require("neogit").open({ kind = "tab" })
end, { desc = "Neogit status" })

-- ---------------------------------------------------------------------------
-- codediff.nvim — 文件级 diff 可视化（按键触发懒加载）
-- ---------------------------------------------------------------------------
-- VSCode 风格 side-by-side diff，支持行级 + 字符级双层高亮。
-- 提供工作区 diff（:CodeDiff）和文件历史（:CodeDiff history）两种视图。
local function load_codediff()
	vim.cmd.packadd("codediff.nvim")
	require("codediff").setup({
		diff = {
			layout = "side-by-side",
			disable_inlay_hints = true,
			jump_to_first_change = true,
			cycle_next_hunk = true,
			cycle_next_file = true,
		},
		explorer = {
			width = 35,
		},
		keymaps = {
			view = {
				quit = "q",
				next_hunk = "]c",
				prev_hunk = "[c",
				next_file = "]f",
				prev_file = "[f",
				diff_get = "do",
				diff_put = "dp",
				open_in_prev_tab = "gf",
				toggle_stage = "<leader>cs",
				stage_hunk = "<leader>hs",
				unstage_hunk = "<leader>hu",
				discard_hunk = "<leader>hr",
				hunk_textobject = "ih",
				show_help = "g?",
				align_move = "gm",
				toggle_layout = "t",
			},
		},
	})
end

-- <leader>gd — CodeDiff 工作区 diff 视图
lazy.on_keys("codediff", "<leader>gd", "n", load_codediff, function()
	vim.cmd("CodeDiff")
end, { desc = "CodeDiff git status" })

-- <leader>gD — CodeDiff 当前文件历史（共享 codediff 懒加载，setup 仅首次执行）
lazy.on_keys("codediff", "<leader>gD", "n", load_codediff, function()
	vim.cmd("CodeDiff history")
end, { desc = "CodeDiff 文件历史" })
