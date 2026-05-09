return { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    init = function()
        -- Register html parser for the html_tags pseudo-language used by vue's
        -- injection queries ("; inherits: html_tags"). Without this, neovim 0.12+
        -- fails to resolve the inheritance and all vue injections silently break.
        vim.treesitter.language.register("html", "html_tags")
        vim.treesitter.language.register("tsx", "typescriptreact")
    end,
    config = function(_, opts)
        require("nvim-treesitter").setup(opts)

        -- The new nvim-treesitter (v1.0+) only handles parser installation.
        -- Highlighting, indentation, etc. must be enabled via neovim's native
        -- treesitter API. Enable highlighting for all buffers with a parser.
        vim.api.nvim_create_autocmd("FileType", {
            desc = "Enable treesitter highlighting",
            callback = function(args)
                local ok = pcall(vim.treesitter.start, args.buf)
                if ok and vim.tbl_contains(opts.highlight.additional_vim_regex_highlighting or {}, vim.bo[args.buf].filetype) then
                    vim.bo[args.buf].syntax = "on"
                end
            end,
        })

        -- Enable treesitter-based indentation (respecting disable list)
        local indent_disable = {}
        for _, lang in ipairs(opts.indent and opts.indent.disable or {}) do
            indent_disable[lang] = true
        end
        vim.api.nvim_create_autocmd("FileType", {
            desc = "Enable treesitter indentation",
            callback = function(args)
                if not indent_disable[vim.bo[args.buf].filetype] then
                    local ok = pcall(vim.treesitter.get_parser, args.buf)
                    if ok then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end
            end,
        })
    end,
    opts = {
        ensure_installed = {
            "bash",
            "c",
            "css",
            "diff",
            "html",
            "http",
            "javascript",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "pug",
            "query",
            "scss",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "vue",
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
            enable = true,
            -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            --  If you are experiencing weird indenting issues, add the language to
            --  the list of additional_vim_regex_highlighting and disabled languages for indent.
            additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby", "vue" } },
        matchup = { enable = true },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["aa"] = "@parameter.outer",
                    ["ia"] = "@parameter.inner",
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    ["ax"] = "@attribute.outer",
                    ["ix"] = "@attribute.inner",
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
        },
    },
}
