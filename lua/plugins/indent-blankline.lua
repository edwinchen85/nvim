return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        -- IblIndent comes from the colorscheme (tokyonight's
        -- `groups/indent-blankline.lua`); ibl's `highlights.lua` falls back to
        -- `Whitespace` for themes that skip it.
        require("ibl").setup({
            scope = {
                highlight = "IblIndent",
                show_start = false,
                show_end = false,
                show_exact_scope = false,
            },
            indent = {
                char = "▏",
                highlight = "IblIndent",
            },
            exclude = {
                filetypes = {
                    "help",
                    "json",
                    "alpha",
                    "neo-tree",
                    "snacks_dashboard",
                    "Trouble",
                },
            },
        })
    end,
}
