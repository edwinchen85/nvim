return {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    init = function()
        -- Outside tmux (headless checks, a bare terminal) the integration only warns
        -- "could not detect pane ID".
        vim.g.smart_splits_multiplexer_integration = vim.env.TMUX and "tmux" or false
    end,
    config = function()
        require("smart-splits").setup({
            ignored_buftypes = { "nofile", "quickfix", "prompt" },
            ignored_filetypes = { "NvimTree" },
            multiplexer_integration = vim.g.smart_splits_multiplexer_integration,
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
            -- The sidekick CLI is a right-side float, outside the split layout: prefer the
            -- split to the right, unless the float hides it, then the float, then tmux.
            local sidekick = require("util.sidekick")
            local right = vim.fn.win_getid(vim.fn.winnr("l"))
            if right ~= vim.api.nvim_get_current_win() and not sidekick.hidden_by_cli_win(right) then
                vim.api.nvim_set_current_win(right)
            elseif not sidekick.focus_cli_win() then
                nav("l", "-R")
            end
        end, { desc = "Nav right" })
    end,
}
