# AGENTS.md

This is a personal Neovim configuration targeting **Neovim 0.12+**. It lives at `~/.config/nvim` and is **not** a traditional software project — there is no build system, test suite, or package manager outside Neovim itself.

## Critical Architecture Notes

- **Plugin manager**: Neovim 0.12+ built-in `vim.pack` (not lazy.nvim / packer). Plugins are declared in `lua/pack.lua` via `vim.pack.add({ urls }, { load = false })` and tracked in `nvim-pack-lock.json`.
- **Custom lazy-loading**: `lua/lazy.lua` is a ~35-line custom framework (unrelated to lazy.nvim). It provides `load()`, `on_event()`, `on_keys()`, `on_cmd()` and tracks loaded modules in `M._loaded`.
- **Mini.nvim monorepo**: Most UI/functionality comes from the single `mini.nvim` package. Its submodules (starter, pick, extra, files, icons, notify, cmdline, completion, snippets, diff, surround, ai, cursorword, pairs) are configured individually in `lua/pack.lua` or on-demand.

## File Loading Order

```
init.lua      → disables ~20 built-in plugins, sets colorscheme, loads core modules
options.lua   → global vim options, yank highlighting, fold settings
keymaps.lua   → keymaps (leader = space)
autocmds.lua  → cursor restore, comment continuation, fold setup
usercmds.lua  → :PackAdd, :PackDel, :PackUpdate
pack.lua      → plugin declarations + lazy-loading bindings
```

## Plugin Commands

```vim
:PackAdd user/repo       " add plugin
:PackDel plugin-name     " delete plugin
:PackUpdate [name]       " update all or specific plugin
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
nvim --startuptime /tmp/startup.log +q
```

There is no traditional lint, typecheck, or test command. The validation commands above are the only verification steps.

## Lazy-Loading Strategy

When adding new plugins that should load lazily, use the custom framework in `lua/lazy.lua` — do **not** use lazy.nvim patterns.

| Trigger       | Plugins / Modules                    |
|---------------|--------------------------------------|
| `VimEnter`    | treesitter, lsp, icons               |
| `InsertEnter` | completion, snippets, pairs          |
| `BufReadPost` | diff, surround, ai, cursorword       |
| `BufWritePre` | conform (format-on-save)             |
| Key press     | pick, files, fugitive, grugfar       |
| Command       | ex-colors (`:ExColors`)              |

## LSP & Formatting

- **LSP servers enabled**: html, cssls, gopls, vtsls, rust_analyzer, lua_ls, taplo, svelte, dartls, kotlin_lsp
- **Lua LSP**: `vim` is declared as a global in `lua_ls` settings to suppress "Undefined global" diagnostics
- **Formatters by filetype**:
  - `lua` → stylua
  - `go` → gofumpt, goimports
  - `js/ts/json/css/html/md` → biome (if `biome.json` found) or prettier
  - `toml` → taplo
- **Toggle autoformat**: `vim.b[bufnr].autoformat = false` (buffer) or `vim.g.autoformat = false` (global)

## Key Conventions

- Startup performance is a priority. Heavy modules are deferred to `VimEnter` or later. Clipboard is set via `vim.schedule()` to avoid blocking.
- The active colorscheme is `ex-catppuccin-mocha`, defined in `colors/ex-catppuccin-mocha.lua`.
- Comments and UI strings are in **Chinese**.
