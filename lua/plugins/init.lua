local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

return require("packer").startup(function(use)
    use({ "wbthomason/packer.nvim" })

    local config = function(name)
        return string.format("require('plugins.%s')", name)
    end

    local use_with_config = function(path, name)
        use({ path, config = config(name) })
    end

    -- basic
    use("tpope/vim-rsi")
    use("tpope/vim-repeat")
    use("tpope/vim-eunuch")
    use("tpope/vim-capslock")
    use("tpope/vim-unimpaired")
    use({
        "tpope/vim-fugitive",
        { "tpope/vim-rhubarb", "junegunn/gv.vim", "tommcdo/vim-fugitive-blame-ext" },
    })
    use_with_config("shumphrey/fugitive-gitlab.vim", "fugitivegitlab")
    use_with_config("lewis6991/impatient.nvim", "impatient")
    use_with_config("lewis6991/gitsigns.nvim", "gitsigns")
    use_with_config("kylechui/nvim-surround", "surround")
    use_with_config("numToStr/Comment.nvim", "comment")

    -- custom
    use_with_config("kyazdani42/nvim-tree.lua", "nvimtree")
    use_with_config("bkad/CamelCaseMotion", "camelcasemotion")
    use_with_config("folke/trouble.nvim", "trouble")
    use_with_config("folke/which-key.nvim", "whichkey")
    use_with_config("folke/todo-comments.nvim", "todocomments")
    use_with_config("akinsho/nvim-toggleterm.lua", "toggleterm")
    use_with_config("rhysd/clever-f.vim", "cleverf")
    use_with_config("andymass/vim-matchup", "matchup")
    use({ "haya14busa/vim-asterisk" })
    use({ "haya14busa/is.vim" })
    use({ "szw/vim-maximizer" })
    use({ "osyo-manga/vim-anzu" })
    use({ "ThePrimeagen/harpoon" })

    -- text objects
    use("wellle/targets.vim") -- many useful additional text objects
    use("machakann/vim-swap") -- swap delimited items
    use("mg979/vim-visual-multi") -- multiple cursors
    use({
        "whatyouhide/vim-textobj-xmlattr", -- text objects for html attributes
        requires = "kana/vim-textobj-user",
    })

    -- cmp plugins
    use({
        "hrsh7th/nvim-cmp", -- completion
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "folke/neodev.nvim", -- better lua-language-server settings
            "saadparwaiz1/cmp_luasnip", -- snippet completions
        },
        config = config("cmp"),
    })

    -- snippets
    use_with_config("L3MON4D3/LuaSnip", "luasnip") -- snippet engine

    use({
        "windwp/nvim-autopairs", -- autocomplete pairs
        config = config("autopairs"),
        wants = "nvim-cmp",
    })
    use("jessarcher/vim-heritage") -- automatically create parent dirs when saving

    -- integrations
    use({
        "nvim-telescope/telescope.nvim",
        config = config("telescope"),
        requires = {
            {
                "nvim-telescope/telescope-fzf-native.nvim", -- better algorithm
                run = "make",
            },
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
    })

    -- lsp
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim")
    use("jose-elias-alvarez/nvim-lsp-ts-utils")
    use("jose-elias-alvarez/typescript.nvim")
    use("tamago324/nlsp-settings.nvim") -- language server settings defined in json
    use("b0o/schemastore.nvim") -- simple access to json-language-server schemae
    use("williamboman/nvim-lsp-installer")
    use("williamboman/mason.nvim")
    use_with_config("williamboman/mason-lspconfig.nvim", "mason")

    -- development
    use({ "Exafunction/codeium.vim" })
    use("nvim-lua/plenary.nvim")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config("treesitter"),
    })
    use("nvim-treesitter/nvim-treesitter-context")
    use("nvim-treesitter/nvim-treesitter-refactor")
    use("nvim-treesitter/nvim-treesitter-textobjects")
    use({
        "JoosepAlviste/nvim-ts-context-commentstring",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        config = config("ts_context_commentstring"),
    }) -- makes jsx comments actually work
    use({ "windwp/nvim-ts-autotag", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- autocomplete close jsx tags
    use_with_config("ahmedkhalf/project.nvim", "project")

    -- visual
    use("moll/vim-bbye")
    use("folke/zen-mode.nvim")
    use("ellisonleao/glow.nvim")
    use("stevearc/dressing.nvim")
    use("kyazdani42/nvim-web-devicons")
    use({ "RRethy/vim-hexokinase", config = config("hexokinase"), run = "make hexokinase" })
    use({ "j-hui/fidget.nvim", config = config("fidget"), tag = "legacy" })
    use_with_config("goolord/alpha-nvim", "alpha")
    use_with_config("nvim-lualine/lualine.nvim", "lualine") -- statusline and tabline
    use_with_config("gelguy/wilder.nvim", "wilder") -- wildmenu
    use_with_config("folke/tokyonight.nvim", "tokyonight") -- theme

    -- misc
    use({
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        config = "vim.cmd[[doautocmd BufEnter]]",
        run = "cd app && yarn install",
        cmd = "MarkdownPreview",
    })
    use("edwinchen85/vim-px-to-rem")
    use_with_config("NTBBloodbath/rest.nvim", "rest")
    use_with_config("AndrewRadev/splitjoin.vim", "splitjoin") -- split arrays and methods onto multiple lines, or join them up
    use({
        "glacambre/firenvim",
        run = function()
            vim.fn["firenvim#install"](0, 'export PATH="$PATH"')
        end,
        config = config("firenvim"),
    })
end)
