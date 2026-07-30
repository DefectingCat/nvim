-- =============================================================================
-- Neovide GUI 专属配置 (lua/plugins/neovide.lua)
-- =============================================================================
-- 本模块专门配置 Neovide GUI 客户端的运行时选项（字号、缩放控制、平滑动画、
-- 光标特效、窗口透明度、macOS 专属快捷键等）。
--
-- 仅在 vim.g.neovide 为真（当前处于 Neovide 环境）时生效。
-- =============================================================================

if not vim.g.neovide then
	return
end

-- =============================================================================
-- 1. 字体与实时缩放控制
-- =============================================================================
-- 默认 GUI 字体与字号 (格式: "字体名:h字号")
vim.o.guifont = "Maple Mono Normal NF CN:h15"
-- 动态缩放因子基准值 (1.0 = 100%)
vim.g.neovide_scale_factor = 1.0

-- 缩放辅助函数：按比例放大或缩小 UI
local change_scale = function(delta)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

-- 快捷键：Ctrl/Cmd + '+' 放大，Ctrl/Cmd + '-' 缩小，Ctrl/Cmd + '0' 重置
vim.keymap.set("n", "<C-=>", function()
	change_scale(1.15)
end, { desc = "Neovide 放大界面" })

vim.keymap.set("n", "<C-->", function()
	change_scale(1 / 1.15)
end, { desc = "Neovide 缩小界面" })

vim.keymap.set("n", "<C-0>", function()
	vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide 重置界面缩放" })

-- =============================================================================
-- 2. 光标动画与粒子特效 (VFX)
-- =============================================================================
-- 光标移动动画时长（单位：秒，值越小移动越快）
vim.g.neovide_cursor_animation_length = 0.12

-- 光标移动拖尾长度比例 (0.0 - 1.0)
vim.g.neovide_cursor_trail_size = 0.1

-- 切换至插入模式时保持光标动画
vim.g.neovide_cursor_animate_in_insert_mode = true

-- 光标粒子特效模式
-- 可选值: "railgun" | "torpedo" | "pixiedust" | "sonicboom" | "ripple" | "wireframe" | "" (禁用)
vim.g.neovide_cursor_vfx_mode = ""
vim.g.neovide_cursor_vfx_opacity = 200.0
vim.g.neovide_cursor_vfx_particle_lifetime = 1.2

-- =============================================================================
-- 3. 平滑滚动与刷新率
-- =============================================================================
-- 视图平滑滚动动画时长 (单位：秒)
vim.g.neovide_scroll_animation_length = 0.25

-- 目标刷新率 (设置为 0 自动匹配显示器最大刷新率，如 120Hz / 144Hz)
vim.g.neovide_refresh_rate = 0

-- =============================================================================
-- 4. 窗口透明度、毛玻璃与外观细节
-- =============================================================================
-- 全局窗口透明度 (0.0 完全透明 - 1.0 完全不透明)
vim.g.neovide_opacity = 0.95

-- 普通文本编辑区背景透明度
vim.g.neovide_normal_opacity = 0.95

-- 浮动窗口背景模糊（毛玻璃效果，支持 macOS、Windows 以及部分 Linux 合成器）
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- 启用浮动窗口阴影效果
vim.g.neovide_floating_shadow = true

-- 自动保存并恢复上一次退出时的窗口尺寸
vim.g.neovide_remember_window_size = true

-- 打字输入时自动隐藏鼠标指针
vim.g.neovide_hide_mouse_when_typing = true

-- 退出 Neovide 时弹出确认对话框
vim.g.neovide_confirm_quit = true

-- =============================================================================
-- 5. macOS 专属交互与剪贴板支持
-- =============================================================================
-- 启用 macOS Logo (Command) 键的绑定支持（映射中的 <D-...>）
vim.g.neovide_input_use_logo = true

-- 将 Option 键映射为 Meta/Alt 键
vim.g.neovide_input_macos_alt_is_meta = true

-- 快捷键：Cmd+C 复制选中文本至系统剪贴板
vim.keymap.set("v", "<D-c>", '"+y', { desc = "复制到系统剪贴板" })

-- 快捷键：Cmd+V 从系统剪贴板粘贴（支持 Normal / Insert / Visual / Command / Terminal 模式）
local function paste_clipboard()
	vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end
vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste_clipboard, { desc = "从系统剪贴板粘贴" })
