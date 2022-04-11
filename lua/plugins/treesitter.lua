require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    indent = { enable = true },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    autopairs = { enable = true },
    highlight = { enable = true },
    autotag = { enable = true },
    matchup = {
        enable = true,
    },
    refactor = {
        highlight_definitions = { enable = true },
        highlight_current_scope = { enable = false },
        navigation = {
            enable = true,
            keymaps = {
                goto_next_usage = "<M-n>",
                goto_previous_usage = "<M-p>",
            },
        },
    },
})
