-- =============================================================================
-- 用户自定义命令 (lua/usercmds.lua)
-- =============================================================================
-- 定义 Neovim 命令行可用的自定义命令，封装 vim.pack API 的日常操作。
--
-- Neovim 0.12+ 内置 vim.pack 插件管理，提供：
--   vim.pack.add(urls, opts)     - 添加/安装插件
--   vim.pack.del(names)          - 删除插件
--   vim.pack.update(names?)      - 更新插件
--
-- 以下命令是对这些 API 的友好封装，支持命令行参数解析。
-- =============================================================================

-- ---------------------------------------------------------------------------
-- :PackAdd — 添加插件
-- ---------------------------------------------------------------------------
-- 用法：:PackAdd user/repo1 user/repo2 ...
-- 示例：:PackAdd stevearc/conform.nvim tpope/vim-fugitive
--
-- 原理：
--   将命令行参数（opts.fargs，已按空格分割的字符串数组）
--   直接传递给 vim.pack.add()。
--   vim.pack 会从 GitHub 下载插件到 stdpath("data")/site/pack/core/opt/。
--
-- nargs = "+" 表示至少需要 1 个参数。
vim.api.nvim_create_user_command("PackAdd", function(opts)
	vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "添加插件 (:PackAdd user/repo1 user/repo2)" })

-- ---------------------------------------------------------------------------
-- :PackDel — 删除插件
-- ---------------------------------------------------------------------------
-- 用法：:PackDel plugin1 plugin2 ...
-- 示例：:PackDel conform.nvim vim-fugitive
--
-- 注意：
--   参数是插件目录名（即 repo 名），不是完整 URL。
--   Neovim 0.13 Nightly 已内置此命令，这里为 0.12 提供兼容。
--
-- nargs = "+" 表示至少需要 1 个参数。
vim.api.nvim_create_user_command("PackDel", function(opts)
	vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "删除插件 (:PackDel plugin1 plugin2)" })

-- ---------------------------------------------------------------------------
-- :PackUpdate — 更新插件
-- ---------------------------------------------------------------------------
-- 用法：
--   :PackUpdate        → 更新所有插件
--   :PackUpdate name1 name2 ... → 更新指定插件
--
-- 原理：
--   检查 opts.args 是否包含非空白字符（%S 匹配任意非空白）。
--   如果有参数，按空白分割为数组后逐个更新；
--   如果无参数，调用无参版本更新所有插件。
--
-- nargs = "*" 表示接受 0 个或多个参数。
vim.api.nvim_create_user_command("PackUpdate", function(opts)
	-- 检查是否有传入任何参数（包含非空白字符）
	if opts.args:match("%S") then
		-- 按空白字符分割参数，trimempty 去除空字符串
		local plugins = vim.split(opts.args, "%s+", { trimempty = true })
		-- 仅更新指定的插件
		vim.pack.update(plugins)
	else
		-- 无参数，更新所有插件
		vim.pack.update()
	end
end, { nargs = "*", desc = "更新所有插件或指定插件" })

-- ---------------------------------------------------------------------------
-- :PackClean — 清理已从配置移除的插件
-- ---------------------------------------------------------------------------
-- 用法：:PackClean
--
-- 原理：
--   从 vim.pack.get() 获取所有 vim.pack 管理的插件，
--   过滤出 active = false 的插件（即从 pack.lua 移除后未加载的），
--   批量调用 vim.pack.del() 删除本地文件。
--   如果没有需要清理的插件，会提示 "No unused plugins to clean"。
--
-- 注意：
--   必须先 :restart Neovim，让 vim.pack 识别到插件已不在当前配置中，
--   否则 active 仍为 true，不会被清理。
vim.api.nvim_create_user_command("PackClean", function()
	local to_clean = vim.iter(vim.pack.get())
		:filter(function(x) return not x.active end)
		:map(function(x) return x.spec.name end)
		:totable()

	if #to_clean == 0 then
		vim.notify("No unused plugins to clean", vim.log.levels.INFO)
		return
	end

	vim.pack.del(to_clean)
	vim.notify("Cleaned " .. #to_clean .. " plugin(s): " .. table.concat(to_clean, ", "), vim.log.levels.INFO)
end, { desc = "删除已从配置移除的本地插件" })
