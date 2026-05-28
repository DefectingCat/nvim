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
