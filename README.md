# Neovim 配置

个人 Neovim 配置，目标版本 **0.12+**。

![screenshot-1](https://raw.githubusercontent.com/DefectingCat/static/a6768b23b6014ebf02a6e38631682690613492cc/neovim/neovim-1.png)

## 核心特性

- **内置插件管理器** — `vim.pack`（Neovim 0.12+），无需 lazy.nvim / packer
- **自定义懒加载框架** — `lua/lazy.lua`，通过 `on_event` / `on_keys` / `load` 延迟加载重型模块
- **mini.nvim 单体插件集** — starter、pick、extra、files、icons、notify、cmdline、completion、snippets、surround、ai、cursorword、pairs
- **LSP + 代码格式化** — nvim-lspconfig + mason + conform.nvim，保存时自动格式化，支持全局/Buffer 级别开关
- **快速启动** — 禁用约 20 个内置插件，尝试启用 Neovim 0.12+ 内置 UI 增强 (`vim._core.ui2`，不可用时跳过)
- **启动仪表盘** — ASCII Logo + 实时模块加载统计 + 同步配置段耗时（不含后续插件扫描与 `VimEnter`）
- **默认主题** — [DefectingCat/clay.nvim](https://github.com/DefectingCat/clay.nvim) 提供的 `clay`，由 `vim.pack` 管理

## 懒加载策略

| 触发条件                       | 插件                                                                    |
| ------------------------------ | ----------------------------------------------------------------------- |
| 启动阶段                       | treesitter（parser 安装检查延后 100ms）                                 |
| `VimEnter`                     | icons、statusline、clue                                                 |
| 普通 buffer 的 `FileType`     | lsp、mason（服务器按自身 filetypes 匹配）                               |
| `InsertEnter`                  | completion、snippets、pairs                                             |
| `BufReadPost` / `BufWritePost` | gitsigns                                                                |
| `BufReadPost` / `BufNewFile` / `BufNew` | surround、ai、cursorword                                        |
| `BufWritePre` 或 `<leader>fm`  | conform                                                                 |
| 按键触发                       | pick、files、neogit、codediff、grugfar、md-render                        |
| 首次按 `:`                     | cmdline                                                                 |
| 命令触发                       | md-render、Mason（原生 `CmdUndefined`）                                 |

## 系统依赖

| 依赖 | 用途 |
| ---- | ---- |
| Neovim 0.12+、Git | 运行配置、安装和更新插件，以及 Git 工作流 |
| ripgrep（`rg`） | 文件查找、项目内搜索与替换 |
| `tree-sitter-cli` 0.26.1+、C 编译器、`curl`、`tar` | Treesitter parser 的生成、编译与下载；CLI 通过系统包管理器安装，不使用 npm 版本 |
| LSP 服务器与格式化工具 | 按使用的语言单独安装，配置不会自动安装 Mason 工具；清单见 [PLUGINS.md](./PLUGINS.md#lsp-与格式化) |

Markdown 的文字预览不要求图形终端；图片、视频和 Mermaid 图像显示需要支持
Kitty graphics protocol 的终端，例如 Ghostty、kitty、WezTerm；Neovide 不支持这部分显示。
网络素材下载使用 `curl`，图片转换可使用 FFmpeg 或 ImageMagick，视频帧提取需要
`ffmpeg` / `ffprobe`；Mermaid 使用 `mmdc`，未安装时上游会尝试
`npx -y @mermaid-js/mermaid-cli`。

使用 Neovide 时，默认字体为 `Maple Mono Normal NF CN`；需自行安装或修改
`lua/plugins/neovide.lua` 中的 `guifont`。终端字体由终端自身配置，推荐使用 Nerd Font。

## 键位映射

完整键位映射见 [MAPS.md](./MAPS.md)。

## 开发与调试

开发相关的命令、健康检查、性能测量等见 [DEVELOPMENT.md](./DEVELOPMENT.md)。

## Plugins

[PLUGINS](./PLUGINS.md)
