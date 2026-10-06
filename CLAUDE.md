# CLAUDE.md

Personal Neovim config in Lua, plugins via **lazy.nvim**. Targets web development
(TypeScript, Vue, React).

- Reviewers: `CODING_STANDARDS.md`. Domain terms (hunk, Vue SFC block, conflict
  marker): `CONTEXT.md`. Decisions: `docs/adr/`.
- **Checks**: `scripts/check.sh` runs stylua, luacheck and every
  `lua/config/checks/*.lua`; it is the pre-commit hook (`.githooks/`). Run it
  before reporting work as done.

## Layout

`init.lua` loads `config.options` → `core.lazy` → `core.lsp` → `config.commands`
→ `config.keymaps` → `config.settings`, then `pcall(require, "config.theme")`
(the theme lives in a separate repo, so it may be absent).

- `lua/plugins/*.lua` each return a lazy.nvim spec; `lua/plugins/lsp/` is a
  second import group.
- `lua/config/utils.lua` is loaded by commands/keymaps, not `init.lua`; it only
  holds `map()`, the `nmap`/`xmap` shorthands (which add `silent = true`) and a
  global `inspect()`.
- Git/diff helpers, required from `settings.lua`, each expose `setup()` plus a
  pure core with a check under `lua/config/checks/`: `config/fugitive.lua`
  (status buffer; `fugitive_word_diff.lua`), `config/noeol.lua`,
  `config/conflict_markers.lua`, `config/vue_blocks.lua` (shared by
  `config/diff_lang.lua` and the zdiff patch).

## Sidekick CLI float

sidekick.nvim (`lua/plugins/sidekick.lua`) runs Claude in a float, not a split:
right side at `cli.win.float.width`, `<C-z>` zoom, `<M-m>` center with a
backdrop, `<M-,>`/`<M-.>`/`<M-=>` width. State is window-local
(`vim.w._sk_zoomed`, `_sk_centered`). Spread across:

- `lua/util/sidekick.lua`: find/focus/leave the CLI window.
- `lua/plugins/smart-splits.lua`: `<C-l>` takes the split to the right unless
  the float hides it, else jumps into the float (floats sit outside the split
  layout).
- `lua/config/fugitive.lua`: leaving any terminal refreshes fugitive status.
- `lua/config/checks/sidekick_float.lua`: drives all of the above headless.

## LSP

`vim.lsp.config(name, ...)` + mason-lspconfig; servers in
`lua/plugins/lsp/lsp.lua`, installs in `lua/plugins/lsp/mason.lua`, attach
keymaps in `lua/core/lsp.lua`. Vue/TS split (see comments in `lsp.lua`):

- `ts_ls` handles `.ts`/`.js`/`.tsx`/`.jsx` only, pinned to its bundled
  tsserver (TS 5.7.2 bug with vue re-exports).
- `vtsls` handles `.vue` with `@vue/typescript-plugin` from mason's
  `vue-language-server`; `vue_ls` bridges to vtsls via the tsserver request
  channel.

Virtual text and inlay hints are off by default (`:ToggleVirtualText`,
`:ToggleInlayHint`); the `inlayHints` server settings only pick which hints
arrive once enabled.

## Completion

**blink.cmp** (`lua/plugins/blink.lua`), `version = "1.*"` so the prebuilt fuzzy
binary downloads instead of building with cargo. It registers LSP capabilities
itself, so `lsp.lua` has none.

- Keymap preset `none`, every key spelled out. The cmdline keymap deliberately
  skips blink's `cmdline` preset, whose `<Tab>` inserts the first item and
  defeats noselect.
- `preselect = false, auto_insert = false` in insert and cmdline (cmp's
  `noinsert,noselect`): `<CR>` falls through to a plain `<CR>` until you move
  into the menu.
- `lua/plugins/cmp.lua` is kept with `enabled = false` for rollback; its
  float-padding comments describe cmp, not blink.
