local M = {}

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
            state.session:send(msg) -- no trailing \n
            if opts.submit then
                state.session:submit()
            end
        end)
    end, { attach = true, filter = opts.filter, show = true })
end

return M
