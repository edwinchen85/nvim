require("nvim-treesitter.configs").setup({
    context_commentstring = { enable = true },
    autopairs = { enable = true },
    ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "lua",
        "json",
        "jsonc",
        "yaml",
    },
    textsubjects = {
        enable = true,
        keymaps = {
            ["."] = "textsubjects-smart",
        },
    },
    highlight = { enable = true },
    autotag = { enable = true },
    matchup = {
        enable = true,
    },
})

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
