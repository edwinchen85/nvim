-- Check that after/queries/diff/injections.scm highlights hunk bodies with the
-- diffed file's own parser, in real `git diff` output and in fugitive's :Git
-- status buffer (whose inline hunks carry no diff header).
--
--   nvim -l lua/config/checks/diff_injections.lua

vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
require("config.diff_lang").setup()

local function attach(lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(lines, "\n"))
    vim.treesitter.get_parser(buf, "diff"):parse(true)
    vim.treesitter.start(buf, "diff")
    return buf
end

local function caps(buf, row, col)
    return vim.iter(vim.treesitter.get_captures_at_pos(buf, row, col))
        :map(function(c)
            return c.lang .. ":@" .. c.capture
        end)
        :join(", ")
end

local diff = attach([[
diff --git a/lua/foo.lua b/lua/foo.lua
index 1234567..89abcde 100644
--- a/lua/foo.lua
+++ b/lua/foo.lua
@@ -1,3 +1,4 @@
 local M = {}
-M.old = function() return 1 end
+M.new = function()
 return M]])

assert(caps(diff, 7, 3):match("lua:@"), "git diff addition: " .. caps(diff, 7, 3))
assert(caps(diff, 6, 3):match("lua:@"), "git diff deletion: " .. caps(diff, 6, 3))

-- fugitive :Git status: no `diff --git`/`+++` header, the `M path` line names the file
local status = attach([[
Head: main

Unstaged (2)
M lua/foo.lua
@@ -1,4 +1,7 @@
 local M = {}
+-- a comment, which must not bleed into the lines below it
+local s = "kept"
-M.old = 1
+M.new = function() end
M src/app.ts
@@ -1,2 +1,2 @@
-const a: number = 1
+const b: string = "x"

Staged (1)
M README.md]])

assert(caps(status, 6, 3):match("lua:@comment"), "fugitive lua comment: " .. caps(status, 6, 3))
-- each line's range has to carry its trailing newline, or the `--` above runs on
-- and every following line lands in one giant comment
assert(caps(status, 7, 1):match("lua:@keyword"), "comment bled past its line: " .. caps(status, 7, 1))
assert(caps(status, 9, 3):match("lua:@"), "addition after a deletion: " .. caps(status, 9, 3))
-- the pre-image is a second combined tree, so deletions highlight too
assert(caps(status, 8, 1):match("lua:@variable"), "deletion side: " .. caps(status, 8, 1))
assert(caps(status, 8, 0):match("diff.minus"), "deletion marker lost its diff highlight")
assert(caps(status, 12, 7):match("typescript:@"), "ts deletion side: " .. caps(status, 12, 7))
assert(caps(status, 13, 7):match("typescript:@"), "fugitive ts hunk: " .. caps(status, 13, 7))
assert(not caps(status, 7, 1):match("markdown"), "README.md leaked backwards into the lua hunk")
assert(caps(status, 7, 0):match("diff.plus"), "marker column lost its diff highlight")

-- a file whose extension has no filetype must get no injection at all; the walk
-- has to stop at its `M path` line rather than run on into the .lua file above
local unknown = attach([[
Unstaged (2)
M lua/foo.lua
@@ -1,1 +1,1 @@
-M.old = 1
M spell/en.utf-8.add
@@ -1,1 +1,1 @@
-alpha
+beta wordlist entry]])

assert(caps(unknown, 3, 1):match("lua:@"), "sanity, the lua hunk above: " .. caps(unknown, 3, 1))
assert(caps(unknown, 6, 1) == "diff:@diff.minus", "language leaked forward: " .. caps(unknown, 6, 1))
assert(caps(unknown, 7, 1) == "diff:@diff.plus", "language leaked forward: " .. caps(unknown, 7, 1))

-- Resolving the language per hunk line used to walk to the file line every time,
-- calling vim.filetype.match at each step: ~1900ms for the buffer below. Anything
-- near that means the row cache or the boundary stop is gone.
local big = { "Unstaged (1)", "M lua/big.lua", "@@ -1,2000 +1,2000 @@" }
for i = 1, 2000 do
    big[#big + 1] = ({ " ", "+", "-" })[i % 3 + 1] .. ('  local v%d = { name = "x%d" }'):format(i, i)
end
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, big)
local started = vim.uv.hrtime()
vim.treesitter.get_parser(buf, "diff"):parse(true)
local ms = (vim.uv.hrtime() - started) / 1e6
assert(ms < 300, ("2000-line status buffer took %.0fms to parse, expected well under 300ms"):format(ms))

print(("diff injections OK (2000-line buffer parsed in %.0fms)"):format(ms))
