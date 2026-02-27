local user_command = vim.api.nvim_create_user_command

-- 定义复制相对路径的函数
local function copy_relative_path()
  local absolute_path = vim.api.nvim_buf_get_name(0)
  local relative_path = vim.fn.fnamemodify(absolute_path, ":~:.")
  vim.fn.setreg("+", relative_path)
  vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
end

-- 定义复制绝对路径的函数
local function copy_absolute_path()
  local absolute_path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg("+", absolute_path)
  vim.notify("Copied absolute path: " .. absolute_path, vim.log.levels.INFO)
end

-- 定义选择图片的函数
local function select_image()
  Snacks.picker.files({
    ft = { "jpg", "jpeg", "png", "webp" },
    layout = {
      preview = "main",
      preset = "ivy",
    },
    confirm = function(self, item, _)
      self:close()
      require("img-clip").paste_image({}, "./" .. item.file) -- ./ is necessary for img-clip to recognize it as path
    end,
  })
end

-- 定义 Difft 命令
user_command("Difft", function()
  vim.cmd("windo diffthis")
end, {
  desc = "windo Diffthis",
})

-- 定义 Diffo 命令
user_command("Diffo", function()
  vim.cmd("windo diffoff")
end, {
  desc = "windo Diffoff",
})

-- 定义 CPRelative 命令：复制当前缓冲区文件的相对路径
user_command("CPrelative", copy_relative_path, {
  desc = "Copy current buffer file relative path to clipboard",
})

-- 定义 CPAbsolute 命令：复制当前缓冲区文件的绝对路径
user_command("CPabsolute", copy_absolute_path, {
  desc = "Copy current buffer file absolute path to clipboard",
})

-- 定义 Simg 命令：选择图片
user_command("Simg", select_image, {
  desc = "Select image with snacks",
})

-- 定义按百分比调整垂直宽度的命令
user_command("Varp", function(opts)
  local percentage = tonumber(opts.args)
  if percentage and percentage > 0 and percentage <= 100 then
    local columns = vim.o.columns
    local target_width = math.floor(columns * (percentage / 100))
    vim.cmd("vertical resize " .. target_width)
  else
    vim.notify("请输入有效的百分比 (1-100)", vim.log.levels.ERROR)
  end
end, { nargs = 1, desc = "Resize vertical window to percentage of screen width" })

-- 定义按百分比调整水平高度的命令
user_command("Harp", function(opts)
  local percentage = tonumber(opts.args)
  if percentage and percentage > 0 and percentage <= 100 then
    local lines = vim.o.lines
    local target_height = math.floor(lines * (percentage / 100))
    vim.cmd("horizontal resize " .. target_height)
  else
    vim.notify("请输入有效的百分比 (1-100)", vim.log.levels.ERROR)
  end
end, { nargs = 1, desc = "Resize horizontal window to percentage of screen height" })

-- 导出函数供其他文件使用
return {
  copy_relative_path = copy_relative_path,
  copy_absolute_path = copy_absolute_path,
  select_image = select_image,
}
