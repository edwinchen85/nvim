-- Pure check for util/hl.
--
--   nvim -l lua/config/checks/hl.lua

local hl = require("util.hl")

assert(hl.blend("#ffffff", "#000000", 0.5) == "#808080", hl.blend("#ffffff", "#000000", 0.5))
assert(hl.blend("#c0caf5", "#1a1b26", 1) == "#c0caf5")
assert(hl.blend("#c0caf5", "#1a1b26", 0) == "#1a1b26")
assert(hl.blend(nil, "#1a1b26", 0.5) == "#1a1b26")
assert(hl.blend("#c0caf5", nil, 0.5) == "#c0caf5")
assert(hl.blend(nil, nil, 0.5) == nil)

vim.api.nvim_set_hl(0, "HlCheckBase", { fg = 0x112233, bg = 0x445566 })
vim.api.nvim_set_hl(0, "HlCheckLink", { link = "HlCheckBase" })
assert(hl.get("HlCheckLink", "fg") == "#112233", hl.get("HlCheckLink", "fg"))
assert(hl.get("HlCheckLink", "bg") == "#445566")
assert(hl.get("HlCheckBase", "sp") == nil)
assert(hl.get("HlCheckMissing", "fg") == nil)
print("ok")
