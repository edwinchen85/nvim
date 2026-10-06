-- Pure check for config/hunk_yank.
--
--   nvim -l lua/config/checks/hunk_yank.lua

local strip = require("config.hunk_yank").strip

local function same(a, b)
    return vim.deep_equal(a, b)
end

assert(same(strip({ "-old", "+new", " ctx", "" }), { "old", "new", "ctx", "" }), "hunk body not stripped")
assert(same(strip({ "+-- comment", "--- deleted comment" }), { "-- comment", "-- deleted comment" }), "comment lines")
assert(strip({ "@@ -1,2 +1,2 @@", "+new" }) == nil, "@@ header did not keep the patch")
assert(strip({ "diff --git a/x b/x", "-old" }) == nil, "diff header did not keep the patch")
assert(strip({ "--- a/x", "+++ b/x" }) == nil, "file headers stripped")
assert(strip({ "--- /dev/null" }) == nil, "/dev/null header stripped")
assert(same(strip({ "--x", "++y" }), { "-x", "+y" }), "only the marker column is cut")
print("ok")
