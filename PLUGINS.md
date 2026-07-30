# Plugins

本文件列出当前 Neovim 配置中使用的所有插件。

## 插件列表

### 核心插件

| 插件                     | 仓库                                                                                                      | 用途                                       |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **mini.nvim**            | [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim)                                             | 单体插件集，提供多种 UI/功能模块           |
| **nvim-treesitter**      | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                     | 语法树解析与语法高亮                       |
| **nvim-lspconfig**       | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                         | LSP 客户端预设配置                         |
| **mason.nvim**           | [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim)                                           | LSP/DAP/格式化工具安装管理                 |
| **conform.nvim**         | [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)                                         | 代码格式化（保存时自动格式化）             |
| **gitsigns.nvim**        | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                     | Git inline gutter + hunk 操作（buffer 级） |
| **neogit**               | [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)                                                   | Git status 客户端（仓库级，依赖 plenary）  |
| **codediff.nvim**        | [esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim)                                   | side-by-side diff 可视化（文件级）         |
| **grug-far.nvim**        | [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)                                     | 搜索与替换                                 |
| **render-markdown.nvim** | [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Buffer 内实时渲染 Markdown 元素            |
| **friendly-snippets**    | [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)                           | 社区代码片段集合                           |

### mini.nvim 子模块

| 模块                | 用途                              | 加载方式             |
| ------------------- | --------------------------------- | -------------------- |
| **mini.starter**    | 启动页（Neovim Logo + 启动耗时）  | 直接加载             |
| **mini.files**      | 悬浮文件浏览器                    | 按键触发 (`-` / `_`) |
| **mini.icons**      | 文件类型图标                      | VimEnter 延迟加载    |
| **mini.notify**     | 浮动通知消息                      | 直接加载             |
| **mini.pairs**      | 自动括号配对                      | InsertEnter 懒加载   |
| **mini.ai**         | 扩展 textobject（函数、参数等）   | BufReadPost 懒加载   |
| **mini.cursorword** | 自动高亮光标下相同单词            | BufReadPost 懒加载   |
| **mini.cmdline**    | 增强命令行界面                    | 首次按 `:` 触发      |
| **mini.pick**       | 文件/内容查找器                   | 按键触发             |
| **mini.extra**      | pick 扩展（keymaps、oldfiles 等） | 按键触发             |
| **mini.completion** | 自动补全引擎（LSP + Buffer）      | InsertEnter 懒加载   |
| **mini.snippets**   | 代码片段引擎                      | InsertEnter 懒加载   |
| **mini.surround**   | 环绕文本操作（括号、引号等）      | BufReadPost 懒加载   |
