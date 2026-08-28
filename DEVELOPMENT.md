# 开发 / 验证

## 文件结构

```
init.lua                -- 入口：禁用内置插件，加载核心模块
lua/options.lua         -- 全局选项
lua/keymaps.lua         -- 键位映射
lua/autocmds.lua        -- 自动命令
lua/usercmds.lua        -- :PackAdd / :PackDel / :PackUpdate
lua/pack.lua            -- 插件声明 + 懒加载绑定
lua/lazy.lua            -- 自定义懒加载原语（load / on_event / on_keys）
lua/plugins/
  lsp.lua               -- LSP + conform 格式化
  treesitter.lua        -- 语法树：延迟安装 parser、按 buffer 启用高亮
  pick.lua              -- mini.pick 封装：buffer picker、filetype picker
  git.lua               -- Git 工具：hunk 预览、blame、文件历史
colors/
  ex-catppuccin-mocha.lua  -- 默认配色（ex-colors 生成的优化版）
  catppuccin-*.lua         -- 原始 Catppuccin 配色方案
nvim-pack-lock.json     -- 插件锁定文件
MAPS.md                 -- 键位映射速查表
DEVELOPMENT.md          -- 开发调试命令与常用指令
```

## 语法检查

```bash
# 检查 init.lua 语法
nvim --headless -c 'lua dofile("init.lua")' -c 'qa!'

# 检查特定模块
nvim --headless -c 'lua require("pack")' -c 'qa!'
```

## 健康检查

```bash
nvim --headless -c 'checkhealth' -c 'qa!'
```

## 性能测量

```bash
# 测量启动时间
nvim --headless --startuptime /tmp/startup.log \
  --cmd 'autocmd VimEnter * ++once lua vim.schedule(function() vim.cmd("qa!") end)'
```

## 常用命令

```vim
:PackAdd user/repo     " 添加插件
:PackDel plugin-name   " 删除插件
:PackUpdate [name]     " 更新全部或指定插件
:ExColors!             " 提取当前 colorscheme 为优化版 ex-colors
```
