return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function(_, opts)
        require("claudecode").setup(opts)
        vim.api.nvim_create_autocmd("BufWinEnter", {
            callback = function(ev)
                if vim.bo[ev.buf].buftype ~= "terminal" then
                    return
                end
                local ok, ct = pcall(require, "claudecode.terminal")
                if not ok or ct.get_active_terminal_bufnr() ~= ev.buf then
                    return
                end
                vim.schedule(function()
                    local wins = vim.fn.win_findbuf(ev.buf)
                    if #wins == 0 then
                        return
                    end
                    vim.api.nvim_win_call(wins[1], function()
                        if vim.api.nvim_get_mode().mode ~= "t" then
                            vim.cmd("startinsert")
                        end
                    end)
                end)
            end,
        })
    end,
    opts = {
        terminal = {
            split_width_percentage = 0.3,
        },
        diff_opts = {
            layout = "horizontal",
        },
    },
    keys = {
        { "<leader>a", group = "Claude" },
        { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle" },
        { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus" },
        { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume" },
        { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue" },
        { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Buffer" },
        { "<leader>at", "<cmd>ClaudeCodeTreeAdd<cr>", ft = { "NvimTree" }, desc = "Add from Tree" },
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send Selection" },
        { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff" },
        { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff" },
        { "<C-h>", "<C-\\><C-n><C-w>h", mode = "t", desc = "Go to Left Window" },
        {
            "<C-f>",
            function()
                local win = vim.api.nvim_get_current_win()
                if vim.g._claude_maximized then
                    vim.g._claude_maximized = false
                    vim.api.nvim_win_set_width(win, vim.g._claude_prev_width or math.floor(vim.o.columns * 0.5))
                else
                    vim.g._claude_prev_width = vim.api.nvim_win_get_width(win)
                    vim.g._claude_maximized = true
                    vim.api.nvim_win_set_width(win, vim.o.columns)
                end
            end,
            mode = "t",
            desc = "Toggle Full Screen",
        },
        { "<C-c>", "<cmd>ClaudeCode<cr>", mode = "t", desc = "Toggle" },
    },
}
