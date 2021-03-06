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
    textobjects = {
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        lsp_interop = {
            enable = true,
            border = "none",
            peek_definition_code = {
                ["<leader>po"] = "@class.outer",
                ["<leader>pO"] = "@function.outer",
            },
        },
    },
})
