#!/bin/sh
# Format, lint, and run every check under lua/config/checks/. Exits non-zero on any failure.
# Runs as the pre-commit hook (.githooks/pre-commit, wired by `git config core.hooksPath .githooks`).
cd "$(dirname "$0")/.." || exit 1
MASON="$HOME/.local/share/nvim/mason"
# Every tracked or new (non-ignored) Lua file, so adding or removing a dir needs no edit here.
SRC=$(git ls-files --cached --others --exclude-standard '*.lua')
status=0
fail() {
    echo "FAIL: $1"
    status=1
}

# shellcheck disable=SC2086
"$MASON/bin/stylua" --check $SRC >/dev/null || fail "stylua (run: $MASON/bin/stylua \$(git ls-files '*.lua'))"

# Mason's luacheck wrapper hardcodes Homebrew's `lua` formula, which moved to 5.5; its
# rocks (and lfs.so) are built for 5.4, so run it on keg-only lua@5.4 directly.
LUA54="$(brew --prefix lua@5.4 2>/dev/null)/bin/lua5.4"
LC="$MASON/packages/luacheck"
if [ -x "$LUA54" ]; then
    # shellcheck disable=SC2086
    "$LUA54" -e "package.path='$LC/share/lua/5.4/?.lua;$LC/share/lua/5.4/?/init.lua;'..package.path
        package.cpath='$LC/lib/lua/5.4/?.so;'..package.cpath" \
        "$LC"/lib/luarocks/rocks-5.4/luacheck/*/bin/luacheck --quiet --no-color $SRC || fail luacheck
else
    fail "luacheck needs lua@5.4 (brew install lua@5.4)"
fi

# Checks that load the full config say so in their header (`nvim --headless -c 'luafile ...'`);
# the rest are pure and run with `nvim -l`. TMUX is unset so smart-splits stays quiet.
for check in lua/config/checks/*.lua; do
    if grep -q "^-- run with: nvim --headless" "$check"; then
        out=$(env -u TMUX -u TMUX_PANE nvim --headless -c "luafile $check" 2>&1) || fail "$check"
    else
        out=$(nvim -l "$check" 2>&1) || fail "$check"
    fi
    printf '%s\n' "$out" | tr '\r' '\n' | grep -v '^[[:space:]]*$' | tail -5
done

exit $status
