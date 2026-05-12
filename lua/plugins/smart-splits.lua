return {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    init = function()
        vim.g.smart_splits_multiplexer_integration = "tmux"
    end,
    config = function()
        require("smart-splits").setup({
            ignored_buftypes = { "nofile", "quickfix", "prompt" },
            ignored_filetypes = { "NvimTree" },
            multiplexer_integration = "tmux",
        })

        local function nav(wincmd, tmux_flag)
            local cur = vim.api.nvim_get_current_win()
            vim.cmd("wincmd " .. wincmd)
            if cur == vim.api.nvim_get_current_win() then
                vim.fn.system(string.format([[tmux if -F '#{window_zoomed_flag}' '' 'select-pane %s']], tmux_flag))
            end
        end

        vim.keymap.set("n", "<C-h>", function()
            nav("h", "-L")
        end, { desc = "Nav left" })
        vim.keymap.set("n", "<C-j>", function()
            nav("j", "-D")
        end, { desc = "Nav down" })
        vim.keymap.set("n", "<C-k>", function()
            nav("k", "-U")
        end, { desc = "Nav up" })
        vim.keymap.set("n", "<C-l>", function()
            nav("l", "-R")
        end, { desc = "Nav right" })
    end,
}
