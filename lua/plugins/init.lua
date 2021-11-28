vim.cmd("packadd packer.nvim")
return require("packer").startup(function()
    use({ "wbthomason/packer.nvim", opt = true })

    local config = function(name)
        return string.format("require('plugins.%s')", name)
    end

    local use_with_config = function(path, name)
        use({ path, config = config(name) })
    end

    -- basic
    use("tpope/vim-rsi")
    use("tpope/vim-repeat")
    use("tpope/vim-sleuth")
    use("tpope/vim-capslock")
    use("tpope/vim-surround")
    use("tpope/vim-unimpaired")
    use({
        "tpope/vim-fugitive",
        { "junegunn/gv.vim", "tommcdo/vim-fugitive-blame-ext" }
    })
    use_with_config("lewis6991/gitsigns.nvim", "gitsigns")
    use_with_config("numToStr/Comment.nvim", "comment")

    -- custom
    use_with_config("kyazdani42/nvim-tree.lua", "nvimtree")
    use_with_config("cappyzawa/trim.nvim", "trim")
    use_with_config("bkad/CamelCaseMotion", "camelcasemotion")
    use_with_config("folke/which-key.nvim", "whichkey")
    use_with_config("folke/todo-comments.nvim", "todocomments")
    use_with_config("akinsho/nvim-toggleterm.lua", "toggleterm")
    use_with_config("rhysd/clever-f.vim", "cleverf")
    use_with_config("justinmk/vim-ipmotion", "ipmotion")
    use({ "jeffkreeftmeijer/vim-numbertoggle" })
    use({ "haya14busa/vim-asterisk" })
    use({ "haya14busa/is.vim" })
    use({ "lambdalisue/suda.vim" })
    use({ "andymass/vim-matchup" })
    use({ "szw/vim-maximizer" })
    use({ "sickill/vim-pasta" })

    -- text objects
    use("wellle/targets.vim") -- many useful additional text objects

    -- additional functionality
    use_with_config("abecodes/tabout.nvim", "tabout") -- tab out of pairs
    use_with_config("hrsh7th/vim-vsnip", "vsnip") -- snippets
    use({
        "hrsh7th/nvim-cmp", -- completion
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-path",
        },
        config = config("cmp"),
    })
    use({
        "windwp/nvim-autopairs", -- autocomplete pairs
        config = config("autopairs"),
        wants = "nvim-cmp",
    })

    -- integrations
    use({
        "nvim-telescope/telescope.nvim",
        config = config("telescope"),
        requires = {
            {
            "nvim-telescope/telescope-fzf-native.nvim", -- better algorithm
            run = "make",
            }
        },
    })

    -- lsp
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim")
    use("b0o/schemastore.nvim") -- simple access to json schema

    -- development
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config("treesitter"),
    })
    use({ "JoosepAlviste/nvim-ts-context-commentstring", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- makes jsx comments actually work
    use({ "windwp/nvim-ts-autotag", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- autocomplete close jsx tags
    use_with_config("ahmedkhalf/project.nvim", "project")

    -- visual
    use("folke/tokyonight.nvim")
    use("kyazdani42/nvim-web-devicons")
    use_with_config("ishan9299/nvim-solarized-lua", "solarized")
    use_with_config("glepnir/dashboard-nvim", "dashboard")
    use_with_config("nvim-lualine/lualine.nvim", "lualine") -- statusline and tabline
    use_with_config("norcalli/nvim-colorizer.lua", "colorizer")

    -- local
    use("jose-elias-alvarez/nvim-lsp-ts-utils")
    use_with_config("romgrk/barbar.nvim", "bufferline")

    -- misc
    use_with_config("nathom/filetype.nvim", "filetype") -- greatly reduce startup time
    use("nvim-lua/plenary.nvim")
    use({
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        config = "vim.cmd[[doautocmd BufEnter]]",
        run = "cd app && yarn install",
        cmd = "MarkdownPreview",
    })
end)
