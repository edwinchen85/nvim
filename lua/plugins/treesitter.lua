require("nvim-treesitter.configs").setup({
    indent = { enable = true },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    autopairs = { enable = true },
    ensure_installed = {
        "bash",
        "hjson",
        "javascript",
        "tsx",
        "lua",
        "json",
        "jsonc",
        "python",
        "toml",
        "tsx",
        "typescript",
        "yaml",
    },
    highlight = { enable = true },
    autotag = { enable = true },
    matchup = {
        enable = true,
    },
    refactor = {
        navigation = {
            enable = true,
            keymaps = {
                goto_next_usage = "<M-n>",
                goto_previous_usage = "<M-p>",
            },
        },
    },
})
