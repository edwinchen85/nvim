-- Pure check for config/conflict_markers.
--
--   nvim -l lua/config/checks/conflict_markers.lua

local marker = require("config.conflict_markers").marker

for line, want in pairs({
    ["<<<<<<< HEAD"] = "start",
    ["<<<<<<<"] = "start",
    ["||||||| merged common ancestors"] = "base",
    ["======="] = "sep",
    [">>>>>>> feature/x"] = "end",
    ["========"] = false,
    ["<<<<<<<< too many"] = false,
    ["const a = 1"] = false,
    ["> quote"] = false,
}) do
    assert((marker(line) or false) == want, ("%q -> %s, want %s"):format(line, tostring(marker(line)), tostring(want)))
end
print("ok")
