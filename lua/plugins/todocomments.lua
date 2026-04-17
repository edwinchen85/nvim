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
            function()
                Snacks.picker.todo_comments({ hidden = true })
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
