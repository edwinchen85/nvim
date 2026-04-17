return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local hooks = require("ibl.hooks")

        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#41425e" })
        end)

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
