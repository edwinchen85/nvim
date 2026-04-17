local M = {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
    },
}

function M.config()
    require("harpoon").setup({
        -- menu = {
        --     width = math.ceil(vim.api.nvim_win_get_width(0) / 7 * 3),
        -- },
        menu = {
            width = 80,
        },
    })

    local u = require("config.utils")
    u.nmap("gm", "m") -- remap mark

    local wk = require("which-key")
    wk.add({
        { "<leader>m", group = "Harpoon" },
        { "<leader>ma", "<cmd>lua require('plugins.harpoon').mark_file()<cr>", desc = "Add Mark" },
        { "<leader>mm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Toggle Menu" },
        { "<leader>mp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Prev Mark" },
        { "<leader>mn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Next Mark" },
    })
end

function M.mark_file()
    require("harpoon.mark").add_file()
    vim.notify("󱡅  marked file")
end

-- return M
return {}
