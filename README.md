# Neovim Config

Personal Neovim configuration for **0.12+**.

## Highlights

- **Built-in plugin manager** — `vim.pack` (Neovim 0.12+), no lazy.nvim/packer
- **Custom lazy-loading** — `lua/lazy.lua` (~35 lines), defers heavy modules via `on_event`/`on_keys`/`load`
- **mini.nvim monorepo** — starter, pick, files, icons, notify, cmdline, completion, snippets, diff, surround
- **LSP + Formatting** — nvim-lspconfig + mason + conform.nvim, format-on-save
- **Fast startup** — disables ~20 built-in plugins, clipboard deferred via `vim.schedule()`
- **Startup dashboard** — ASCII logo + live module count + startup timing

## Lazy Loading

| Trigger       | Plugins                              |
|---------------|--------------------------------------|
| `VimEnter`    | treesitter, lsp, icons               |
| `InsertEnter` | completion, snippets                 |
| `BufReadPost` | diff, surround                       |
| `BufWritePre` | conform                              |
| Key press     | pick, files, fugitive, grugfar       |

## Keymaps (Leader = Space)

| Key           | Action                          |
|---------------|---------------------------------|
| `<leader>ff`  | Find files                      |
| `<leader>fw`  | Live grep                       |
| `<leader><leader>` | Buffer picker            |
| `<leader>-` / `-` | File browser (cwd / current) |
| `<leader>gg`  | Fugitive git                    |
| `<leader>sr`  | Search & replace (grug-far)     |
| `<leader>fm`  | Format buffer                   |
| `gd` / `gh`   | Go to definition / hover        |
| `]d` / `[d`   | Next / prev diagnostic          |
| `<leader>u`   | Undotree                        |

## Commands

```vim
:PackAdd user/repo     " Add a plugin
:PackDel plugin-name   " Delete a plugin
:PackUpdate [name]     " Update all or specific plugin
```

## Structure

```
init.lua           -- Entry point, disable built-ins
lua/options.lua    -- Global options
lua/keymaps.lua    -- Keymaps
lua/autocmds.lua   -- Autocmds
lua/usercmds.lua   -- :PackAdd / :PackDel / :PackUpdate
lua/pack.lua       -- Plugin declarations + lazy bindings
lua/lsp.lua        -- LSP + conform formatting
lua/treesitter.lua -- Deferred parser install
lua/lazy.lua       -- Custom lazy-loading primitives
lua/pick.lua       -- mini.pick wrappers
lua/git.lua        -- Git utilities
nvim-pack-lock.json -- Lock file
```
