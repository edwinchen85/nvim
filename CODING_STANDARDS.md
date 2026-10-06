# Coding standards

Judgement calls for reviewers. Formatting, lint and behaviour checks are
mechanical and live in `scripts/check.sh`; don't restate them here.

## Upstream facts

Any comment relying on upstream behaviour (a patched internal, a plugin or theme
default) names the file that defines it, e.g. `sidekick/cli/terminal.lua`
`Terminal:open_win`. Confirm it there: the theme can redefine a plugin's
highlight groups (tokyonight's `groups/render-markdown.lua`).

## Patching plugin internals

Wrap in place with the hand-rolled save/wrap idiom, no shared helper
(`docs/adr/0001-no-upstream-patch-helper.md`), and keep `return orig(...)` so a
vanished field fails loudly.

## Overriding plugin defaults

Opts deep-merge into the defaults, so an overridden entry inherits every field
left unset. Spell out each inherited field that changes behaviour, e.g.
`expr = false` on a sidekick key whose default is an `expr` map (textlock, E565).

## Terminal windows

Resize only on an explicit user action (a zoom or width key, `VimResized`),
never on focus changes: each resize SIGWINCHes the pty, and Claude caught
mid-output redraws rows in the wrong place.

## Checks

New pure logic gets a check under `lua/config/checks/`. A check asserting on
registers feeds keys as typed input from the main loop, never `feedkeys(…, "x")`
inside the script: nvim defers clipboard writes until the script's command ends
(see `checks/hunk_yank_registers.lua`).
