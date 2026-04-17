return {
    "lewis6991/gitsigns.nvim",
    config = function()
        local wk = require("which-key")
        wk.add({
            { "<leader>g", group = "Git" },
            -- { "<leader>gg", "<cmd>aboveleft G<cr>", desc = "Fugitive" },
            { "<leader>gg", "<cmd>Gedit :<cr>", desc = "Fugitive" },
            { "<leader>gi", "<cmd>PreviewHunkInline<cr>", desc = "Preview Hunk Inline" },
            { "<leader>gj", "<cmd>NextHunk<cr>", desc = "Next Hunk" },
            { "<leader>gk", "<cmd>PrevHunk<cr>", desc = "Prev Hunk" },
            { "<leader>gp", "<cmd>PreviewHunk<cr>", desc = "Preview Hunk" },
            { "<leader>gr", "<cmd>ResetHunk<cr>", desc = "Reset Hunk" },
            { "<leader>gR", "<cmd>ResetBuffer<cr>", desc = "Reset Buffer" },
            { "<leader>gs", "<cmd>StageHunk<cr>", desc = "Stage Hunk" },
            { "<leader>gu", "<cmd>UndoStageHunk<cr>", desc = "Undo Last Stage Hunk" },
            { "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open Changed File" },
            { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout Branch" },
            { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout Commit" },
            { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Checkout Commit(For Current File)" },
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
                        gitsigns.nav_hunk("next")
                    end
                end)

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev")
                    end
                end)
            end,
        })
    end,
}
