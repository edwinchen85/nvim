-- Rust-backed file finder + live grep. Replaces snacks' files/grep/grep_word
-- pickers only; every other snacks picker (buffers, help, lsp, git, ...) stays.
return {
    "dmtrKovalenko/fff",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- the plugin lazy-initialises itself
    opts = {
        prompt = "❯ ",
        lazy_sync = true,
        wrap_around = false, -- matches snacks `cycle = false`
        -- Mirrors the snacks "ivy" layout: bottom-anchored, half height, preview right.
        layout = {
            height = 0.5,
            width = 1,
            anchor = "bottom",
            prompt_position = "top",
            preview_position = "right",
            preview_size = 0.5,
            show_path_first = false, -- filename first, like snacks `filename_first = true`
        },
        keymaps = {
            close = "<Esc>",
            select = "<CR>",
            move_up = { "<Up>", "<C-k>", "<C-p>" },
            move_down = { "<Down>", "<C-j>", "<C-n>" },
            preview_scroll_up = "<C-u>",
            preview_scroll_down = "<C-d>",
            toggle_select = "<Tab>",
            send_to_quickfix = "<C-q>",
            focus_list = "<leader>l",
            focus_preview = "<leader>p",
        },
    },
    keys = {
        {
            "<leader>ff",
            function()
                require("fff").find_files()
            end,
            desc = "Files",
        },
        {
            "<leader>fs",
            function()
                require("fff").live_grep()
            end,
            desc = "Grep",
        },
        {
            "<leader>fr",
            function()
                require("fff").find_files()
            end,
            desc = "Recent",
        },
        {
            "<leader>fa",
            function()
                require("fff").live_grep_under_cursor()
            end,
            mode = { "n", "x" },
            desc = "Cursor",
        },
    },
}
