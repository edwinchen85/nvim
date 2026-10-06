# CLAUDE.md

Personal Neovim config in Lua, plugins via **lazy.nvim**. Targets web development
(TypeScript, Vue, React).

- Reviewers: `CODING_STANDARDS.md`. Domain terms (hunk, Vue SFC block, conflict
  marker): `CONTEXT.md`. Decisions: `docs/adr/`.
- **Checks**: `scripts/check.sh` runs stylua, luacheck and every
  `lua/config/checks/*.lua`; it is the pre-commit hook (`.githooks/`). Run it
  before reporting work as done.
- **Trying keys by hand**: `scripts/drive.sh` runs a hidden nvim with the full
  config and sends it keys as real typing (usage at its top).

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
  `config/hunk_yank.lua` (marker-free `Vy` of hunk lines),
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

## LSP and completion

- Servers: `lua/plugins/lsp/lsp.lua`; its comments explain the `.vue` split
  (`vtsls` + `vue_ls`, `ts_ls` for plain TS/JS). Installs:
  `lua/plugins/lsp/mason.lua`. Attach keymaps: `lua/core/lsp.lua`.
- Completion: blink.cmp, `lua/plugins/blink.lua`. `lua/plugins/cmp.lua` is the
  disabled rollback; its comments describe cmp, not blink.
