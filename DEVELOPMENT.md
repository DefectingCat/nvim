# 开发 / 验证

本配置面向 **Neovim 0.12+**，使用内置 `vim.pack` 管理插件。以下命令默认在
`~/.config/nvim`（本仓库根目录）执行。

## 文件结构

```
init.lua                   -- 入口：禁用内置插件、加载核心模块并设置 colorscheme
lua/options.lua            -- 全局选项、剪贴板与折叠默认值
lua/keymaps.lua            -- 全局键位映射（Leader = Space）
lua/autocmds.lua           -- 光标恢复、注释延续、Treesitter 折叠
lua/usercmds.lua           -- :PackAdd / :PackDel / :PackUpdate / :PackClean
lua/pack.lua               -- 插件声明、模块配置与懒加载绑定
lua/lazy.lua               -- 自定义懒加载原语（load / on_event / on_keys / on_cmd）
lua/plugins/
  lsp.lua                  -- LSP、Mason 与 conform 格式化
  treesitter.lua            -- 延迟安装 parser、按 buffer 启用高亮
  pick.lua                 -- mini.pick 封装：文件、buffer、filetype picker
  files.lua                -- mini.files 文件浏览器与文件操作映射
  git.lua                  -- gitsigns、Neogit、CodeDiff Git 工具链
  starter.lua              -- mini.starter 启动页与模块加载统计
  markdown.lua             -- render-markdown.nvim Markdown 渲染
  neovide.lua              -- Neovide GUI 专属选项与映射
colors/
  ex-catppuccin-mocha.lua  -- 当前启用的精简版 colorscheme
nvim-pack-lock.json        -- vim.pack 插件版本锁定文件
PLUGINS.md                 -- 插件列表与加载说明
MAPS.md                    -- 键位映射速查表
DEVELOPMENT.md             -- 开发、验证与常用命令
```

## 启动与懒加载顺序

`init.lua` 按以下顺序加载核心配置：

1. `options.lua`：设置全局选项。
2. `keymaps.lua`：设置 Leader 和全局映射。
3. `autocmds.lua`：注册通用自动命令。
4. `usercmds.lua`：注册 `vim.pack` 管理命令。
5. `pack.lua`：登记插件并注册各功能域的懒加载入口。
6. 应用 `ex-catppuccin-mocha` colorscheme。

重型模块不会全部在启动阶段初始化：

| 触发条件 | 模块 / 插件 |
| -------- | ----------- |
| `VimEnter` | Treesitter、`mini.icons`、`mini.statusline`、`mini.clue` |
| 代码 `FileType` 或 Mason 命令 | LSP、Mason |
| `InsertEnter` | `mini.completion`、`mini.snippets`、`friendly-snippets`、`mini.pairs` |
| `BufReadPost` | gitsigns、`mini.surround`、`mini.ai`、`mini.cursorword` |
| `BufWritePre` 或 `<leader>fm` | conform.nvim |
| 按键触发 | `mini.pick`、`mini.files`、Neogit、CodeDiff、grug-far |
| Markdown 类 `FileType`、`<leader>tm` 或 `:RenderMarkdown` | render-markdown.nvim |
| 首次按 `:` | `mini.cmdline` |

完整插件说明见 [PLUGINS.md](./PLUGINS.md)，完整映射见 [MAPS.md](./MAPS.md)。

## 语法与启动检查

```bash
# 检查完整配置并退出
nvim --headless -c 'lua dofile("init.lua")' -c 'qa!'

# 只加载插件声明与懒加载配置
nvim --headless -c 'lua require("pack")' -c 'qa!'

# 运行 Neovim 健康检查
nvim --headless -c 'checkhealth' -c 'qa!'
```

本配置没有独立的构建、lint、类型检查或测试套件；改动后至少运行完整配置检查。

## 性能测量

```bash
# 测量启动时间，日志写入 /tmp/startup.log
nvim --headless --startuptime /tmp/startup.log \
  --cmd 'autocmd VimEnter * ++once lua vim.schedule(function() vim.cmd("qa!") end)'
```

`init.lua` 中记录的启动时间只覆盖同步配置加载和 colorscheme，不包含后续
插件扫描与 `VimEnter` 回调；`--startuptime` 可用于观察完整启动过程。

## 常用命令

```vim
:PackAdd user/repo1 user/repo2  " 添加一个或多个插件
:PackDel plugin-name            " 删除插件
:PackUpdate                    " 更新全部插件
:PackUpdate name1 name2        " 更新指定插件
:PackClean                     " 清理已从 pack.lua 移除的插件
:ExColors!                     " （可选）提取当前 colorscheme 为优化版
```

`:PackClean` 前先执行 `:restart`，让 `vim.pack` 重新识别已从配置移除的插件。
`:ExColors!` 需要先在 `lua/pack.lua` 中启用并安装 `ex-colors.nvim`。
