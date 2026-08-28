# 键位映射

> Leader = 空格（`<leader>`）
>
> 下文未特别标注时均为 Normal 模式；`Visual`、`Insert`、`Terminal` 等模式会明确标出。

## 基础编辑

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `<Esc>` | Normal | 清除搜索高亮 |
| `J` | Normal | 合并当前行与下一行，光标位置保持不变 |
| `<` / `>` | Visual | 减少 / 增加缩进并保持选区 |
| `$` | Normal / Visual | 跳到行尾最后一个非空白字符 |

## 文件查找（mini.pick）

| 键位 | 动作 |
| ---- | ---- |
| `<leader>ff` | 查找文件（包含隐藏文件，但排除 `.git/`） |
| `<leader>fw` | 项目内实时 grep |
| `<leader>fa` | 查找所有文件（包含隐藏和被忽略文件，排除 `.git/`） |
| `<leader>fh` | 搜索帮助标签 |
| `<leader>fo` | 查找最近打开的文件 |
| `<leader>fz` | 搜索当前 buffer 的行 |
| `<leader>fr` | 恢复上次 picker 搜索 |
| `<leader>sk` | 搜索键位映射 |
| `<leader><leader>` | Buffer 列表；在 picker 中按 `<C-d>` 删除选中 buffer |
| `<leader>ft` | 切换当前 buffer 的文件类型 |

## 文件浏览器（mini.files）

### 从编辑器打开

| 键位 | 动作 |
| ---- | ---- |
| `-` | 在当前文件所在目录打开文件浏览器，并定位当前文件 |
| `_` | 在项目根目录（git root）打开文件浏览器 |

### 文件浏览器内部

| 键位 | 动作 |
| ---- | ---- |
| `<CR>` | 目录：进入；文件：打开并关闭文件浏览器 |
| `<C-l>` | 进入目录或打开文件，并同步光标位置 |
| `_` | 返回上级目录 |
| `<C-h>` | 返回上级目录，并同步光标位置 |
| `<leader>yp` | 复制光标下条目的相对路径 |
| `<leader>yP` | 复制光标下条目的绝对路径 |
| `<C-s>` | 同步文件系统变更；纯创建操作免确认 |

## Git

### gitsigns（已打开文件的 buffer）

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `]h` / `[h` | Normal | 下一个 / 上一个 hunk |
| `]H` / `[H` | Normal | 最后一个 / 第一个 hunk |
| `<leader>ghp` | Normal | 预览当前 hunk |
| `<leader>ghb` | Normal | Blame 当前行 |
| `<leader>ghB` | Normal | Blame 整个文件 |
| `<leader>ghs` | Normal / Visual | Stage hunk |
| `<leader>ghr` | Normal / Visual | Reset hunk |
| `<leader>ghS` | Normal | Stage 整个 buffer |
| `<leader>ghR` | Normal | Reset 整个 buffer |
| `<leader>ghu` | Normal | 撤销 stage hunk |
| `<leader>ghd` | Normal | Diff this（对比 index） |
| `<leader>ghD` | Normal | Diff this ~（对比 HEAD） |
| `ih` | Operator / Visual | 选择当前 hunk |

### Neogit

| 键位 | 动作 |
| ---- | ---- |
| `<leader>gg` | 在新标签页打开 Neogit status |

### CodeDiff

| 键位 | 动作 |
| ---- | ---- |
| `<leader>gd` | 打开工作区 diff |
| `<leader>gl` | 查看全仓库提交历史 |
| `<leader>gD` | 查看当前文件提交历史 |

CodeDiff 视图内还提供：

| 键位 | 动作 |
| ---- | ---- |
| `q` | 退出 diff 视图 |
| `]c` / `[c` | 下一个 / 上一个 hunk |
| `]f` / `[f` | 下一个 / 上一个文件 |
| `do` / `dp` | 从另一侧获取 / 推送当前变更 |
| `gf` | 在前一个标签页打开 |
| `<leader>gs` | Stage 当前文件 |
| `<leader>ghs` / `<leader>ghu` | Stage / Unstage 当前 hunk |
| `<leader>ghr` | 丢弃当前 hunk |
| `ih` | 选择当前 hunk |
| `g?` | 显示帮助 |
| `gm` | 对齐两侧光标 |
| `t` | 切换布局 |

## 搜索与替换

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `<leader>ss` | Normal | 全局替换光标下的单词 |
| `<leader>ss` | Visual | 只在当前选区内搜索替换 |
| `<leader>sr` | Normal / Visual | 打开 grug-far 搜索与替换 |

## Surround、补全与 Markdown

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `ys` | Normal / Operator | 添加环绕文本（如 `ysiw"`） |
| `ds` | Normal | 删除环绕文本 |
| `cs` | Normal | 替换环绕文本 |
| `<CR>` | Insert | 有补全选择时确认；无补全弹窗时执行普通换行 / 括号配对 |
| `<leader>tm` | Normal | 切换 Markdown 渲染 |

## LSP 与诊断

| 键位 | 动作 |
| ---- | ---- |
| `gd` | 跳转到定义 |
| `gh` | 悬停查看文档 |
| `<leader>ca` | 代码操作 |
| `<leader>cr` | 重命名符号 |
| `<leader>fm` | 格式化当前 buffer |
| `<leader>df` | 显示当前行诊断浮动窗口 |
| `<leader>ds` | 打开诊断位置列表 |
| `]d` / `[d` | 下一个 / 上一个诊断 |
| `]e` / `[e` | 下一个 / 上一个错误 |
| `]w` / `[w` | 下一个 / 上一个警告 |

## Buffer 管理

| 键位 | 动作 |
| ---- | ---- |
| `<leader>x` | 关闭当前 buffer；未保存时先确认 |
| `<leader>bn` | 新建空 buffer |
| `<leader>bo` | 关闭其他 buffer（保留文件浏览器等指定侧栏） |

## 窗口与标签页

| 键位 | 动作 |
| ---- | ---- |
| `<C-h/j/k/l>` | 在窗口间快速跳转 |
| `<leader>tc` | 关闭当前标签页 |
| `<leader>tn` | 新建标签页 |
| `<leader>]` / `<leader>[` | 下一个 / 上一个标签页 |

## 撤销、格式化与文件操作

| 键位 | 动作 |
| ---- | ---- |
| `<leader>ud` | 打开内置撤销树 |
| `<leader>uf` | 切换全局自动格式化 |
| `<leader>uF` | 切换当前 buffer 自动格式化 |
| `<C-s>` | 保存当前文件 |
| `<C-c>` | 复制整个文件内容到系统剪贴板 |
| `<leader>yp` | 复制相对文件路径 |
| `<leader>yP` | 复制绝对文件路径 |

## 终端

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `<leader>tt` | Normal | 打开新终端窗口 |
| `<C-x>` | Terminal | 返回 Normal 模式 |

## Neovide

仅在 Neovide GUI 中生效：

| 键位 | 模式 | 动作 |
| ---- | ---- | ---- |
| `<C-=>` | Normal | 放大界面 |
| `<C-->` | Normal | 缩小界面 |
| `<C-0>` | Normal | 重置界面缩放 |
| `<D-c>` | Visual | 复制到系统剪贴板 |
| `<D-v>` | Normal / Insert / Visual / Command / Terminal | 从系统剪贴板粘贴 |
