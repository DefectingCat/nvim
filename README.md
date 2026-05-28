# Neovim 配置

个人 Neovim 配置，目标版本 **0.12+**。

## 核心特性

- **内置插件管理器** — `vim.pack`（Neovim 0.12+），无需 lazy.nvim / packer
- **自定义懒加载框架** — `lua/lazy.lua`（约 35 行），通过 `on_event` / `on_keys` / `load` 延迟加载重型模块
- **mini.nvim 单体插件集** — starter、pick、extra、files、icons、notify、cmdline、completion、snippets、diff、surround
- **LSP + 代码格式化** — nvim-lspconfig + mason + conform.nvim，保存时自动格式化
- **快速启动** — 禁用约 20 个内置插件，剪贴板通过 `vim.schedule()` 延迟初始化
- **启动仪表盘** — ASCII Logo + 实时模块加载统计 + 启动耗时

## 懒加载策略

| 触发条件      | 插件                                 |
|---------------|--------------------------------------|
| `VimEnter`    | treesitter、lsp、icons               |
| `InsertEnter` | completion、snippets                 |
| `BufReadPost` | diff、surround                       |
| `BufWritePre` | conform                              |
| 按键触发      | pick、files、fugitive、grugfar       |

## 键位映射（Leader = 空格）

### 文件查找（mini.pick）

| 键位           | 动作                              |
|----------------|-----------------------------------|
| `<leader>ff`   | 查找文件                          |
| `<leader>fw`   | 实时 grep（项目中搜索文本）       |
| `<leader>fa`   | 查找所有文件（含隐藏和忽略）      |
| `<leader>fh`   | 搜索帮助标签                      |
| `<leader>fo`   | 最近打开的文件                    |
| `<leader>fz`   | 当前缓冲区行内搜索                |
| `<leader>sk`   | 搜索键位映射                      |
| `<leader><leader>` | Buffer 列表（支持 `<C-d>` 删除） |
| `<leader>ft`   | 切换文件类型                      |

### 文件浏览器（mini.files）

| 键位 | 动作                                  |
|------|---------------------------------------|
| `-`  | 在当前文件所在目录打开文件浏览器      |
| `_`  | 在项目根目录（git root）打开文件浏览器 |

### Git

| 键位           | 动作                     |
|----------------|--------------------------|
| `<leader>gg`   | Fugitive（全屏新标签页） |
| `<leader>gd`   | Git diff 垂直分割        |
| `<leader>ghp`  | 预览当前 hunk            |
| `<leader>ghb`  | Blame 当前行             |
| `<leader>gB`   | Blame 整个文件           |
| `<leader>gD`   | 查看文件 Git 历史        |
| `<leader>sr`   | 搜索并替换（grug-far）   |

### LSP 与诊断

| 键位         | 动作                   |
|--------------|------------------------|
| `gd`         | 跳转到定义             |
| `gh`         | 悬停查看文档           |
| `<leader>ca` | 代码操作               |
| `<leader>fm` | 格式化当前 Buffer      |
| `df`         | 显示行诊断浮动窗口     |
| `<leader>ds` | 诊断位置列表           |
| `]d` / `[d`  | 下一个 / 上一个诊断    |
| `]e` / `[e`  | 下一个 / 上一个错误    |
| `]w` / `[w`  | 下一个 / 上一个警告    |

### Buffer 管理

| 键位         | 动作               |
|--------------|--------------------|
| `<leader>x`  | 关闭当前 Buffer    |
| `<leader>bn` | 新建 Buffer        |
| `<leader>bo` | 关闭其他 Buffer    |

### 编辑与搜索

| 键位         | 动作                       |
|--------------|----------------------------|
| `<leader>ss` | 全局替换光标下的单词       |
| `<leader>u`  | 打开内置撤销树             |
| `<Esc>`      | 清除搜索高亮               |
| `J`          | 合并行且不移动光标         |

### 窗口与标签

| 键位         | 动作               |
|--------------|--------------------|
| `<C-h/j/k/l>` | 窗口间快速跳转    |
| `<leader>tc` | 关闭当前标签页     |
| `<leader>tn` | 新建标签页         |
| `<leader>]`  | 下一个标签页       |
| `<leader>[`  | 上一个标签页       |

### 终端

| 键位         | 动作                       |
|--------------|----------------------------|
| `<leader>tt` | 打开新终端                 |
| `<C-x>`      | 从终端模式返回普通模式     |

### 文件操作

| 键位         | 动作                       |
|--------------|----------------------------|
| `<C-s>`      | 保存文件                   |
| `<C-c>`      | 复制整个文件内容到剪贴板   |
| `<leader>yp` | 复制相对文件路径           |
| `<leader>yP` | 复制绝对文件路径           |

## 命令

```vim
:PackAdd user/repo     " 添加插件
:PackDel plugin-name   " 删除插件
:PackUpdate [name]     " 更新全部或指定插件
```

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
nvim-pack-lock.json     -- 插件锁定文件
colors/
  catppuccin-*.lua      -- Catppuccin 配色方案（mocha 为默认）
```

## 开发 / 验证

```bash
# 检查 init.lua 语法
nvim --headless -c 'lua dofile("init.lua")' -c 'qa!'

# 检查特定模块
nvim --headless -c 'lua require("pack")' -c 'qa!'

# 健康检查
nvim --headless -c 'checkhealth' -c 'qa!'

# 测量启动时间
nvim --startuptime /tmp/startup.log +q
```
