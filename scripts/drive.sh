#!/bin/sh
# Drive a hidden nvim running the full config, as if typing into it. Keys arrive as
# real input, so mappings, autocmds and clipboard writes behave as they do on screen
# (unlike `nvim --headless -c 'normal! ...'`, which batches clipboard writes).
#
#   scripts/drive.sh start [file]   start it (cwd: repo root), optionally editing file
#   scripts/drive.sh keys '<C-q>'   send keys (nvim key notation)
#   scripts/drive.sh expr 'mode(1)' print a Vimscript expression
#   scripts/drive.sh lua 'return vim.bo.filetype'   (no single quotes in the Lua)
#   scripts/drive.sh stop
#
# Uses a fake clipboard provider when DRIVE_REAL_CLIPBOARD is unset, so yanks never
# reach the system clipboard; read it back with `expr 'getreg("+")'`.
cd "$(dirname "$0")/.." || exit 1
SOCK="${TMPDIR:-/tmp}/nvim-drive.sock"

FAKE_CLIPBOARD='lua local s = {}
local function c(r) return function(l, t) s[r] = { l, t } end end
local function p(r) return function() return s[r] or { {}, "v" } end end
vim.g.clipboard = { name = "drive", copy = { ["+"] = c("+"), ["*"] = c("*") },
  paste = { ["+"] = p("+"), ["*"] = p("*") } }'

case "$1" in
start)
    [ -S "$SOCK" ] && nvim --server "$SOCK" --remote-send '<C-\><C-n>:qa!<CR>' 2>/dev/null
    rm -f "$SOCK"
    if [ -n "$DRIVE_REAL_CLIPBOARD" ]; then
        env -u TMUX -u TMUX_PANE nvim --headless --listen "$SOCK" ${2:+"$2"} >/dev/null 2>&1 &
    else
        env -u TMUX -u TMUX_PANE nvim --headless --listen "$SOCK" --cmd "$FAKE_CLIPBOARD" ${2:+"$2"} >/dev/null 2>&1 &
    fi
    i=0
    while [ ! -S "$SOCK" ] && [ $i -lt 50 ]; do
        sleep 0.1
        i=$((i + 1))
    done
    [ -S "$SOCK" ] || { echo "drive: nvim did not start" >&2; exit 1; }
    ;;
keys) nvim --server "$SOCK" --remote-send "$2" ;;
expr) nvim --server "$SOCK" --remote-expr "$2" && echo ;;
lua) nvim --server "$SOCK" --remote-expr "luaeval('(function() $2 end)()')" && echo ;;
stop)
    nvim --server "$SOCK" --remote-send '<C-\><C-n>:qa!<CR>' 2>/dev/null
    rm -f "$SOCK"
    ;;
*)
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
