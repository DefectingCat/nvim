# Plugins

本文件记录当前配置中启用的插件包、`mini.nvim` 子模块及其加载时机。插件声明位于
`lua/pack.lua`，功能配置位于 `lua/plugins/*.lua`。

## 插件包

| 插件                     | 仓库                                                                                                      | 用途                                            | 加载时机                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------- |
| **clay.nvim**           | [DefectingCat/clay.nvim](https://github.com/DefectingCat/clay.nvim)                                       | 默认 `clay` 配色主题                            | 启动时                                                    |
| **mini.nvim**            | [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim)                                             | 单体插件集，提供 UI、查找、文件浏览、补全等模块 | 按子模块加载                                              |
| **friendly-snippets**    | [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)                           | 社区代码片段集合                                | `InsertEnter`                                             |
| **nvim-treesitter**      | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                     | parser 安装与更新、语法查询；配合原生高亮和折叠 | 启动时加载；安装检查延后，更新插件后异步同步已安装 parser |
| **nvim-lspconfig**       | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                         | LSP 服务器配置                                  | 普通 buffer 的 `FileType` 或 Mason 命令                    |
| **mason.nvim**           | [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim)                                           | LSP、DAP 与格式化工具安装管理                   | 普通 buffer 的 `FileType` 或 Mason 命令                    |
| **conform.nvim**         | [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)                                         | 代码格式化与保存时格式化                        | `BufWritePre` 或 `<leader>fm`                             |
| **gitsigns.nvim**        | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                     | Git gutter、hunk 导航与操作                     | `BufReadPost` / `BufWritePost`                            |
| **plenary.nvim**         | [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)                                         | Neogit 的依赖库                                 | `<leader>gg` 前置加载                                     |
| **neogit**               | [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)                                                   | 仓库级 Git status、提交、推送与拉取             | `<leader>gg`                                              |
| **codediff.nvim**        | [esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim)                                   | side-by-side 工作区 diff 与提交历史             | `<leader>gd` / `<leader>gl` / `<leader>gD`                |
| **grug-far.nvim**        | [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)                                     | 项目级搜索与替换                                | `<leader>sr`                                              |
| **md-render.nvim**       | [delphinus/md-render.nvim](https://github.com/delphinus/md-render.nvim)                                   | 浮动窗口内渲染 Markdown（表格、图片、Mermaid）  | `<leader>tm` 或 `:MdRender`                               |

Markdown 预览正文宽度上限为 120 列（`lua/plugins/markdown.lua` 中的
`vim.g.md_render_max_width`）；浮窗按内容自适应，宽高最多占屏幕的 80%。
需要全屏阅读时可用 `:MdRender tab`。

## mini.nvim 子模块

| 模块                | 用途                                             | 加载时机                                    |
| ------------------- | ------------------------------------------------ | ------------------------------------------- |
| **mini.starter**    | 启动页、Neovim Logo、同步配置段耗时与模块统计 | 启动时                                      |
| **mini.notify**     | 浮动通知窗口，替换默认 `vim.notify`              | 启动时                                      |
| **mini.cmdline**    | 增强命令行界面                                   | 首次按 `:`                                  |
| **mini.icons**      | 文件类型图标                                     | `VimEnter`                                  |
| **mini.statusline** | 全局状态栏                                       | `VimEnter`                                  |
| **mini.clue**       | `<leader>`、Git、折叠、窗口等前缀的按键提示      | `VimEnter`                                  |
| **mini.pick**       | 文件、内容、帮助、最近文件与 buffer 查找         | 对应 picker 按键                            |
| **mini.extra**      | `mini.pick` 的 keymap、oldfiles、buffer 行等扩展 | 对应 picker 按键                            |
| **mini.files**      | 悬浮文件浏览器                                   | `-` 或 `_`                                  |
| **mini.pairs**      | 自动括号配对                                     | `InsertEnter`                               |
| **mini.ai**         | 扩展 `a` / `i` textobject                        | `BufReadPost` / `BufNewFile` / `BufNew`      |
| **mini.cursorword** | 高亮光标下的相同单词                             | `BufReadPost` / `BufNewFile` / `BufNew`      |
| **mini.surround**   | `ys` / `ds` / `cs` 环绕文本操作                  | `BufReadPost` / `BufNewFile` / `BufNew`      |
| **mini.completion** | LSP 与 buffer 自动补全                           | `InsertEnter`                               |
| **mini.snippets**   | 代码片段展开与 LSP snippet 服务                  | `InsertEnter`，同时加载 `friendly-snippets` |

## LSP 与格式化

### LSP 服务器

普通 buffer 首次触发 `FileType` 或执行 Mason 命令时，`lua/plugins/lsp.lua`
自动检测应启用哪些服务器，无需手动维护列表；服务器按各自的 filetypes 匹配 buffer。

- **Mason 已装包自动启用**：遍历 `mason-registry` 已安装包，若某包的 registry spec 带有
  `neovim.lspconfig` 字段（如 `css-lsp` → `cssls`、`lua-language-server` → `lua_ls`、
  `tsc` → `tsc`），且本机 `nvim-lspconfig` 确实提供对应 `lsp/<name>.lua`，即启用该服务器。
  安装新包后需要重启 Neovim，让初始化阶段重新扫描 Mason 注册表。

配置只自动启用已安装的服务器，不会自动安装工具。例如需要 Lua 的语义补全、诊断和
跳转时，先执行 `:MasonInstall lua-language-server`，安装完成后重启 Neovim。
`stylua` 虽然也能作为 Lua LSP 自动启用，但只提供格式化，不能替代 `lua_ls`。

### 格式化器

| 文件类型                                      | 格式化器                                                               |
| --------------------------------------------- | ---------------------------------------------------------------------- |
| Lua                                           | `stylua`                                                               |
| Go                                            | `gofumpt`，然后 `goimports`                                            |
| JavaScript、TypeScript、JSX、TSX、JSON、JSONC | 检测到 `biome.json` / `biome.jsonc` 时使用 Biome，否则使用 `prettierd` |
| CSS、HTML、Markdown                           | `prettierd`                                                            |
| TOML                                          | `taplo`                                                                |

表中工具需通过 Mason、系统包管理器或项目依赖自行安装，并确保 Neovim 可执行。
Mason 初始化后会将其 `bin` 目录加入 Neovim 的 PATH。例如：

```vim
:MasonInstall stylua gofumpt goimports prettierd taplo
```

使用 Biome 的项目还需安装 `biome`；对应分支优先使用 `biome-check`，再尝试 `biome`，
不会因缺少 Biome 自动改用 `prettierd`。没有可用的外部格式化器时，配置会尝试回退到
已附着且支持格式化的 LSP；两者都不可用时，声明的格式化能力不会生效。

保存时自动格式化可通过 `<leader>uf` 关闭全局功能，或通过 `<leader>uF` 只关闭当前
buffer。完整键位说明见 [MAPS.md](./MAPS.md)。
