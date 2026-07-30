# Neovim 配置

个人 Neovim 配置，目标版本 **0.12+**。

![screenshot-1](https://raw.githubusercontent.com/DefectingCat/static/a6768b23b6014ebf02a6e38631682690613492cc/neovim/neovim-1.png)

## 核心特性

- **内置插件管理器** — `vim.pack`（Neovim 0.12+），无需 lazy.nvim / packer
- **自定义懒加载框架** — `lua/lazy.lua`（约 35 行），通过 `on_event` / `on_keys` / `load` 延迟加载重型模块
- **mini.nvim 单体插件集** — starter、pick、extra、files、icons、notify、cmdline、completion、snippets、surround、ai、cursorword、pairs
- **LSP + 代码格式化** — nvim-lspconfig + mason + conform.nvim，保存时自动格式化，支持全局/Buffer 级别开关
- **快速启动** — 禁用约 20 个内置插件，启用 Neovim 0.12+ 内置 UI 增强 (`vim._core.ui2`)
- **启动仪表盘** — ASCII Logo + 实时模块加载统计 + 启动耗时
- **Colorscheme 优化** — `ex-colors.nvim` 提取并生成精简版 colorscheme（默认 `ex-catppuccin-mocha`）

## 懒加载策略

| 触发条件      | 插件                                   |
| ------------- | -------------------------------------- |
| `VimEnter`    | treesitter、lsp、icons                 |
| `InsertEnter` | completion、snippets、pairs            |
| `BufReadPost` | gitsigns、surround、ai、cursorword     |
| `BufWritePre` | conform                                |
| 按键触发      | pick、files、neogit、codediff、grugfar |
| `FileType` / 按键 | render-markdown (`FileType: markdown`, `<leader>tm`, `:RenderMarkdown`) |
| 首次按 `:`    | cmdline                                |
| 命令触发      | ex-colors (`:ExColors`)                |

## 键位映射

完整键位映射见 [MAPS.md](./MAPS.md)。

## 开发与调试

开发相关的命令、健康检查、性能测量等见 [DEVELOPMENT.md](./DEVELOPMENT.md)。

## Plugins

[PLUGINS](./PLUGINS.md)
