-- Pure check for config/fugitive.conflicts (porcelain XY classification).
--
--   nvim -l lua/config/checks/fugitive.lua

local conflicts = require("config.fugitive").conflicts

local files = {
    ["img.png"] = "\137PNG\0\0binary",
    ["text.txt"] = "<<<<<<< HEAD\nfoo\0bar\n",
    ["ok.txt"] = "plain",
}
local porcelain = table.concat({
    "DU gone.lua",
    "UU img.png",
    "AA text.txt",
    'UU "ok.txt"',
    " M unrelated.lua",
    "UD other.lua",
}, "\n")

local got = conflicts(porcelain, function(p)
    return files[p]
end)
local want = { "deletion:gone.lua", "binary:img.png", "deletion:other.lua" }
assert(#got == #want, "count " .. #got)
for i, c in ipairs(got) do
    local key = c.kind .. ":" .. (c.path or c.line:sub(4))
    assert(key == want[i], key .. " ~= " .. want[i])
end
print("ok")
