-- run with: nvim -l lua/config/checks/signcolumn.lua
vim.opt.rtp:prepend(vim.fn.stdpath("config"))
local overlaps = require("config.signcolumn").overlaps

assert(overlaps({ [3] = true }, { { 2, 4 } }))
assert(overlaps({ [4] = true }, { { 1, 1 }, { 4, 4 } }))
assert(not overlaps({ [5] = true }, { { 2, 4 } }))
assert(not overlaps({}, { { 1, 9 } }))
assert(not overlaps({ [1] = true }, {}))
print("signcolumn ok")
