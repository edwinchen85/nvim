-- Treesitter textobjects.
--
-- nvim-treesitter v1.0 dropped module handling, so the `textobjects` table that
-- used to live in the treesitter spec is ignored. This plugin now needs its own
-- setup() call and its keymaps bound by hand.
return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true }, -- jump forward to the textobject, like targets.vim
            move = { set_jumps = true },
        })

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")

        for lhs, obj in pairs({
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ax"] = "@attribute.outer",
            ["ix"] = "@attribute.inner",
        }) do
            vim.keymap.set({ "x", "o" }, lhs, function()
                select.select_textobject(obj, "textobjects")
            end, { desc = "Select " .. obj })
        end

        for lhs, spec in pairs({
            ["]m"] = { move.goto_next_start, "@function.outer" },
            ["]]"] = { move.goto_next_start, "@class.outer" },
            ["]M"] = { move.goto_next_end, "@function.outer" },
            ["]["] = { move.goto_next_end, "@class.outer" },
            ["[m"] = { move.goto_previous_start, "@function.outer" },
            ["[["] = { move.goto_previous_start, "@class.outer" },
            ["[M"] = { move.goto_previous_end, "@function.outer" },
            ["[]"] = { move.goto_previous_end, "@class.outer" },
        }) do
            local goto_fn, obj = spec[1], spec[2]
            vim.keymap.set({ "n", "x", "o" }, lhs, function()
                goto_fn(obj, "textobjects")
            end, { desc = "Go to " .. obj })
        end
    end,
}
