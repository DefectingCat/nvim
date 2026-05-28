# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal Neovim configuration (~/.config/nvim) targeting **Neovim 0.12+**. It uses Neovim's built-in `vim.pack` plugin management (available in 0.12+) rather than external plugin managers like lazy.nvim or packer.nvim.

A custom lightweight lazy-loading framework lives in `lua/lazy.lua` that wraps `on_event`/`on_keys`/`load` to defer heavy module initialization until first use.

## File Architecture

```
init.lua                  -- Entry point: disables built-in plugins, loads all core modules
lua/options.lua           -- Global vim options, highlight groups, yank highlighting
lua/keymaps.lua           -- Keymaps (leader = space), window/tab navigation, buffer mgmt
lua/autocmds.lua          -- Autocmds: restore cursor position, comment continuation, fold setup
lua/usercmds.lua          -- User commands: :PackAdd, :PackDel, :PackUpdate
lua/pack.lua              -- Plugin declarations via vim.pack.add(), mini.starter dashboard,
                          -- lazy.on_keys/on_event bindings for all deferred plugins
lua/lazy.lua              -- Custom lazy-loading primitives: load(), on_event(), on_keys()
lua/plugins/
  lsp.lua                 -- LSP config (nvim-lspconfig + mason), conform.nvim formatter
  treesitter.lua          -- Treesitter setup: deferred parser install, per-buffer attach
  pick.lua                -- mini.pick wrappers: buffer picker, filetype picker
  git.lua                 -- Custom git utilities: hunk preview, blame line, fugitive keymaps
colors/                   -- Catppuccin colorscheme variants (frappe, latte, macchiato, mocha)
nvim-pack-lock.json       -- Lock file for vim.pack managed plugins
```

## Plugin Management

Plugins are declared in `lua/pack.lua` via `vim.pack.add({ urls }, { load = false })` and tracked in `nvim-pack-lock.json`.

Available commands:
- `:PackAdd user/repo` — add a new plugin
- `:PackDel plugin-name` — delete a plugin
- `:PackUpdate [plugin-name]` — update all or specific plugins

Plugins are loaded lazily via the custom framework in `lua/lazy.lua`:
- **on_event**: triggered by autocmd (e.g., `InsertEnter`, `BufReadPost`, `VimEnter`)
- **on_keys**: triggered by keymap press (e.g., `<leader>ff`, `<leader>gg`)
- **load**: manual loading checked by `_loaded` flag

Key lazy-loading points in `pack.lua`:
- `mini.completion` / `mini.snippets` — `InsertEnter`
- `mini.diff` / `mini.surround` — `BufReadPost`
- `treesitter` / `lsp` — `VimEnter`
- `mini.pick` / `mini.extra` — key trigger (`<leader>ff`, etc.)
- `vim-fugitive` — key trigger (`<leader>gg`)
- `conform.nvim` — `BufWritePre`

## LSP and Formatting

- **LSP**: nvim-lspconfig + mason. Enabled servers: html, cssls, gopls, vtsls, rust_analyzer, lua_ls, taplo, svelte, dartls, kotlin_lsp.
- **Formatting**: conform.nvim with format-on-save. Formatters by filetype:
  - `lua` → stylua
  - `go` → gofumpt, goimports
  - `js/ts/json/css/html/md` → biome (if biome.json found) or prettier
  - `toml` → taplo
- Toggle autoformat per-buffer: `vim.b[bufnr].autoformat = false`
- Toggle autoformat globally: `vim.g.autoformat = false`

## Treesitter

Configured in `lua/plugins/treesitter.lua`. Parsers are installed lazily via `vim.defer_fn` to avoid blocking startup. Treesitter highlighting is attached per-buffer on `FileType` via `vim.treesitter.start()`.

## Key Leader Bindings (Space)

Common bindings defined across files:

**File pickers (mini.pick):**
- `<leader>ff` — find files
- `<leader>fw` — live grep
- `<leader>fa` — find all files (including hidden/ignored)
- `<leader>fh` — search help tags
- `<leader>fo` — recent files
- `<leader>fz` — current buffer lines
- `<leader>sk` — search keymaps
- `<leader><leader>` — buffer picker (supports `<C-d>` to delete)
- `<leader>ft` — filetype picker

**File browser (mini.files):**
- `-` — open at current file's directory
- `_` — open at project root (git root)

**Git:**
- `<leader>gg` — fugitive (fullscreen new tab)
- `<leader>gd` — git diff vertical split
- `<leader>ghp` — preview current hunk
- `<leader>ghb` — blame current line
- `<leader>gB` — blame entire file
- `<leader>gD` — file git history
- `<leader>sr` — search and replace (grug-far)

**LSP & diagnostics:**
- `gd` / `gh` — go to definition / hover
- `<leader>ca` — code action
- `<leader>fm` — format buffer
- `df` — show line diagnostic float
- `<leader>ds` — diagnostic location list
- `]d` / `[d` — next / prev diagnostic
- `]e` / `[e` — next / prev error
- `]w` / `[w` — next / prev warning

**Buffer management:**
- `<leader>x` — close current buffer
- `<leader>bn` — new buffer
- `<leader>bo` — close other buffers

**Editing & search:**
- `<leader>ss` — global replace word under cursor
- `<leader>u` — undotree (builtin)
- `<Esc>` — clear search highlight

**Window & tab:**
- `<C-h/j/k/l>` — navigate between windows
- `<leader>tc/tn/]/[` — tab close / new / next / prev

**Terminal:**
- `<leader>tt` — open new terminal
- `<C-x>` — exit terminal mode to normal mode

**File operations:**
- `<C-s>` — save file
- `<C-c>` — copy entire file to clipboard
- `<leader>yp` — copy relative file path
- `<leader>yP` — copy absolute file path

## Development / Validation

Since this is a Neovim config, there is no traditional build or test suite.

Validate configuration changes:
```bash
# Syntax check init.lua
nvim --headless -c 'lua dofile("init.lua")' -c 'qa!'

# Check for Lua syntax errors in a specific module
nvim --headless -c 'lua require("pack")' -c 'qa!'

# Runtime health check
nvim --headless -c 'checkhealth' -c 'qa!'
```

Check startup time after changes:
```bash
nvim --startuptime /tmp/startup.log +q
```

## Important Design Patterns

1. **Startup performance is a priority**. Heavy modules (treesitter, LSP, mason) are deferred to `VimEnter` or later. Clipboard is set via `vim.schedule()` to avoid provider detection blocking.

2. **Custom lazy-loading in `lua/lazy.lua`**. Do not confuse with the lazy.nvim plugin manager — this is a ~35-line custom module. When adding new plugins that should load lazily, use `lazy.on_event()` or `lazy.on_keys()`.

3. **mini.nvim monorepo**. Most UI/functionality comes from the single `mini.nvim` package (starter, pick, extra, files, icons, notify, cmdline, completion, snippets, diff, surround). These are configured individually in `pack.lua` or on-demand.

4. **Colorscheme**. The active colorscheme is `catppuccin-mocha`, defined in `colors/catppuccin-mocha.lua`. The `moonflyTransparent` variable is still set in `init.lua` for compatibility but the moonfly theme was removed.
