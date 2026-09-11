# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Overview

Personal Neovim configuration written in Lua, using **lazy.nvim** as the plugin
manager. Targets modern web development (TypeScript, Vue, React) with extensive
LSP support, Git integration, and AI assistance.

## Code Style

Lua formatting governed by `stylua.toml`:

- Column width: 120
- Indentation: 4 spaces
- Line endings: Unix
- Quote style: auto

Formatting on save is wired up via **conform.nvim**
(`lua/plugins/formatting.lua`) with `lsp_format = "fallback"` — conform runs the
configured formatter (prettier, stylua, etc.) and falls back to LSP formatting
if none is mapped for the filetype.

## Architecture

### Entry Point & Loading Order

`init.lua` requires modules in this order:

1. `lua/config/options.lua` — editor options (`vim.opt`, `vim.g.loaded_*`
   disables)
2. `lua/core/lazy.lua` — bootstraps lazy.nvim, imports `plugins` and
   `plugins.lsp`
3. `lua/core/lsp.lua` — global `LspAttach` autocmd (keymaps), diagnostic config,
   notify filter
4. `lua/config/commands.lua` — custom `:` commands
5. `lua/config/keymaps.lua` — global keybindings
6. `lua/config/settings.lua` — autocmds, filetype behaviors, extra commands
7. `pcall(require, "config.theme")` — optional theme module kept in a separate
   repo

Git/diff helpers required from `settings.lua`, each exposing `setup()` and a
pure core with a check under `lua/config/checks/` (run with `nvim -l <file>`):

- `lua/config/fugitive.lua` — status-buffer behaviours: conflict warnings
  (`conflicts()` pure), which-key detach, `q` maps, and
  `lua/config/fugitive_word_diff.lua` (word-level diff highlights)
- `lua/config/noeol.lua` — "No newline at end of file" marks, plain and inside
  conflict blocks
- `lua/config/conflict_markers.lua` — `marker(line)` classifier
- `lua/config/vue_blocks.lua` — Vue SFC block tracking shared by
  `lua/config/diff_lang.lua` (treesitter diff injections) and the zdiff patch

`lua/config/utils.lua` is **not** required directly from `init.lua`; it is
loaded by `commands.lua`/`keymaps.lua`. It only holds `map()` and the
`nmap`/`xmap`/... shorthands (which add `silent = true`) plus a global
`inspect()`. Commands use `vim.api.nvim_create_user_command` directly.

### Plugin Structure

All plugin specs live in `lua/plugins/`. Each file returns a lazy.nvim spec
table (or list of tables). LSP-related specs live in `lua/plugins/lsp/` and are
imported as a second import group (`{ import = "plugins.lsp" }`) by
`lua/core/lazy.lua`.

### LSP Configuration

LSP is configured with the modern `vim.lsp.config(name, ...)` / mason-lspconfig
flow — there is **no** `lua/lsp/` directory.

- `lua/core/lsp.lua` — `LspAttach` keymaps, diagnostic signs/float, notify
  filter that suppresses noisy lspconfig warnings, horizontal padding for LSP
  floats
- `lua/plugins/lsp/lsp.lua` — `vim.lsp.config(...)` blocks per server: `ts_ls`,
  `vtsls`, `vue_ls`, `jsonls`, `emmet_language_server`, `eslint`, `cssls`,
  `lua_ls`, `tailwindcss`
- `lua/plugins/lsp/mason.lua` — `mason-lspconfig` `ensure_installed` list (adds
  `html`, `svelte`, `graphql`, `prismals`, `pyright`, `gopls`) and
  `mason-tool-installer` for `prettier`, `stylua`, `shellcheck`, `shfmt`

Vue/TS split (important context, see comments in `lsp.lua`):

- `ts_ls` handles `.ts`/`.js`/`.tsx`/`.jsx` only and is pinned to its bundled
  tsserver (workaround for a TS 5.7.2 bug with vue re-exports).
- `vtsls` handles `.vue` files and loads `@vue/typescript-plugin` from mason's
  `vue-language-server` package; `vue_ls` bridges to vtsls via the tsserver
  request channel.

Diagnostic virtual text is off by default — toggle via `:ToggleVirtualText`.
Inlay hints are also off by default — toggle per buffer via `:ToggleInlayHint`
(`<leader><tab>i`). The `inlayHints` settings on `ts_ls`/`vtsls` control which
hints arrive once enabled, not whether they show.

