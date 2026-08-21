return { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    init = function()
        -- Diff-hunk language injection for fugitive's :Git buffers; drives
        -- after/queries/diff/injections.scm.
        require("config.diff_lang").setup()

        -- Register html parser for the html_tags pseudo-language used by vue's
        -- injection queries ("; inherits: html_tags"). Without this, neovim 0.12+
        -- fails to resolve the inheritance and all vue injections silently break.
        vim.treesitter.language.register("html", "html_tags")
        vim.treesitter.language.register("tsx", "typescriptreact")
    end,
    config = function(_, opts)
        local ts = require("nvim-treesitter")
        ts.setup(opts)

        -- nvim-treesitter v1.0+ only handles parser installation, and its setup()
        -- reads nothing but install_dir — ensure_installed, auto_install, highlight
        -- and indent are all ours to honour from here.
        local installed = {}
        local function refresh_installed()
            installed = {}
            for _, lang in ipairs(ts.get_installed("parsers")) do
                installed[lang] = true
            end
        end
        refresh_installed()

        local missing = vim.tbl_filter(function(lang)
            return not installed[lang]
        end, opts.ensure_installed)
        if #missing > 0 then
            ts.install(missing):await(vim.schedule_wrap(refresh_installed))
        end

        local additional_regex = opts.highlight and opts.highlight.additional_vim_regex_highlighting or {}
        local indent_disable = {}
        for _, lang in ipairs(opts.indent and opts.indent.disable or {}) do
            indent_disable[lang] = true
        end

        vim.api.nvim_create_autocmd("FileType", {
            desc = "Enable treesitter highlighting and indentation",
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                local lang = vim.treesitter.language.get_lang(ft)
                if not lang then
                    return
                end

                local function start()
                    if not vim.api.nvim_buf_is_valid(args.buf) then
                        return
                    end
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end
                    -- some languages still need vim's regex engine for indent rules
                    if vim.tbl_contains(additional_regex, ft) then
                        vim.bo[args.buf].syntax = "on"
                    end
                    if not indent_disable[ft] then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end

                if installed[lang] then
                    start()
                elseif opts.auto_install and vim.tbl_contains(ts.get_available(), lang) then
                    ts.install({ lang }):await(vim.schedule_wrap(function()
                        refresh_installed()
                        start()
                    end))
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
            additional_vim_regex_highlighting = { "ruby", "fugitive", "git" },
        },
        indent = { enable = true, disable = { "ruby", "vue", "fugitive", "git" } },
        -- matchup is driven by its own plugin spec; textobjects live in
        -- plugins/textobjects.lua — v1.0's setup() ignores both keys.
    },
}
