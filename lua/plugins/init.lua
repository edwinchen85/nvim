vim.cmd("packadd packer.nvim")
return require("packer").startup(function()
    use({ "wbthomason/packer.nvim", opt = true })

    local config = function(name)
        pcall(require, "plugins." .. name)
    end
    local use_with_config = function(opts)
        local path, name = opts[1], opts[2]
        use({ path, config = config(name) })
    end

    -- basic
    use("tpope/vim-repeat")
    use("tpope/vim-surround")
    use("tpope/vim-unimpaired")
    use("tpope/vim-commentary")
    use({
        "tpope/vim-fugitive",
        { "tpope/vim-rhubarb", "junegunn/gv.vim" },
    })
    use_with_config({ "lewis6991/gitsigns.nvim", "gitsigns" })

    -- text objects
    use("wellle/targets.vim")
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
    use_with_config({ "phaazon/hop.nvim", "hop" }) -- motion
    use_with_config({ "windwp/nvim-autopairs", "autopairs" }) -- autocomplete pairs
    use_with_config({ "svermeulen/vim-subversive", "subversive" }) -- adds substitute operator
    use_with_config({ "svermeulen/vim-cutlass", "cutlass" }) -- makes registers less annoying
    use({
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/popup.nvim" },
        config = config("telescope"),
    })
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- better algorithm

    -- integrations
    use_with_config({ "numToStr/Navigator.nvim", "navigator" }) -- tmux / vim pane navigation
    use_with_config({ "mcchrish/nnn.vim", "nnn" }) -- file manager integration
    use_with_config({ "christoomey/vim-tmux-runner", "vtr" }) -- run commands in a linked tmux pane

    -- development
    use("neovim/nvim-lspconfig")
    use("nvim-lua/plenary.nvim")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config("treesitter"),
        { "nvim-treesitter/playground" },
    })
    use("RRethy/nvim-treesitter-textsubjects") -- adds smart . text object
    use("JoosepAlviste/nvim-ts-context-commentstring") -- makes jsx comments actually work
    use("windwp/nvim-ts-autotag") -- autocomplete jsx tags

    -- visual
    use("sainnhe/sonokai")
    use_with_config({ "RRethy/vim-illuminate", "illuminate" }) -- highlight and jump between references

    -- local
    use_with_config({ "~/git/buftabline.nvim", "buftabline" })
    use("~/git/nvim-lsp-ts-utils")
    use("~/git/null-ls")
    use_with_config({ "~/git/minsnip.nvim", "minsnip" })

    -- misc
    use("blankname/vim-fish")
    use("teal-language/vim-teal")
    use({
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        config = "vim.cmd[[doautocmd BufEnter]]",
        run = "cd app && yarn install",
        cmd = "MarkdownPreview",
    })
end)
