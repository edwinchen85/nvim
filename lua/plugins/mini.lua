return {
    -- Icons
    {
        "echasnovski/mini.icons",
        lazy = true,
        version = false,
        opts = {},
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    -- Split & join
    {
        "echasnovski/mini.splitjoin",
        keys = { "gJ", "gS" },
        config = function()
            local miniSplitJoin = require("mini.splitjoin")
            miniSplitJoin.setup({
                mappings = { toggle = "" }, -- Disable default mapping
            })
            vim.keymap.set({ "n", "x" }, "gJ", function()
                miniSplitJoin.join()
            end, { desc = "Join arguments" })
            vim.keymap.set({ "n", "x" }, "gS", function()
                miniSplitJoin.split()
            end, { desc = "Split arguments" })
        end,
    },
}
