-- Gitsigns captures hunk-preview highlights (removed side, deleted-preview
-- virt_lines) from scratch buffers that are never shown in a window.
-- Treesitter only parses ranges an actual redraw touches, so an off-screen
-- buffer's tree stays empty and those lines render with no syntax highlight
-- at all. Force a sync parse right before gitsigns reads captures back out --
-- every capture path (preview_hunk, preview_hunk_inline, deleted_preview)
-- routes through this one function.
local function patch_scratch_buf_highlighting()
    local capture = require("gitsigns.render.capture")
    local capture_node = capture.capture_node
    capture.capture_node = function(bufnr, ...)
        pcall(function()
            vim.treesitter.get_parser(bufnr):parse(true)
        end)
        return capture_node(bufnr, ...)
    end
end

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        patch_scratch_buf_highlighting()
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
