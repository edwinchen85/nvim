vim.cmd("packadd packer.nvim")
return require("packer").startup(function()
    use("wbthomason/packer.nvim")

    local config = function(name)
        pcall(require, "plugins." .. name)
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
    use("tpope/vim-commentary")
    use({
        "tpope/vim-fugitive",
        { "junegunn/gv.vim", "tommcdo/vim-fugitive-blame-ext" }
    })
    use_with_config("lewis6991/gitsigns.nvim", "gitsigns")

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
    use({
        "kana/vim-textobj-user",
        {
            "thinca/vim-textobj-between", -- af/if for region between characters
            "Julian/vim-textobj-variable-segment", -- av/iv for variable segment
            "kana/vim-textobj-entire", -- ae/ie for entire buffer
            "beloglazov/vim-textobj-punctuation", -- au/iu for punctuation
            "preservim/vim-textobj-sentence", -- better sentences
        },
    })

    -- additional functionality
    use({
        "hrsh7th/nvim-cmp", -- completion
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
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
    use_with_config("mcchrish/nnn.vim", "nnn") -- file manager integration

    -- development
    use("neovim/nvim-lspconfig")
    use("nvim-lua/plenary.nvim")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config("treesitter"),
    })
    use({ "JoosepAlviste/nvim-ts-context-commentstring", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- makes jsx comments actually work
    use({ "windwp/nvim-ts-autotag", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- autocomplete close jsx tags
    use_with_config("ahmedkhalf/lsp-rooter.nvim", "rooter") -- automagically change working directory

    -- autocomplete
    use_with_config("hrsh7th/nvim-compe", "compe")
    use({ "hrsh7th/vim-vsnip" })
    use({ "rafamadriz/friendly-snippets" })

    -- visual
    use("folke/tokyonight.nvim")
    use("kyazdani42/nvim-web-devicons")
    use("onsails/lspkind-nvim")
    use_with_config("glepnir/dashboard-nvim", "dashboard")
    use_with_config("norcalli/nvim-colorizer.lua", "colorizer")

    -- local
    use_with_config("jose-elias-alvarez/buftabline.nvim", "buftabline")
    use("jose-elias-alvarez/nvim-lsp-ts-utils")
    use("jose-elias-alvarez/null-ls.nvim")

    -- misc
    use({
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        config = "vim.cmd[[doautocmd BufEnter]]",
        run = "cd app && yarn install",
        cmd = "MarkdownPreview",
    })
end)
