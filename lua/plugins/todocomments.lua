return {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--hidden",
            },
            pattern = [[\b(KEYWORDS):]],
        },
    },
    keys = {
        {
            "<leader>ft",
            -- live_grep on todo-comments' keyword regex. Pinned to regex mode: the
            -- picker defaults to "plain", which matches the pattern literally.
            function()
                require("fff").live_grep({
                    query = [[\b(TODO|FIXME|HACK|WARN|PERF|NOTE|TEST)\b:?]],
                    grep = { modes = { "regex" } },
                })
            end,
            desc = "Todo",
        },
        {
            "]t",
            function()
                require("todo-comments").jump_next()
            end,
            desc = "Next todo comment",
        },
        {
            "[t",
            function()
                require("todo-comments").jump_prev()
            end,
            desc = "Prev todo comment",
        },
    },
}
