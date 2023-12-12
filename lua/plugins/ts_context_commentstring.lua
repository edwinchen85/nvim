vim.g.skip_ts_context_commentstring_module = true

require("ts_context_commentstring").setup({
    -- Whether to update the `commentstring` on the `CursorHold` autocmd
    enable_autocmd = true,

    -- Custom logic for calculating the commentstring.
    custom_calculation = nil,

    -- Keybindings to use for the commentary.nvim integration
    commentary_integration = {
        Commentary = "gc",
        CommentaryLine = "gcc",
        ChangeCommentary = "cgc",
        CommentaryUndo = "gcu",
    },

    languages = {
        -- Languages that have a single comment style
        astro = "<!-- %s -->",
        c = { __default = "// %s", __multiline = "/* %s */" },
        css = "/* %s */",
        glimmer = "{{! %s }}",
        go = { __default = "// %s", __multiline = "/* %s */" },
        graphql = "# %s",
        haskell = "-- %s",
        handlebars = "{{! %s }}",
        html = "<!-- %s -->",
        lua = { __default = "-- %s", __multiline = "--[[ %s ]]" },
        nix = { __default = "# %s", __multiline = "/* %s */" },
        php = { __default = "// %s", __multiline = "/* %s */" },
        python = { __default = "# %s", __multiline = '""" %s """' },
        rescript = { __default = "// %s", __multiline = "/* %s */" },
        scss = { __default = "// %s", __multiline = "/* %s */" },
        sh = "# %s",
        bash = "# %s",
        solidity = { __default = "// %s", __multiline = "/* %s */" },
        sql = "-- %s",
        svelte = "<!-- %s -->",
        twig = "{# %s #}",
        typescript = { __default = "// %s", __multiline = "/* %s */" },
        vim = '" %s',
        vue = "<!-- %s -->",
        zsh = "# %s",

        -- Languages that can have multiple types of comments
        tsx = {
            __default = "// %s",
            __multiline = "/* %s */",
            jsx_element = "{/* %s */}",
            jsx_fragment = "{/* %s */}",
            jsx_attribute = { __default = "// %s", __multiline = "/* %s */" },
            comment = { __default = "// %s", __multiline = "/* %s */" },
            call_expression = { __default = "// %s", __multiline = "/* %s */" },
            statement_block = { __default = "// %s", __multiline = "/* %s */" },
            spread_element = { __default = "// %s", __multiline = "/* %s */" },
        },
    },

    ---@deprecated Use the languages configuration instead!
    config = {},
})
