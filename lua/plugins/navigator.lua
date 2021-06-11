local u = require("utils")

require("Navigator").setup({ disable_on_zoom = true })

u.map("n", "<C-h>", "<cmd> lua require'Navigator'.left()<CR>")
u.map("n", "<C-k>", "<cmd> lua require'Navigator'.up()<CR>")
u.map("n", "<C-l>", "<cmd> lua require'Navigator'.right()<CR>")
u.map("n", "<C-j>", "<cmd> lua require'Navigator'.down()<CR>")
