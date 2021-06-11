local minsnip = require("minsnip")

local u = require("utils")

minsnip.setup({
    snippets = require("snippets"),
    extends = { typescriptreact = { "typescript" } },
    after = function()
        if vim.fn.pumvisible() == 1 then
            u.input("<C-o>i")
        end
    end,
})

_G.global.tab_complete = function()
    if not minsnip.jump() then
        if vim.fn.pumvisible() == 1 then
            u.input("<C-y>")
        elseif vim.opt_local.omnifunc ~= "" then
            u.input("<C-x><C-o>")
        else
            u.input("<C-n>")
        end
    end
end

vim.api.nvim_set_keymap("i", "<Tab>", "<cmd> lua tab_complete()<CR>", {})

u.map("i", "<Tab>", "<cmd> lua global.tab_complete()<CR>")
u.map("i", "<C-j>", "<cmd> lua require'minsnip'.jump()<CR>")
