# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 NvChad v2.5 的 Neovim 配置，使用 lazy.nvim 作为插件管理器。配置采用模块化结构，用户自定义配置与 NvChad 核心分离。

## 架构结构

```
init.lua              - 入口点：设置 leader 键、bootstrap lazy.nvim、加载插件
lua/chadrc.lua        - NvChad UI 配置（主题、状态栏、启动页）
lua/options.lua       - Vim 选项（cursorline、clipboard、tabstop 等）
lua/mappings.lua      - 自定义快捷键映射
lua/plugins/init.lua  - 用户插件列表
lua/configs/          - 插件配置目录（lazy.lua、lspconfig.lua、conform.lua）
NvChad/               - NvChad 核心模块（v2.5）
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

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `;` | n | 进入命令模式 |
| `<C-x>` | t | 退出终端 |
| `<leader>tt` | n | 打开终端 |
| `<leader>tc` | n | 关闭标签页 |
| `<leader>tn` | n | 新建标签页 |
| `<leader>]` / `[` | n | 下/上一个标签页 |
| `<leader>ss` | v | 可视选择内搜索替换 |
| `$` | n/v | 移动到行尾非空白字符（`g_`） |

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

## Neovim 版本要求

需要 Neovim 0.11+（NvChad v2.5 要求）。