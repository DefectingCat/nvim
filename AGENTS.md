# AGENTS.md

This is a personal Neovim configuration targeting **Neovim 0.12+**. It lives at `~/.config/nvim` and is **not** a traditional software project — there is no build system, test suite, or package manager outside Neovim itself.

## Critical Architecture Notes

- **Plugin manager**: Neovim 0.12+ built-in `vim.pack` (not lazy.nvim / packer). `mini.nvim` uses `load = false` so its shared modules are immediately require-able; trigger-loaded plugins use a no-op `load` callback and explicit `:packadd`. All plugins are tracked in `nvim-pack-lock.json`.
- **Custom lazy-loading**: `lua/lazy.lua` is a ~35-line custom framework (unrelated to lazy.nvim). It provides `load()`, `on_event()`, `on_keys()`, `on_cmd()` and tracks loaded modules in `M._loaded`.
- **Mini.nvim monorepo**: Most UI/functionality comes from the single `mini.nvim` package. Its submodules (starter, pick, extra, files, icons, notify, cmdline, completion, snippets, surround, clue, statusline, ai, cursorword, pairs) are configured individually in `lua/pack.lua` or on-demand.

## File Loading Order

```
init.lua      → disables ~20 built-in plugins, sets colorscheme, loads core modules
options.lua   → global vim options, yank highlighting, fold settings
keymaps.lua   → keymaps (leader = space)
autocmds.lua  → cursor restore, comment continuation, fold setup
usercmds.lua  → :PackAdd, :PackDel, :PackUpdate, :PackClean
pack.lua      → plugin declarations + lazy-loading bindings
```

## Plugin Commands

```vim
:PackAdd user/repo       " add plugin
:PackDel plugin-name     " delete plugin
:PackUpdate [name]       " update all or specific plugin
:PackClean               " remove plugins no longer declared in pack.lua
:ExColors!               " extract current colorscheme to optimized ex-colors
```

## Validation & Debugging

```bash
# Syntax check init.lua (run from repo root)
nvim --headless -c 'lua dofile("init.lua")' -c 'qa!'

# Check a specific module
nvim --headless -c 'lua require("pack")' -c 'qa!'

# Health check
nvim --headless -c 'checkhealth' -c 'qa!'

# Measure startup time
nvim --headless --startuptime /tmp/startup.log \
  --cmd 'autocmd VimEnter * ++once lua vim.schedule(function() vim.cmd("qa!") end)'
```

There is no traditional lint, typecheck, or test command. The validation commands above are the only verification steps.

## Lazy-Loading Strategy

When adding new plugins that should load lazily, use the custom framework in `lua/lazy.lua` — do **not** use lazy.nvim patterns.

| Trigger       | Plugins / Modules                        |
| ------------- | ---------------------------------------- |
| `VimEnter`    | treesitter, icons, clue, statusline      |
| Code `FileType` | lsp, mason                             |
| `InsertEnter` | completion, snippets, pairs              |
| `BufReadPost` | gitsigns, surround, ai, cursorword       |
| `BufWritePre` | conform (format-on-save)                 |
| Key press     | pick, files, neogit, codediff, grugfar   |
| Command       | ex-colors (`:ExColors`)                  |

Note: `clue` is set up on `VimEnter` (not via `lazy.on_keys`) because `mini.clue` must register prefix keys itself as buffer-local triggers, which is incompatible with the wrapper-mapping approach. Its buffer triggers are re-asserted on `LspAttach` and inside gitsigns' `on_attach` via `MiniClue.ensure_buf_triggers()`.

## LSP & Formatting

- **LSP servers enabled**: html, cssls, gopls, vtsls, rust_analyzer, lua_ls, taplo, svelte, kotlin_lsp
- **Lua LSP**: `vim` is declared as a global in `lua_ls` settings to suppress "Undefined global" diagnostics
- **Formatters by filetype** (`lua/plugins/lsp.lua`):
  - `lua` → stylua
  - `go` → gofumpt, goimports
  - `js/ts/json/jsonc/jsx/tsx` → biome (if `biome.json`/`biome.jsonc` found upward) or prettierd
  - `css/html/markdown` → prettierd
  - `toml` → taplo
- **Toggle autoformat**: `vim.b[bufnr].autoformat = false` (buffer) or `vim.g.autoformat = false` (global). Mapped to `<leader>uf` (global) / `<leader>uF` (buffer).

## Key Conventions

- Startup performance is a priority. Heavy modules are deferred to `VimEnter` or the first relevant `FileType`. Clipboard is set via `vim.schedule()` to avoid blocking.
- The active colorscheme is `ex-catppuccin-mocha`, defined in `colors/ex-catppuccin-mocha.lua`.
- Comments and UI strings are in **Chinese**.
- Line diagnostic float is on `<leader>df`. Do **not** map bare `df` — it shadows the `df{char}` operator-pending motion (delete-until-char), a footgun previously hit in this repo.

## Git Workflow

每完成一个功能点立即提交，Agent 自主判断提交时机——当一个逻辑完整的改动通过验证（语法检查 / `nvim --headless` 模块加载通过）后，无需等待用户指令，直接 `git add` + `git commit`。

- **提交粒度按"功能点"而非"文件"**：相关联的多文件改动合并为一个提交，不相关的改动拆成多个提交。
- **提交信息格式**：遵循历史格式 `type(scope): 中文描述`
  - `type`：`feat`（新功能）、`fix`（修复）、`refactor`（重构）、`chore`（杂项）等
  - `scope`：功能域，如 `files`、`lsp`、`statusline`、`conform`、`clue`、`pack`、`pick`、`starter`、`git`、`fold` 等；跨域改动可省略 scope
  - 描述用中文，简明扼要说明"做了什么"
  - 示例：`feat(files): mini.files 中支持复制文件路径`、`fix: 修复 review 发现的 7 处问题`
- **提交前必须验证**：改动涉及哪个模块就用对应的 `nvim --headless -c 'lua require("xxx")' -c 'qa!'` 检查，确保不破坏启动。
