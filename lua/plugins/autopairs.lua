local npairs = require("nvim-autopairs")
local u = require("utils")

npairs.setup({
    check_ts = true,
    ignored_next_char = "[%w%.]",
    check_line_pair = false,
})

_G.global.on_enter = function()
    return npairs.autopairs_cr()
end
u.map("i", "<CR>", "v:lua.global.on_enter()", { expr = true })
