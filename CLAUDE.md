# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration written in Lua, using **lazy.nvim** as the plugin manager. Targets modern web development (TypeScript, Vue, React) with extensive LSP support, Git integration, and AI assistance.

## Code Style

Lua formatting governed by `stylua.toml`:

- Column width: 120
- Indentation: 4 spaces
- Line endings: Unix
- Quote style: auto

Formatting on save is wired up via **conform.nvim** (`lua/plugins/formatting.lua`) with `lsp_format = "fallback"` — conform runs the configured formatter (prettier, stylua, etc.) and falls back to LSP formatting if none is mapped for the filetype.

## Architecture

### Entry Point & Loading Order

`init.lua` requires modules in this order:

1. `lua/config/options.lua` — editor options (`vim.opt`, `vim.g.loaded_*` disables)
2. `lua/core/lazy.lua` — bootstraps lazy.nvim, imports `plugins` and `plugins.lsp`
3. `lua/core/lsp.lua` — global `LspAttach` autocmd (keymaps), diagnostic config, notify filter
4. `lua/config/commands.lua` — custom `:` commands
5. `lua/config/keymaps.lua` — global keybindings
6. `lua/config/settings.lua` — autocmds, filetype behaviors, extra commands
7. `pcall(require, "config.theme")` — optional theme module kept in a separate repo

`lua/config/utils.lua` is **not** required directly from `init.lua`; it is loaded transitively by `commands.lua`/`keymaps.lua`/etc. It exposes `map()`, `buf_map()`, `command()`, `lua_command()`, and other helpers — read it before adding new keymaps or commands.

### Plugin Structure

All plugin specs live in `lua/plugins/`. Each file returns a lazy.nvim spec table (or list of tables). LSP-related specs live in `lua/plugins/lsp/` and are imported as a second import group (`{ import = "plugins.lsp" }`) by `lua/core/lazy.lua`.

### LSP Configuration

LSP is configured with the modern `vim.lsp.config(name, ...)` / mason-lspconfig flow — there is **no** `lua/lsp/` directory.

- `lua/core/lsp.lua` — `LspAttach` keymaps, diagnostic signs/float, notify filter that suppresses noisy lspconfig warnings, per-buffer auto-enable of inlay hints
- `lua/plugins/lsp/lsp.lua` — `vim.lsp.config(...)` blocks per server: `ts_ls`, `vtsls`, `vue_ls`, `jsonls`, `emmet_language_server`, `eslint`, `cssls`, `lua_ls`, `tailwindcss`
- `lua/plugins/lsp/mason.lua` — `mason-lspconfig` `ensure_installed` list (adds `html`, `svelte`, `graphql`, `prismals`, `pyright`, `gopls`) and `mason-tool-installer` for `prettier` + `stylua`

Vue/TS split (important context, see comments in `lsp.lua`):

- `ts_ls` handles `.ts`/`.js`/`.tsx`/`.jsx` only and is pinned to its bundled tsserver (workaround for a TS 5.7.2 bug with vue re-exports).
- `vtsls` handles `.vue` files and loads `@vue/typescript-plugin` from mason's `vue-language-server` package; `vue_ls` bridges to vtsls via the tsserver request channel.

Diagnostic virtual text is off by default — toggle via `:ToggleVirtualText`. Inlay hints auto-enable per buffer when the attached client supports them.

### Core LSP Keybindings (set on `LspAttach`)

`gr`=references, `gd`=definition, `gD`=declaration, `gi`=implementation, `gt`=type definition, `ga`=code actions, `gR`=rename, `gl`=line diagnostics, `K`=hover, `[d`/`]d`=prev/next diagnostic, `<leader>rs`=`:LspRestart`

### AI Plugins

- **sidekick.nvim** (`lua/plugins/sidekick.lua`) — primary AI sidebar / CLI integration (Folke)
- **supermaven-nvim** (`lua/plugins/supermaven.lua`) — installed but `condition = function() return false end` keeps inline completion disabled; cmp source still references it
- **GitHub Copilot** — installed manually in `pack/github/start/copilot.vim/`, not via lazy

(`avante.nvim` and `codeium.nvim` have been removed.)

## Key Custom Commands

Defined across `lua/config/commands.lua` and `lua/config/settings.lua`.

| Command              | Purpose                              |
| -------------------- | ------------------------------------ |
| `:LspRestart`        | Restart LSP server (buffer-scoped)   |
| `:ToggleVirtualText` | Toggle LSP diagnostic virtual text   |
| `:ToggleDiagnostics` | Toggle diagnostics on/off            |
| `:ToggleInlayHint`   | Toggle inlay hints                   |
| `:ToggleTailwindFold`| Toggle Tailwind class folding        |
| `:ToggleLocList`     | Toggle location list                 |
| `:ToggleQuickFix`    | Toggle quickfix list                 |
| `:WipeReg`           | Wipe all registers                   |
| `:Help`              | `:help` for word under cursor        |
| `:R`                 | `w | :e` — save + reload buffer      |
| `:S`                 | `syntax sync clear`                  |
| `:RotateWindows`     | Rotate window layout                 |

## Directory Conventions

- `lua/plugins/*.lua` — each returns a lazy.nvim spec table
- `lua/plugins/lsp/` — LSP plugin specs (imported as separate group)
- `after/` — `after/ftplugin/`, `after/queries/`, `after/syntax/`, plus root-level overrides loaded after their counterparts
- `ftplugin/` — filetype-specific buffer settings loaded automatically by Neovim
- `plugin/ft.lua` — early filetype detection overrides
- `queries/` — custom treesitter queries
- `snippets/` — custom LuaSnip snippet files
- `spell/` — spellfile additions
- `pack/` — manual (non-lazy) packages (e.g. Copilot)
