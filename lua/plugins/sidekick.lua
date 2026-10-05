local send_no_newline = require("util.sidekick").send_no_newline

-- Find the sidekick CLI window in current tabpage (marked via vim.w[win].sidekick_cli).
local function find_sidekick_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and vim.w[win].sidekick_cli ~= nil then
            return win
        end
    end
    return nil
end

-- Full-screen float config, leaving the cmdline and global statusline visible.
local function zoom_config()
    return {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines - vim.o.cmdheight - 1,
    }
end

-- Floats don't reflow like splits, so refit a zoomed sidekick when the terminal resizes.
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("sidekick_zoom_refit", { clear = true }),
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.w[win]._sk_zoomed then
                pcall(vim.api.nvim_win_set_config, win, zoom_config())
            end
        end
    end,
})

-- Toggle sidekick window between zoomed and its original right split.
-- Zoom turns the split into a full-screen float, so it is the only window on screen
-- (no 1-column slivers of the others). Same window id both ways, so sidekick keeps
-- tracking it, and the other windows' layout stays intact underneath.
-- Works regardless of which window currently holds focus.
local function toggle_sidekick_width()
    local win = find_sidekick_win()
    if not win then
        return false
    end
    if vim.w[win]._sk_zoomed then
        local orig = vim.w[win]._sk_orig_w or math.floor(vim.o.columns / 2)
        pcall(vim.api.nvim_win_set_config, win, { split = "right", win = -1, width = orig })
        vim.w[win]._sk_zoomed = false
        vim.w[win]._sk_orig_w = nil
    else
        vim.w[win]._sk_orig_w = vim.api.nvim_win_get_width(win)
        pcall(vim.api.nvim_win_set_config, win, zoom_config())
        vim.w[win]._sk_zoomed = true
    end
    vim.cmd("redraw")
    return true
end

vim.keymap.set({ "n", "t", "i" }, "<C-z>", function()
    if not toggle_sidekick_width() then
        -- No sidekick window: fall back to vim default (suspend).
        vim.cmd("stopinsert")
        vim.cmd("suspend")
    end
end, { desc = "Toggle sidekick full width (fallback: suspend)" })

-- `nes` is disabled below, so the Copilot LSP is unused -- but sidekick's health check
-- reports its absence as an ERROR unconditionally, with no config gate. health.lua binds
-- `local error = vim.health.error` at module load, so the filter has to be installed
-- before the module is first required (i.e. before :checkhealth pulls it in).
local function silence_copilot_health()
    local real_error = vim.health.error
    vim.health.error = function(msg, ...)
        if type(msg) == "string" and msg:find("No Copilot LSP server", 1, true) then
            return vim.health.ok("Copilot LSP not enabled (`nes` is disabled)")
        end
        return real_error(msg, ...)
    end
    require("sidekick.health") -- captures the wrapper as its module-local `error`
    vim.health.error = real_error -- every other healthcheck keeps the real one
end

return {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    config = function(_, opts)
        require("sidekick").setup(opts)
        silence_copilot_health()
    end,
    opts = {
        nes = { enabled = false },
        cli = {
            win = {
                layout = "right",
                keys = {
                    -- disable sidekick default: <C-z> -> blur (jumps to previous window),
                    -- which shadows our global <C-z> zoom toggle in the terminal buffer.
                    hide_ctrl_z = false,
                    -- disable sidekick default <C-b> -> buffer picker; conflicts with
                    -- claude-code's <C-b> shortcut inside the CLI session.
                    buffers = false,
                },
            },
            tools = {
                -- Claude sees $TMUX and wraps OSC 52 copies in a tmux passthrough
                -- code that nvim's terminal prints as base64 junk. Hide $TMUX;
                -- pbcopy still copies, and workmux is told the backend directly.
                claude = {
                    env = { TMUX = false, WORKMUX_BACKEND = "tmux" },
                    cmd = { "claude" },
                    is_proc = "\\<claude\\>",
                },
                claude_continue = {
                    env = { TMUX = false, WORKMUX_BACKEND = "tmux" },
                    cmd = { "claude", "--continue" },
                    is_proc = "\\<claude\\>",
                },
                claude_resume = {
                    env = { TMUX = false, WORKMUX_BACKEND = "tmux" },
                    cmd = { "claude", "--resume" },
                    is_proc = "\\<claude\\>",
                },
            },
        },
    },
    keys = {
        {
            "<leader>aa",
            function()
                require("sidekick.cli").toggle()
            end,
            desc = "Sidekick Toggle CLI",
        },
        {
            "<leader>as",
            function()
                require("sidekick.cli").select()
            end,
            -- Or to select only installed tools:
            -- require("sidekick.cli").select({ filter = { installed = true } })
            desc = "Select CLI",
        },
        {
            "<leader>ad",
            function()
                require("sidekick.cli").close()
            end,
            desc = "Detach a CLI Session",
        },
        {
            "<leader>at",
            function()
                -- submit=false: leave cursor right after the mention so the
                -- prompt can be typed on the same line instead of a new one.
                send_no_newline({ msg = "{this}", submit = false })
            end,
            mode = { "x", "n" },
            desc = "Send This",
        },
        {
            "<leader>af",
            function()
                send_no_newline({ msg = "{file}", submit = false })
            end,
            desc = "Send File",
        },
        {
            "<leader>av",
            function()
                send_no_newline({ msg = "{selection}" })
            end,
            mode = { "x" },
            desc = "Send Visual Selection",
        },
        {
            "<leader>ap",
            function()
                require("sidekick.cli").prompt()
            end,
            mode = { "n", "x" },
            desc = "Sidekick Select Prompt",
        },
        {
            "<leader>ac",
            function()
                require("sidekick.cli").toggle({ name = "claude_continue", focus = true })
            end,
            desc = "Claude --continue",
        },
        {
            "<leader>ar",
            function()
                require("sidekick.cli").toggle({ name = "claude_resume", focus = true })
            end,
            desc = "Claude --resume",
        },
        {
            "<C-t>",
            function()
                require("sidekick.cli").toggle()
            end,
            desc = "Toggle Sidekick CLI",
            mode = { "n", "t", "i", "x" },
        },
    },
}
