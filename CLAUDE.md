# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 NvChad v2.5 的 Neovim 配置，使用 lazy.nvim 作为插件管理器。配置采用模块化结构，用户自定义配置与 NvChad 核心分离。

## 常用命令

| 命令            | 用途                             |
| --------------- | -------------------------------- |
| `:Lazy`         | 打开插件管理器界面               |
| `:Lazy sync`    | 同步插件（安装/更新/清理）       |
| `:Lazy install` | 安装新插件                       |
| `:Lazy update`  | 更新所有插件                     |
| `:Lazy clean`   | 清理未使用的插件                 |
| `:Mason`        | 打开 LSP/linter/formatter 管理器 |
| `:Cheatsheet`   | 查看 NvChad 快捷键速查表         |
| `:Nvdash`       | 打开启动页                       |
| `:GrugFar`      | 打开搜索替换界面                 |

## 架构结构

```
init.lua              - 入口点：设置 leader 键、bootstrap lazy.nvim、加载插件
lua/chadrc.lua        - NvChad UI 配置（主题、状态栏、启动页）
lua/options.lua       - Vim 选项（cursorline、clipboard、tabstop 等）
lua/mappings.lua      - 自定义快捷键映射
lua/plugins/init.lua  - 用户插件列表
lua/configs/          - 插件配置目录（lazy.lua、lspconfig.lua、conform.lua）
```

## 关键配置说明

### 插件管理

使用 lazy.nvim，配置在 `lua/configs/lazy.lua`。默认所有插件懒加载（`lazy = true`）。添加新插件时在 `lua/plugins/init.lua` 中定义。

### LSP 配置

LSP 服务器通过 `vim.lsp.enable()` 启用（Neovim 0.11+ 新 API）。当前启用的服务器：`html`、`cssls`。配置文件：`lua/configs/lspconfig.lua`。

### 格式化

使用 conform.nvim，配置在 `lua/configs/conform.lua`。当前仅配置 Lua 使用 stylua。

### 文件浏览器

使用 oil.nvim 替代 netrw（已在 lazy.lua 中禁用 netrw 相关插件）。快捷键：

- `-` 打开父目录
- `_` 打开当前工作目录

## 自定义快捷键

| 快捷键            | 模式 | 功能                                     |
| ----------------- | ---- | ---------------------------------------- |
| `;`               | n    | 进入命令模式                             |
| `<C-x>`           | t    | 退出终端                                 |
| `<leader>tt`      | n    | 打开终端                                 |
| `<leader>tc`      | n    | 关闭标签页                               |
| `<leader>tn`      | n    | 新建标签页                               |
| `<leader>]` / `[` | n    | 下/上一个标签页                          |
| `<leader>ss`      | v    | 可视选择内搜索替换                       |
| `<leader>sr`      | n/v  | GrugFar 搜索替换（自动过滤当前文件类型） |
| `<leader>ft`      | n    | Telescope 切换文件类型                   |
| `<leader>fr`      | n    | Telescope 恢复上次搜索                   |
| `gh`              | n    | LSP hover 显示文档                       |
| `$`               | n/v  | 移动到行尾非空白字符（`g_`）             |
| `>` / `<`         | v    | 缩进并保持可视模式                       |
| `]h` / `[h`       | n    | 跳转到下/上一个 Git hunk                 |
| `-`               | n    | Oil 打开父目录                           |
| `_`               | n    | Oil 打开当前工作目录                     |

### Git 快捷键（gitsigns，`<leader>gh` 前缀）

| 快捷键        | 功能            |
| ------------- | --------------- |
| `<leader>ghs` | Stage hunk      |
| `<leader>ghr` | Reset hunk      |
| `<leader>ghS` | Stage buffer    |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk    |
| `<leader>ghb` | Blame line      |
| `<leader>ghd` | Diff this       |

## NvChad 配置要点

`lua/chadrc.lua` 的结构需与 [nvconfig.lua](https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua) 保持一致。

当前设置：

- 主题：catppuccin
- 启动页：nvdash（启动时加载）
- 状态栏分隔符：round 风格

## 修改配置的最佳实践

1. **添加插件**：在 `lua/plugins/init.lua` 中添加，遵循 lazy.nvim 规范
2. **修改 UI**：在 `lua/chadrc.lua` 的 `M.ui` 中配置
3. **添加快捷键**：在 `lua/mappings.lua` 中使用 `vim.keymap.set()`
4. **修改 Vim 选项**：在 `lua/options.lua` 中添加
5. **调试配置**：使用 `:Lazy log` 查看插件加载日志，`:messages` 查看 Neovim 消息

## 开发调试技巧

- 修改配置后运行 `:Lazy sync` 或重启 Neovim
- LSP 问题检查：`:LspInfo` 查看当前 buffer 的 LSP 状态
- 格式化问题：`:ConformInfo` 查看 conform.nvim 状态
- 查看 Lua 错误：`:lua print(vim.inspect(...))` 或 `:= vim.inspect(...)`

## Neovim 版本要求

需要 Neovim 0.11+（NvChad v2.5 要求）。