### Core LSP Keybindings (set on `LspAttach`)

`gr`=references, `gd`=definition, `gD`=declaration, `gi`=implementation,
`gt`=type definition, `ga`=code actions, `gR`=rename, `gl`=line diagnostics,
`K`=hover, `[d`/`]d`=prev/next diagnostic, `<leader>rs`=`:LspRestart`

### Completion

**blink.cmp** (`lua/plugins/blink.lua`) drives completion; `version = "1.*"` so
the prebuilt fuzzy binary is downloaded instead of built with cargo. It
registers its own LSP client capabilities via `vim.lsp.config("*")`, so
`lua/plugins/lsp/lsp.lua` carries no completion-related capability wiring.

- sources: `lsp`, `path`, `snippets`, `buffer`, `ripgrep` (blink-ripgrep.nvim,
  `prefix_min_len = 3`, gitgrep-or-ripgrep backend)
- keymap preset is `none` — every key is spelled out, carried over from the old
  cmp config: `<C-k>`/`<C-j>` select, `<C-b>`/`<C-f>` scroll docs, `<C-c>` show,
  `<C-e>` hide, `<CR>` accept. `<Tab>`/`<S-Tab>`, `<C-p>`/`<C-n>` and
  `<Up>`/`<Down>` are left unmapped in both modes. The cmdline keymap is the
  same minus the docs scroll, with `<C-e>` = `cancel` and `<CR>` =
  `accept_and_enter` (insert the selection _and_ execute). Note this diverges
  from blink's own `cmdline` preset, whose `<Tab>`/`<S-Tab>` open the menu and
  insert the first/last item — that would defeat the noselect setup below.
- selection is `preselect = false, auto_insert = false` in both the insert and
  cmdline menus (cmp's `noinsert,noselect`): nothing is highlighted until you
  move with `<C-j>`/`<C-k>`, and moving does not write into the buffer. Since
  `accept`/`accept_and_enter` bail when nothing is selected, `<CR>` falls
  through to a plain `<CR>` until you have moved into the menu.
- snippets come from **LuaSnip** (`lua/plugins/luasnip.lua`) plus
  friendly-snippets, loaded with
  `require("luasnip.loaders.from_vscode").lazy_load()`.

`lua/plugins/cmp.lua` (nvim-cmp) is kept but `enabled = false` for rollback —
flip that flag and disable blink to swap back. Its long comments describe cmp's
float-padding internals and do not apply to blink.

### AI Plugins

- **sidekick.nvim** (`lua/plugins/sidekick.lua`) — primary AI sidebar / CLI
  integration (Folke) (`supermaven-nvim`, `avante.nvim`, `codeium.nvim`, and
  GitHub Copilot have been removed.)

## Key Custom Commands

Defined across `lua/config/commands.lua` and `lua/config/settings.lua`.

| Command               | Purpose                            |
| --------------------- | ---------------------------------- |
| `:LspRestart`         | Restart LSP server (buffer-scoped) |
| `:ToggleVirtualText`  | Toggle LSP diagnostic virtual text |
| `:ToggleDiagnostics`  | Toggle diagnostics on/off          |
| `:ToggleInlayHint`    | Toggle inlay hints                 |
| `:ToggleTailwindFold` | Toggle Tailwind class folding      |
| `:ToggleLocList`      | Toggle location list               |
| `:ToggleQuickFix`     | Toggle quickfix list               |
| `:ToggleSpell`        | Toggle spell check                 |
| `:WipeReg`            | Wipe all registers                 |
| `:Help`               | `:help` for word under cursor      |
| `:R`                  | `w \| :e` — save + reload buffer   |
| `:S`                  | `syntax sync clear`                |
| `:RotateWindows`      | Rotate window layout               |

## Directory Conventions

- `lua/plugins/*.lua` — each returns a lazy.nvim spec table
- `lua/plugins/lsp/` — LSP plugin specs (imported as separate group)
- `after/` — `after/ftplugin/`, `after/queries/`, `after/syntax/`, plus
  root-level overrides loaded after their counterparts
- `ftplugin/` — filetype-specific buffer settings loaded automatically by Neovim
- `plugin/ft.lua` — early filetype detection overrides
- `queries/` — custom treesitter queries
- `spell/` — spellfile additions
