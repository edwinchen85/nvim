-- workaround for upstream bug: cli.send hardcodes `msg .. "\n"`, and tmux's
-- paste-buffer -r passes the LF raw to claude which renders it as a stray `j`.
-- send the message without trailing newline; rely on submit=true for actual Enter.
-- Find the sidekick CLI window in current tabpage (marked via vim.w[win].sidekick_cli).
local function find_sidekick_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and vim.w[win].sidekick_cli ~= nil then
            return win
        end
    end
    return nil
end

-- Toggle sidekick window between zoomed (full width) and original width.
-- Works regardless of which window currently holds focus.
local function toggle_sidekick_width()
    local win = find_sidekick_win()
    if not win then
        return false
    end
    if vim.w[win]._sk_zoomed then
        local orig = vim.w[win]._sk_orig_w or math.floor(vim.o.columns / 2)
        pcall(vim.api.nvim_win_set_width, win, orig)
        vim.w[win]._sk_zoomed = false
        vim.w[win]._sk_orig_w = nil
    else
        vim.w[win]._sk_orig_w = vim.api.nvim_win_get_width(win)
        pcall(vim.api.nvim_win_set_width, win, vim.o.columns)
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

local function send_no_newline(opts)
    opts = type(opts) == "string" and { msg = opts } or opts
    opts.submit = opts.submit ~= false
    local Cli = require("sidekick.cli")
    local State = require("sidekick.cli.state")
    local Util = require("sidekick.util")

    if not opts.msg and not opts.prompt and Util.visual_mode() then
        opts.msg = "{selection}"
    end

    local msg, text = "", opts.text
    if not text then
        msg, text = Cli.render(opts)
        if msg == "" or not text then
            Util.warn("Nothing to send.")
            return
        elseif msg == "\n" then
            msg = ""
            text = {}
        end
    end

    opts.filter = opts.filter or {}
    opts.filter.name = opts.name or opts.filter.name or nil

    State.with(function(state)
        Util.exit_visual_mode()
        vim.schedule(function()
            msg = state.tool:format(text)
            state.session:send(msg) -- no trailing \n
            if opts.submit then
                state.session:submit()
            end
        end)
    end, { attach = true, filter = opts.filter, show = true })
end

return {
    "folke/sidekick.nvim",
    event = "VeryLazy",
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
                claude = {
                    cmd = { "headroom", "wrap", "claude" },
                    is_proc = "\\<claude\\>",
                },
                claude_continue = {
                    cmd = { "headroom", "wrap", "claude", "--continue" },
                    is_proc = "\\<claude\\>",
                },
                claude_resume = {
                    cmd = { "headroom", "wrap", "claude", "--resume" },
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
                send_no_newline({ msg = "{this}" })
            end,
            mode = { "x", "n" },
            desc = "Send This",
        },
        {
            "<leader>af",
            function()
                send_no_newline({ msg = "{file}" })
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
