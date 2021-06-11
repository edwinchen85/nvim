local u = require("utils")

require("hop").setup({})

u.map("n", "<Leader>s", ":HopChar2<CR>")
u.map("n", "<Leader>S", ":HopWord<CR>")
