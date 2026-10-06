# Coding standards

Judgement calls for reviewers. Formatting, lint and behaviour checks are
mechanical and live in `scripts/check.sh`; don't restate them here.

## Patching plugin internals

Wrap in place with the hand-rolled save/wrap idiom, no shared helper
(`docs/adr/0001-no-upstream-patch-helper.md`). Each site cites the upstream
fact it depends on, file and function (e.g. `sidekick/cli/terminal.lua`
`Terminal:open_win`), and keeps `return orig(...)` so a vanished field fails
loudly.

## Overriding plugin defaults

Plugin opts deep-merge into the defaults, so overriding one entry of a table
(a sidekick key, a lazy spec field) inherits every field you leave unset. Spell
out each inherited field that changes behaviour, e.g. `expr = false` on a
sidekick key whose default is an `expr` map, since an `expr` map runs under
textlock and cannot switch windows (E565).

## Terminal windows

Resize a terminal window only on an explicit user action (a zoom or width key,
`VimResized`), never on focus changes. Every resize sends the pty a SIGWINCH,
and a TUI caught mid-output (Claude) redraws rows in the wrong place.

## Checks

New pure logic gets a check under `lua/config/checks/`, run with `nvim -l`. A
check that needs the full config starts with a line beginning
`-- run with: nvim --headless`; `scripts/check.sh` keys on it to run the check
via `luafile` instead.
