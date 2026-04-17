# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration written in Lua, using **lazy.nvim** as the plugin manager. It targets modern web development (TypeScript, Vue, React) with extensive LSP support, Git integration, and AI assistance.

## Code Style

Lua formatting is governed by `stylua.toml`:

- Column width: 120
- Indentation: 4 spaces
- Line endings: Unix
- Quote style: auto

## Architecture

### Entry Point & Loading Order

`init.lua` is the entry point. It requires modules in this order:

1. `lua/config/options.lua` — editor options (vim.opt settings)
2. `lua/config/utils.lua` — shared utility functions used by other modules
3. `lua/core/lazy.lua` — bootstraps lazy.nvim, imports `plugins` and `plugins.lsp`
4. `lua/config/keymaps.lua` — keybindings
5. `lua/config/commands.lua` — custom `:` commands
6. `lua/config/settings.lua` — autocmds and filetype behaviors

### Plugin Structure

All plugin specs live in `lua/plugins/`. Each file exports a table (or list of tables) consumed by lazy.nvim. LSP-specific plugin specs are in `lua/plugins/lsp/` and imported separately via the `plugins.lsp` import in lazy setup.

### LSP Configuration

- `lua/lsp/init.lua` — shared `on_attach`, capabilities, and diagnostic config
- `lua/lsp/<server>.lua` — per-server setup called from plugin specs in `lua/plugins/lsp/`
- LSP servers: bashls, cssls, emmetls, eslint, jsonls, null-ls, pyright, lua_ls, tailwindcss, ts_ls, vuels
- Auto-format on save is enabled per-client in `on_attach`
- Virtual text is disabled by default (toggle via `:ToggleVirtualText`)

### Core LSP Keybindings (set in on_attach)

`gr`=references, `gd`=definition, `gD`=declaration, `gi`=implementation, `gt`=type definition, `ga`=code actions, `gR`=rename, `gl`=line diagnostics, `K`=hover, `<leader>rs`=restart LSP

### AI Plugins

- **avante.nvim** — AI chat sidebar, enabled, uses OpenAI (`gpt-4o-mini`)
- **GitHub Copilot** — installed in `pack/github/start/copilot.vim/` (manual git clone, not via lazy)
- **supermaven-nvim** — disabled via `condition = function() return false end`
- **codeium.nvim** — disabled (empty spec)

### Notable Utilities (`lua/config/utils.lua`)

Provides `map()`, `buf_map()`, `command()`, and other helpers used throughout config files. Read this before adding keymaps or commands.

## Key Custom Commands

| Command              | Purpose                                    |
| -------------------- | ------------------------------------------ |
| `:LspFormatting`     | Format buffer via LSP                      |
| `:LspRestart`        | Restart LSP server                         |
| `:ToggleVirtualText` | Toggle LSP virtual text                    |
| `:ToggleDiagnostics` | Toggle diagnostics                         |
| `:ToggleInlayHint`   | Toggle inlay hints                         |
| `:R`                 | Reload file + reset treesitter/diagnostics |
| `:S`                 | Syntax sync clear                          |
| `:RotateWindows`     | Rotate window layout                       |

## File Conventions

- Plugin files in `lua/plugins/` should return a lazy.nvim spec table
- LSP server files in `lua/lsp/` should expose a `setup()` function called from the corresponding plugin spec
- `after/` directory contains post-init scripts (filetype overrides, etc.)
- `ftplugin/` contains filetype-specific settings loaded automatically by Neovim
- `snippets/` contains custom LuaSnip snippet files
