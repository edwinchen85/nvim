# AGENTS.md

Personal Neovim config in Lua, plugins via **lazy.nvim**. Targets web development
(TypeScript, Vue, React).

- Writing or reviewing code: `CODING_STANDARDS.md`. Domain terms (hunk, Vue SFC
  block, conflict marker): `CONTEXT.md`. Decisions: `docs/adr/`.
- **Checks**: `scripts/check.sh` runs stylua, luacheck and every
  `lua/config/checks/*.lua`; it is the pre-commit hook (`.githooks/`). Run it
  before reporting work as done.
- **Trying keys by hand**: `scripts/drive.sh` runs a hidden nvim with the full
  config and sends it keys as real typing (usage at its top).

## Layout

`init.lua` loads the config; `config.theme` lives in a separate repo, so it may
be absent.

- `lua/plugins/*.lua` each return a lazy.nvim spec; `lua/plugins/lsp/` is a
  second import group.
- `lua/config/settings.lua` calls `setup()` on `config/fugitive.lua` (status
  buffer; `fugitive_word_diff.lua`), `config/noeol.lua`, `config/hunk_yank.lua`
  (marker-free `Vy` of hunk lines) and `config/signcolumn.lua` (1 cell, 2 while
  diagnostic and git signs share a line); `lua/plugins/treesitter.lua` sets up
  `config/diff_lang.lua`. `config/conflict_markers.lua` and `config/vue_blocks.lua`
  are shared libraries (the latter also used by the zdiff patch). Checks live in
  `lua/config/checks/`; `noeol` has none.
- Floats inherit the global `winborder = "rounded"`; one that must be borderless
  needs `border = "none"`.

## Sidekick CLI float

sidekick.nvim (`lua/plugins/sidekick.lua`) runs Claude in a right-side float,
not a split; its keys and window-local state are in that file. Spread across:

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
