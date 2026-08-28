# Plugins

本文件记录当前配置中启用的插件包、`mini.nvim` 子模块及其加载时机。插件声明位于
`lua/pack.lua`，功能配置位于 `lua/plugins/*.lua`。

## 插件包

| 插件 | 仓库 | 用途 | 加载时机 |
| ---- | ---- | ---- | -------- |
| **mini.nvim** | [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim) | 单体插件集，提供 UI、查找、文件浏览、补全等模块 | 按子模块加载 |
| **friendly-snippets** | [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | 社区代码片段集合 | `InsertEnter` |
| **nvim-treesitter** | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 语法树解析、语法高亮与代码折叠 | `VimEnter` |
| **nvim-lspconfig** | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP 服务器配置 | 代码文件类型首次出现时 |
| **mason.nvim** | [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | LSP、DAP 与格式化工具安装管理 | 代码文件类型或 Mason 命令 |
| **conform.nvim** | [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | 代码格式化与保存时格式化 | `BufWritePre` 或 `<leader>fm` |
| **gitsigns.nvim** | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter、hunk 导航与操作 | `BufReadPost` |
| **plenary.nvim** | [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Neogit 的依赖库 | `<leader>gg` 前置加载 |
| **neogit** | [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit) | 仓库级 Git status、提交、推送与拉取 | `<leader>gg` |
| **codediff.nvim** | [esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim) | side-by-side 工作区 diff 与提交历史 | `<leader>gd` / `<leader>gl` / `<leader>gD` |
| **grug-far.nvim** | [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | 项目级搜索与替换 | `<leader>sr` |
| **render-markdown.nvim** | [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | 在 buffer 内实时渲染 Markdown 元素 | Markdown 类 `FileType`、`<leader>tm` 或 `:RenderMarkdown` |

## mini.nvim 子模块

| 模块 | 用途 | 加载时机 |
| ---- | ---- | -------- |
| **mini.starter** | 启动页、Neovim Logo、启动耗时与模块统计 | 启动时 |
| **mini.notify** | 浮动通知窗口，替换默认 `vim.notify` | 启动时 |
| **mini.cmdline** | 增强命令行界面 | 首次按 `:` |
| **mini.icons** | 文件类型图标 | `VimEnter` |
| **mini.statusline** | 全局状态栏 | `VimEnter` |
| **mini.clue** | `<leader>`、Git、折叠、窗口等前缀的按键提示 | `VimEnter` |
| **mini.pick** | 文件、内容、帮助、最近文件与 buffer 查找 | 对应 picker 按键 |
| **mini.extra** | `mini.pick` 的 keymap、oldfiles、buffer 行等扩展 | 对应 picker 按键 |
| **mini.files** | 悬浮文件浏览器 | `-` 或 `_` |
| **mini.pairs** | 自动括号配对 | `InsertEnter` |
| **mini.ai** | 扩展 `a` / `i` textobject | `BufReadPost` |
| **mini.cursorword** | 高亮光标下的相同单词 | `BufReadPost` |
| **mini.surround** | `ys` / `ds` / `cs` 环绕文本操作 | `BufReadPost` |
| **mini.completion** | LSP 与 buffer 自动补全 | `InsertEnter` |
| **mini.snippets** | 代码片段展开与 LSP snippet 服务 | `InsertEnter`，同时加载 `friendly-snippets` |

## LSP 与格式化

### LSP 服务器

首次打开代码文件时，配置会检查对应可执行文件；仅启用本机实际可用的服务器：

| 服务器 | 可执行文件 | 支持类型 |
| ------ | ----------- | -------- |
| `html` | `vscode-html-language-server` | HTML |
| `cssls` | `vscode-css-language-server` | CSS、SCSS、Less |
| `gopls` | `gopls` | Go、Go Modules、Go Workspaces、Go Templates |
| `vtsls` | `vtsls` | JavaScript、TypeScript、JSX、TSX |
| `lua_ls` | `lua-language-server` | Lua |
| `taplo` | `taplo` | TOML |
| `svelte` | `svelteserver` | Svelte |
| `kotlin_lsp` | `intellij-server` | Kotlin |
| `rust_analyzer` | `rust-analyzer` | Rust；打开 Rust 文件后异步验证 |

### 格式化器

| 文件类型 | 格式化器 |
| -------- | -------- |
| Lua | `stylua` |
| Go | `gofumpt`，然后 `goimports` |
| JavaScript、TypeScript、JSX、TSX、JSON、JSONC | 检测到 `biome.json` / `biome.jsonc` 时使用 Biome，否则使用 `prettierd` |
| CSS、HTML、Markdown | `prettierd` |
| TOML | `taplo` |

保存时自动格式化可通过 `<leader>uf` 关闭全局功能，或通过 `<leader>uF` 只关闭当前
buffer。完整键位说明见 [MAPS.md](./MAPS.md)。
