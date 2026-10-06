local M = {}

-- sidekick marks its CLI windows with vim.w[win].sidekick_cli (cli/terminal.lua `Terminal:open_win`).
function M.is_cli_win(win)
    return vim.api.nvim_win_is_valid(win) and vim.w[win].sidekick_cli ~= nil
end

-- First sidekick CLI window in the current tabpage.
-- SIMPLIFIED: first match wins, track the last-focused session if running several at once
function M.find_cli_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if M.is_cli_win(win) then
            return win
        end
    end
end

-- True when the CLI float spans every column of `win` (floats here are full height), so
-- the window is out of sight. nvim_win_get_position gives the float's outer (border) corner.
function M.hidden_by_cli_win(win)
    local cli = M.find_cli_win()
    if not cli or cli == win then
        return false
    end
    local config = vim.api.nvim_win_get_config(cli)
    local left = vim.api.nvim_win_get_position(cli)[2]
    local right = left + config.width + (config.border and 2 or 0)
    local col = vim.api.nvim_win_get_position(win)[2]
    return col >= left and col + vim.api.nvim_win_get_width(win) <= right
end

-- Jump into the CLI float (it sits outside the split layout, so `wincmd l` never reaches it).
-- Returns false when there is no CLI window or it already has focus.
function M.focus_cli_win()
    local win = M.find_cli_win()
    if not win or win == vim.api.nvim_get_current_win() then
        return false
    end
    vim.api.nvim_set_current_win(win)
    vim.cmd.startinsert()
    return true
end

-- Leave the CLI float for the previous window, like sidekick's `blur` (`wincmd p`), but fall
-- back to the first non-float window when there is no previous one to go to.
function M.leave_cli_win()
    local cur = vim.api.nvim_get_current_win()
    local prev = vim.fn.winnr("#") > 0 and vim.fn.win_getid(vim.fn.winnr("#")) or 0
    if prev == 0 or prev == cur then
        prev = 0
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(win).relative == "" then
                prev = win
                break
            end
        end
    end
    if prev ~= 0 then
        vim.api.nvim_set_current_win(prev)
        vim.cmd.stopinsert()
    end
end

-- workaround for upstream bug: cli.send hardcodes `msg .. "\n"`, and tmux's
-- paste-buffer -r passes the LF raw to claude which renders it as a stray `j`.
-- send the message without trailing newline; rely on submit=true for actual Enter.
function M.send_no_newline(opts)
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
            if not opts.submit then
                msg = msg .. " " -- keep the cursor off the mention when typing continues on the same line
            end
            state.session:send(msg) -- no trailing \n
            if opts.submit then
                state.session:submit()
            end
        end)
    end, { attach = true, filter = opts.filter, show = true })
end

return M
