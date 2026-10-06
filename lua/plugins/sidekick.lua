local sidekick_util = require("util.sidekick")
local send_no_newline = sidekick_util.send_no_newline

-- Float height: everything above the cmdline and the global statusline's row. Constant
-- across focus changes even though the statusline hides while the float has focus:
-- growing into that row resized the pty on every enter/leave, and Claude's diffing
-- renderer, caught mid-output, left rows duplicated one line apart.
local function float_height()
    return vim.o.lines - vim.o.cmdheight - 1
end

-- Full-screen float config, leaving the cmdline visible.
local function zoom_config()
    return {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = float_height(),
    }
end

-- Side/center float, same look as the zoomed one: full height, flush with the right edge,
-- or horizontally centered when `centered`.
-- Width is `cli.win.float.width` as a fraction of the screen (re-read on every refit).
-- `width` excludes the 2 border columns. `title = ""` drops sidekick's " Sidekick " title.
local function side_config(centered)
    local width = math.floor(vim.o.columns * require("sidekick.config").cli.win.float.width)
    return {
        relative = "editor",
        row = 0,
        col = centered and math.floor((vim.o.columns - width) / 2) or vim.o.columns - width,
        width = width - 2,
        height = float_height(),
        title = "",
    }
end

-- Claude's renderer only repaints the cells it thinks changed, so after the pty is resized
-- it leaves stale rows behind (a duplicate prompt line, footer text drawn over the
-- statusline). Send it <C-l> (full redraw) once the resizes settle. Debounced because
-- one refit can fire several times in a row (open_win, then WinEnter hiding the statusline).
local redraw_timer = assert(vim.uv.new_timer())
local function redraw_cli(win)
    local buf = vim.api.nvim_win_get_buf(win)
    redraw_timer:stop()
    redraw_timer:start(
        100,
        0,
        vim.schedule_wrap(function()
            local chan = vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].channel or 0
            if chan > 0 then
                pcall(vim.api.nvim_chan_send, chan, "\12")
            end
        end)
    )
end

-- Apply a float config; force a CLI redraw if the size actually changed.
local function set_config(win, config)
    local w, h = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
    pcall(vim.api.nvim_win_set_config, win, config)
    if vim.api.nvim_win_get_width(win) ~= w or vim.api.nvim_win_get_height(win) ~= h then
        redraw_cli(win)
    end
end

local function refit(win)
    set_config(win, vim.w[win]._sk_zoomed and zoom_config() or side_config(vim.w[win]._sk_centered))
end

-- Backdrop behind a focused, centered float: an empty full-screen float one zindex below
-- sidekick's (default 50), drawn with Normal so it hides the editor. Raise the blend
-- (e.g. 60) to dim the editor instead of hiding it.
local BACKDROP_BLEND = 0
local backdrop_win

local function hide_backdrop()
    if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
        pcall(vim.api.nvim_win_close, backdrop_win, true)
    end
    backdrop_win = nil
end

local function sync_backdrop()
    local win = vim.api.nvim_get_current_win()
    if not (sidekick_util.is_cli_win(win) and vim.w[win]._sk_centered and not vim.w[win]._sk_zoomed) then
        return hide_backdrop()
    end
    local config = {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines - vim.o.cmdheight,
        zindex = vim.api.nvim_win_get_config(win).zindex - 1,
        focusable = false,
        style = "minimal",
        border = "none",
    }
    if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
        pcall(vim.api.nvim_win_set_config, backdrop_win, config)
        return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    config.noautocmd = true
    backdrop_win = vim.api.nvim_open_win(buf, false, config)
    vim.wo[backdrop_win].winhighlight = "Normal:Normal"
    vim.wo[backdrop_win].winblend = BACKDROP_BLEND
end

-- Set the float's width to `width` (a fraction of the screen), kept in 0.1..1 on a 5% grid.
-- Writes `cli.win.float.width` itself, so the new width sticks for re-shows and resizes.
-- A zoomed window keeps its zoom and picks the new width up when it unzooms.
local function set_float_width(terminal, width)
    require("sidekick.config").cli.win.float.width = math.min(1, math.max(0.1, math.floor(width * 20 + 0.5) / 20))
    if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
        refit(terminal.win)
    end
end

-- Step the float's width by `delta`.
local function resize_side_float(terminal, delta)
    set_float_width(terminal, require("sidekick.config").cli.win.float.width + delta)
end

-- Toggle the float between the right side and the screen center (with a backdrop).
-- Unzooms first, so the move is visible. Window-local: a re-shown float opens on the side.
local function toggle_center(terminal)
    local win = terminal.win
    if not (win and vim.api.nvim_win_is_valid(win)) then
        return
    end
    vim.w[win]._sk_centered = not vim.w[win]._sk_centered
    vim.w[win]._sk_zoomed = false
    refit(win)
    sync_backdrop()
end

