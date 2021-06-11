local u = require("utils")

require("nnn").setup({
    set_default_mappings = false,
    session = "local",
    layout = { window = { width = 0.9, height = 0.6 } },
    action = {
        ["<C-t>"] = "tab split",
        ["<C-x>"] = "split",
        ["<C-v>"] = "vsplit",
    },
})

u.map("n", "-", ":NnnPicker %:p:h<CR>")
u.map("n", "<Leader>n", ":NnnPicker")
