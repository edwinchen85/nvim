return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local gs = require("gitsigns")
        local wk = require("which-key")
        wk.add({
            { "<leader>g", group = "Git" },
            -- { "<leader>gg", "<cmd>aboveleft G<cr>", desc = "Fugitive" },
            { "<leader>gg", "<cmd>Gedit :<cr>", desc = "Fugitive" },
            {
                "<leader>gi",
                function()
                    gs.preview_hunk_inline()
                end,
                desc = "Preview Hunk Inline",
            },
            {
                "<leader>gj",
                function()
                    gs.next_hunk()
                end,
                desc = "Next Hunk",
            },
            {
                "<leader>gk",
                function()
                    gs.prev_hunk()
                end,
                desc = "Prev Hunk",
            },
            {
                "<leader>gp",
                function()
                    gs.preview_hunk()
                end,
                desc = "Preview Hunk",
            },
            {
                "<leader>gr",
                function()
                    gs.reset_hunk()
                end,
                desc = "Reset Hunk",
            },
            {
                "<leader>gR",
                function()
                    gs.reset_buffer()
                end,
                desc = "Reset Buffer",
            },
            {
                "<leader>gs",
                function()
                    gs.stage_hunk()
                end,
                desc = "Stage Hunk",
            },
            {
                "<leader>gS",
                function()
                    gs.stage_buffer()
                end,
                desc = "Stage Buffer",
            },
            {
                "<leader>gu",
                function()
                    gs.undo_stage_hunk()
                end,
                desc = "Undo Last Stage Hunk",
            },
            {
                "<leader>go",
                function()
                    Snacks.picker.git_status()
                end,
                desc = "Open Changed File",
            },
            {
                "<leader>gb",
                function()
                    Snacks.picker.git_branches()
                end,
                desc = "Checkout Branch",
            },
            {
                "<leader>gc",
                function()
                    Snacks.picker.git_log()
                end,
                desc = "Checkout Commit",
            },
            {
                "<leader>gC",
                function()
                    Snacks.picker.git_log_file()
                end,
                desc = "Checkout Commit(For Current File)",
            },
            { "<leader>gd", "<cmd>:Gdiff!<cr>", desc = "Git Diff" },
            { "<leader>gD", "<cmd>Gtabedit @:% | Gdiff :<cr>", desc = "Git Diff Staged" },
            { "<leader>gh", "<cmd>diffget //2<cr>", desc = "Diffget Target Branch" },
            { "<leader>gl", "<cmd>diffget //3<cr>", desc = "Diffget Merge Branch" },
            { "<leader>gv", "<cmd>GV<cr>", desc = "Git Commit Browser" },
            { "<leader>gx", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle deleted" },
        })

        require("gitsigns").setup({
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "󰐊" },
                topdelete = { text = "󰐊" },
                changedelete = { text = "▎" },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "󰐊" },
                topdelete = { text = "󰐊" },
                changedelete = { text = "▎" },
                untracked = { text = "┆" },
            },
            signs_staged_enable = true,
            numhl = false,
            linehl = false,
            watch_gitdir = { interval = 1000 },
            sign_priority = 6,
            update_debounce = 200,
            status_formatter = nil, -- Use default
            preview_config = {
                -- Options passed to nvim_open_win
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            on_attach = function(bufnr)
                if vim.api.nvim_buf_get_name(bufnr):match("fugitive") then
                    return false
                end

                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gitsigns.nav_hunk("next", { target = "all" })
                    end
                end)

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev", { target = "all" })
                    end
                end)
            end,
        })
    end,
}
