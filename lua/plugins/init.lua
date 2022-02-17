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
    use("tpope/vim-surround")
    use("tpope/vim-unimpaired")
    use({
        "tpope/vim-fugitive",
        { "junegunn/gv.vim", "tommcdo/vim-fugitive-blame-ext" },
    })
    use_with_config("shumphrey/fugitive-gitlab.vim", "fugitivegitlab")
    use_with_config("lewis6991/impatient.nvim", "impatient")
    use_with_config("lewis6991/gitsigns.nvim", "gitsigns")
    use_with_config("numToStr/Comment.nvim", "comment")

    -- custom
    use_with_config("kyazdani42/nvim-tree.lua", "nvimtree")
    use_with_config("bkad/CamelCaseMotion", "camelcasemotion")
    use_with_config("folke/which-key.nvim", "whichkey")
    use_with_config("folke/todo-comments.nvim", "todocomments")
    use_with_config("akinsho/nvim-toggleterm.lua", "toggleterm")
    use_with_config("rhysd/clever-f.vim", "cleverf")
    use_with_config("andymass/vim-matchup", "matchup")
    use({ "jeffkreeftmeijer/vim-numbertoggle" })
    use({ "haya14busa/vim-asterisk" })
    use({ "haya14busa/is.vim" })
    use({ "szw/vim-maximizer" })
    use({ "osyo-manga/vim-anzu" })
    use({ "edwinchen85/vim-pasta" })
    use({ "ThePrimeagen/harpoon" })

    -- text objects
    use("wellle/targets.vim") -- many useful additional text objects
    use("machakann/vim-swap") -- swap delimited items

    -- cmp plugins
    use({
        "hrsh7th/nvim-cmp", -- completion
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-path",
            "folke/lua-dev.nvim",
            "saadparwaiz1/cmp_luasnip", -- snippet completions
        },
        config = config("cmp"),
    })

    -- snippets
    use("L3MON4D3/LuaSnip") --snippet engine
    use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

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
            },
        },
    })

    -- lsp
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim")
    use("jose-elias-alvarez/nvim-lsp-ts-utils")
    use("williamboman/nvim-lsp-installer")
    use("tamago324/nlsp-settings.nvim") -- language server settings defined in json

    -- development
    use("nvim-lua/plenary.nvim")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config("treesitter"),
    })
    use("nvim-treesitter/nvim-treesitter-refactor")
    use({
        "JoosepAlviste/nvim-ts-context-commentstring",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    }) -- makes jsx comments actually work
    use({ "windwp/nvim-ts-autotag", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } }) -- autocomplete close jsx tags
    use_with_config("ahmedkhalf/project.nvim", "project")

    -- visual
    use("moll/vim-bbye")
    use("folke/tokyonight.nvim")
    use("kyazdani42/nvim-web-devicons")
    use_with_config("ishan9299/nvim-solarized-lua", "solarized")
    use_with_config("rebelot/kanagawa.nvim", "kanagawa")
    use_with_config("goolord/alpha-nvim", "alpha")
    use_with_config("nvim-lualine/lualine.nvim", "lualine") -- statusline and tabline
    use_with_config("norcalli/nvim-colorizer.lua", "colorizer")

    -- misc
    use({
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        config = "vim.cmd[[doautocmd BufEnter]]",
        run = "cd app && yarn install",
        cmd = "MarkdownPreview",
    })
end)
