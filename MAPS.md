# 键位映射

> Leader = 空格

## 文件查找（mini.pick）

| 键位               | 动作                             |
| ------------------ | -------------------------------- |
| `<leader>ff`       | 查找文件                         |
| `<leader>fw`       | 实时 grep（项目中搜索文本）      |
| `<leader>fa`       | 查找所有文件（含隐藏和忽略）     |
| `<leader>fh`       | 搜索帮助标签                     |
| `<leader>fo`       | 最近打开的文件                   |
| `<leader>fz`       | 当前缓冲区行内搜索               |
| `<leader>sk`       | 搜索键位映射                     |
| `<leader><leader>` | Buffer 列表（支持 `<C-d>` 删除） |
| `<leader>ft`       | 切换文件类型                     |

## 文件浏览器（mini.files）

| 键位 | 动作                                   |
| ---- | -------------------------------------- |
| `-`  | 在当前文件所在目录打开文件浏览器       |
| `_`  | 在项目根目录（git root）打开文件浏览器 |

## Git

| 键位          | 动作                          |
| ------------- | ----------------------------- |
| `<leader>gg`  | Neogit status（新标签页）     |
| `<leader>gd`  | CodeDiff 工作区 diff          |
| `<leader>gl`  | CodeDiff 提交历史（全仓库）   |
| `<leader>gD`  | CodeDiff 当前文件历史         |
| `<leader>ghp` | 预览当前 hunk（gitsigns）     |
| `<leader>ghb` | Blame 当前行（gitsigns）      |
| `<leader>ghB` | Blame 整个文件（gitsigns）    |
| `<leader>ghs` | Stage hunk（gitsigns）        |
| `<leader>ghr` | Reset hunk（gitsigns）        |
| `<leader>ghS` | Stage 整个 buffer（gitsigns） |
| `<leader>ghR` | Reset 整个 buffer（gitsigns） |
| `<leader>ghu` | 撤销 stage hunk（gitsigns）   |
| `<leader>ghd` | Diff this（vs index）         |
| `<leader>ghD` | Diff this ~（vs HEAD）        |
| `]h` / `[h`   | 下一个 / 上一个 hunk          |
| `]H` / `[H`   | 最后 / 第一个 hunk            |
| `<leader>sr`  | 搜索并替换（grug-far）        |

## LSP 与诊断

| 键位         | 动作                |
| ------------ | ------------------- |
| `gd`         | 跳转到定义          |
| `gh`         | 悬停查看文档        |
| `<leader>ca` | 代码操作            |
| `<leader>cr` | 重命名符号          |
| `<leader>fm` | 格式化当前 Buffer   |
| `df`         | 显示行诊断浮动窗口  |
| `<leader>ds` | 诊断位置列表        |
| `]d` / `[d`  | 下一个 / 上一个诊断 |
| `]e` / `[e`  | 下一个 / 上一个错误 |
| `]w` / `[w`  | 下一个 / 上一个警告 |

## Buffer 管理

| 键位         | 动作            |
| ------------ | --------------- |
| `<leader>x`  | 关闭当前 Buffer |
| `<leader>bn` | 新建 Buffer     |
| `<leader>bo` | 关闭其他 Buffer |

## 编辑与搜索

| 键位         | 动作                                 |
| ------------ | ------------------------------------ |
| `<leader>tm` | 切换 Markdown 渲染 (render-markdown) |
| `<leader>ss` | 全局替换光标下的单词                 |
| `<leader>ud` | 打开内置撤销树                       |
| `<leader>uf` | 切换全局自动格式化                   |
| `<leader>uF` | 切换当前 Buffer 自动格式化           |
| `<Esc>`      | 清除搜索高亮                         |
| `J`          | 合并行且不移动光标                   |

## 代码折叠（Treesitter Fold）

| 键位        | 动作                                |
| ----------- | ----------------------------------- |
| `za`        | 切换（折叠/展开）当前光标下的代码块 |
| `zc`        | 折叠（关闭）当前代码块              |
| `zo`        | 展开（打开）当前代码块              |
| `zC`        | 递归折叠当前代码块及内部所有嵌套块  |
| `zO`        | 递归展开当前代码块及内部所有嵌套块  |
| `zM`        | 关闭（折叠）文件中的所有代码块      |
| `zR`        | 打开（展开）文件中的所有代码块      |
| `zj` / `zk` | 跳转到下一个 / 上一个折叠位置       |

## 窗口与标签

| 键位          | 动作           |
| ------------- | -------------- |
| `<C-h/j/k/l>` | 窗口间快速跳转 |
| `<leader>tc`  | 关闭当前标签页 |
| `<leader>tn`  | 新建标签页     |
| `<leader>]`   | 下一个标签页   |
| `<leader>[`   | 上一个标签页   |

## 终端

| 键位         | 动作                   |
| ------------ | ---------------------- |
| `<leader>tt` | 打开新终端             |
| `<C-x>`      | 从终端模式返回普通模式 |

## 文件操作

| 键位         | 动作                     |
| ------------ | ------------------------ |
| `<C-s>`      | 保存文件                 |
| `<C-c>`      | 复制整个文件内容到剪贴板 |
| `<leader>yp` | 复制相对文件路径         |
| `<leader>yP` | 复制绝对文件路径         |
