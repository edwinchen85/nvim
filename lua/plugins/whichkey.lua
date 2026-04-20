return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "classic",
        plugins = {
            marks = true, -- shows a list of your marks on ' and `
            registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            -- the presets plugin, adds help for a bunch of default keybindings in Neovim
            -- No actual key bindings are created
            presets = {
                operators = false, -- adds help for operators like d, y, ...
                motions = false, -- adds help for motions
                text_objects = false, -- help for text objects triggered after entering an operator
                windows = true, -- default bindings on <c-w>
                nav = false, -- misc bindings to work with windows
                z = true, -- bindings for folds, spelling and others prefixed with z
                g = true, -- bindings for prefixed with g
            },
        },
        replace = {
            key = {
                function(key)
                    return require("which-key.view").format(key)
                end,
            },
            desc = {
                { "<Plug>%(?(.*)%)?", "%1" },
                { "^%+", "" },
                { "<[cC]md>", "" },
                { "<[cC][rR]>", "" },
                { "<[sS]ilent>", "" },
                { "^lua%s+", "" },
                { "^call%s+", "" },
                { "^:%s*", "" },
            },
        },
        icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
            separator = "➜", -- symbol used between a key and it's label
            group = "+", -- symbol prepended to a group
        },
        win = {
            no_overlap = true,
            border = "rounded",
            padding = { 2, 2, 2, 2 },
            title = true,
            title_pos = "center",
            zindex = 1000,
            wo = {
                windblend = 100,
            },
        },
        layout = {
            align = "bottom",
            height = { min = 4, max = 25 }, -- min and max height of the columns
            width = { min = 20, max = 50 }, -- min and max width of the columns
            spacing = 10, -- spacing between columns
            winblend = 100,
        },
        disable = {
            ft = { "fugitive" },
            bt = {},
        },
    },
    keys = {
        { "<leader>h", "<cmd>nohl<cr>", desc = "No Highlight" },
        { "<leader>;", "@:", desc = "Repeat Command" },
        { "<leader>A", "<cmd>Alpha<cr>", desc = "Alpha" },
        {
            "<leader>c",
            function()
                Snacks.bufdelete()
            end,
            desc = "Close Buffer",
        },
        {
            "<leader>C",
            function()
                Snacks.bufdelete.all()
            end,
            desc = "Close All Buffers",
        },
        { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
        { "<leader>q", "<cmd>ToggleQuickFix<cr>", desc = "Toggle Quickfix" },
        { "<leader>R", "<cmd>RotateWindows<cr>", desc = "Rotate Windows" },
        { "<leader>v", "<cmd>vsp #<cr>", desc = "Vsplit Last" },
        { "<leader>w", "<cmd>w<cr>", desc = "Save" },
        { "<leader>W", "<cmd>noa w<cr>", desc = "Save (No Format)" },
        { "<leader><leader>", "<C-^>", desc = "Previous Buffer" },
        { "<leader>a", group = "Claude Code", desc = "Claude Code" },
        { "<leader><tab>", group = "Tab", desc = "Tab" },
        { "<leader><tab>c", "<cmd>set cursorline!<cr>", desc = "Cursor Line" },
        { "<leader><tab>d", "<cmd>ToggleDiagnostics<cr>", desc = "Diagnostics" },
        { "<leader><tab>i", "<cmd>ToggleInlayHint<cr>", desc = "Inlay Hint" },
        { "<leader><tab>n", "<cmd>set relativenumber!<cr>", desc = "Relative Number" },
        { "<leader><tab>p", "<cmd>Px!<cr>", desc = "Rem to Px" },
        { "<leader><tab>r", "<cmd>Rem!<cr>", desc = "Px to Rem" },
        { "<leader><tab>v", "<cmd>ToggleVirtualText<cr>", desc = "Virtual Text" },
        { "<leader><tab>w", "<cmd>lua vim.wo.wrap = not vim.wo.wrap<cr>", desc = "Wrap" },
    },
}