-- Sidekick sizes its float once, from static opts: sidekick/cli/terminal.lua `Terminal:open_win`
-- reads `cli.win.float` and opens the window into `self.win`, returning early (nothing
-- returned) when `self:is_open()`. Refit it to the right side every time it opens, so a
-- re-shown window follows the current terminal size.
local function patch_open_win()
    local Terminal = require("sidekick.cli.terminal")
    local open_win = Terminal.open_win
    Terminal.open_win = function(self)
        local was_open = self:is_open()
        open_win(self)
        if not was_open and self.win and vim.api.nvim_win_is_valid(self.win) then
            set_config(self.win, side_config())
        end
    end
end

local refit_group = vim.api.nvim_create_augroup("sidekick_float_refit", { clear = true })

-- Floats don't reflow like splits, so refit sidekick floats when the terminal resizes.
vim.api.nvim_create_autocmd("VimResized", {
    group = refit_group,
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if sidekick_util.is_cli_win(win) then
                refit(win)
            end
        end
        sync_backdrop()
    end,
})

-- Hide the global statusline while a sidekick float has focus (its row stays empty, see
-- float_height). 'ruler' goes too: without a statusline Neovim draws it in the cmdline.
-- The center backdrop only shows while the float has focus, so it never covers the
-- window you jump to. WinLeave also fires when the focused float is hidden/closed.
local saved_laststatus, saved_ruler
vim.api.nvim_create_autocmd("WinEnter", {
    group = refit_group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        if not sidekick_util.is_cli_win(win) then
            return
        end
        if vim.o.laststatus ~= 0 then
            saved_laststatus, saved_ruler = vim.o.laststatus, vim.o.ruler
            vim.o.laststatus, vim.o.ruler = 0, false
        end
        sync_backdrop()
    end,
})
vim.api.nvim_create_autocmd("WinLeave", {
    group = refit_group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        if not sidekick_util.is_cli_win(win) then
            return
        end
        if saved_laststatus then
            vim.o.laststatus, vim.o.ruler = saved_laststatus, saved_ruler
            saved_laststatus, saved_ruler = nil, nil
        end
        hide_backdrop()
    end,
})

-- Toggle sidekick window between full-screen and its side/center float.
-- Same window id both ways, so sidekick keeps tracking it.
-- Works regardless of which window currently holds focus.
local function toggle_sidekick_zoom()
    local win = sidekick_util.find_cli_win()
    if not win then
        return false
    end
    vim.w[win]._sk_zoomed = not vim.w[win]._sk_zoomed
    refit(win)
    sync_backdrop()
    vim.cmd("redraw")
    return true
end

vim.keymap.set({ "n", "t", "i" }, "<C-z>", function()
    if not toggle_sidekick_zoom() then
        -- No sidekick window: fall back to vim default (suspend).
        vim.cmd("stopinsert")
        vim.cmd("suspend")
    end
end, { desc = "Toggle sidekick full-screen zoom (fallback: suspend)" })

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
        patch_open_win()
        silence_copilot_health()
    end,
    opts = {
        nes = { enabled = false },
        cli = {
            win = {
                -- Right-side float (see side_config) instead of a split.
                layout = "float",
                float = { width = 0.5 }, -- fraction of the screen width
                keys = {
                    -- disable sidekick default: <C-z> -> blur (jumps to previous window),
                    -- which shadows our global <C-z> zoom toggle in the terminal buffer.
                    hide_ctrl_z = false,
                    -- disable sidekick default <C-b> -> buffer picker; conflicts with
                    -- claude-code's <C-b> shortcut inside the CLI session.
                    buffers = false,
                    -- sidekick passes <c-h> through to the CLI in a float; jump back to
                    -- the previous window instead, like <c-h> did out of the split.
                    -- `expr = false` overrides the default's deep-merged `expr = true`:
                    -- expr maps run under textlock, where switching windows is E565.
                    -- The float hangs off the right edge: <M-,> ("<") pushes its left edge left
                    -- (wider), <M-.> (">") pulls it right (narrower), by 5% of the screen.
                    float_narrower = {
                        "<M-.>",
                        function(t)
                            resize_side_float(t, -0.05)
                        end,
                        mode = "nt",
                        desc = "narrow the CLI float by 5%",
                    },
                    float_wider = {
                        "<M-,>",
                        function(t)
                            resize_side_float(t, 0.05)
                        end,
                        mode = "nt",
                        desc = "widen the CLI float by 5%",
                    },
                    float_half = {
                        "<M-=>",
                        function(t)
                            set_float_width(t, 0.5)
                        end,
                        mode = "nt",
                        desc = "reset the CLI float to 50% of the screen",
                    },
                    float_center = {
                        "<M-m>",
                        toggle_center,
                        mode = "nt",
                        desc = "toggle the CLI float between the right side and the center",
                    },
                    nav_left = {
                        "<c-h>",
                        sidekick_util.leave_cli_win,
                        expr = false,
                        desc = "go back to the previous window",
                    },
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
