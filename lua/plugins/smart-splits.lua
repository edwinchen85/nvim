return {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    -- v3 ships no backends; tmux support is this separate plugin.
    dependencies = {
        { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
    },
    config = function()
        require("smart-splits").setup({
            ignored_buftypes = { "nofile", "quickfix", "prompt" },
            ignored_filetypes = { "NvimTree" },
            -- Outside tmux (headless checks, a bare terminal) no backend, else it warns.
            mux = { backend = vim.env.TMUX and "smart-splits-backend-tmux" or nil },
        })

        local function nav(wincmd, tmux_flag)
            local cur = vim.api.nvim_get_current_win()
            local prev = vim.fn.win_getid(vim.fn.winnr("#"))
            vim.cmd("wincmd " .. wincmd)
            -- Going up/down from a full-width split (toggleterm) picks the window over
            -- the cursor's column, often the side tree. Prefer the last-used window,
            -- else the one right of the tree.
            if (wincmd == "j" or wincmd == "k") and vim.bo.filetype == "NvimTree" then
                local tree = vim.api.nvim_get_current_win()
                local function rows(win)
                    local top = vim.api.nvim_win_get_position(win)[1]
                    return top, top + vim.api.nvim_win_get_height(win)
                end
                local ok_prev = prev ~= 0
                    and prev ~= cur
                    and prev ~= tree
                    and vim.api.nvim_win_get_config(prev).relative == ""
                if ok_prev then
                    local cur_top, cur_bot = rows(cur)
                    local prev_top, prev_bot = rows(prev)
                    ok_prev = wincmd == "k" and prev_bot <= cur_top or wincmd == "j" and prev_top >= cur_bot
                end
                if ok_prev then
                    vim.api.nvim_set_current_win(prev)
                else
                    vim.cmd("wincmd l")
                end
            end
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
        -- In toggleterm, up/down only: the shell takes <C-j> as Enter and <C-k> is
        -- unused, while <C-h>/<C-l> stay the shell's (backspace, clear screen).
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "toggleterm",
            callback = function(ev)
                vim.keymap.set("t", "<C-j>", function()
                    nav("j", "-D")
                end, { buffer = ev.buf, desc = "Nav down" })
                vim.keymap.set("t", "<C-k>", function()
                    nav("k", "-U")
                end, { buffer = ev.buf, desc = "Nav up" })
            end,
        })
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
