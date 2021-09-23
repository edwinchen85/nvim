require("nvim-treesitter.configs").setup({
    indent = { enable = true },
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
    highlight = { enable = true },
    autotag = { enable = true },
    matchup = {
        enable = true,
    },
})
