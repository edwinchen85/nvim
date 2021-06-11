local illuminate = require("illuminate")

local u = require("utils")

_G.global.illuminate = {
    next_ref = function()
        illuminate.next_reference({ wrap = true })
    end,
    prev_ref = function()
        illuminate.next_reference({ reverse = true, wrap = true })
    end,
}

vim.g.Illuminate_ftblacklist = { 'NvimTree' }

u.map("n", "<A-n>", "<cmd> lua global.illuminate.next_ref()<CR>")
u.map("n", "<A-p>", "<cmd> lua global.illuminate.prev_ref()<CR>")
