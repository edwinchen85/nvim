local sidekick_util = require("util.sidekick")
local send_no_newline = sidekick_util.send_no_newline

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

-- Right-half float, same look as the zoomed one: full height, flush with the right edge.
-- `width` excludes the 2 border columns. `title = ""` drops sidekick's " Sidekick " title.
local function half_config()
    local width = math.floor(vim.o.columns / 2)
    return {
        relative = "editor",
        row = 0,
        col = vim.o.columns - width,
        width = width - 2,
        height = vim.o.lines - vim.o.cmdheight - 1,
        title = "",
    }
end

-- Sidekick sizes its float once, from static opts: sidekick/cli/terminal.lua `Terminal:open_win`
-- reads `cli.win.float` and opens the window into `self.win`, returning early (nothing
-- returned) when `self:is_open()`. Refit it to the right half every time it opens, so a
-- re-shown window follows the current terminal size.
local function patch_open_win()
    local Terminal = require("sidekick.cli.terminal")
    local open_win = Terminal.open_win
    Terminal.open_win = function(self)
        local was_open = self:is_open()
        open_win(self)
        if not was_open and self.win and vim.api.nvim_win_is_valid(self.win) then
            pcall(vim.api.nvim_win_set_config, self.win, half_config())
        end
    end
end

-- Floats don't reflow like splits, so refit sidekick floats when the terminal resizes.
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("sidekick_float_refit", { clear = true }),
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if sidekick_util.is_cli_win(win) then
                local config = vim.w[win]._sk_zoomed and zoom_config() or half_config()
                pcall(vim.api.nvim_win_set_config, win, config)
            end
        end
    end,
})

-- Toggle sidekick window between full-screen and right-half float.
-- Same window id both ways, so sidekick keeps tracking it.
-- Works regardless of which window currently holds focus.
local function toggle_sidekick_zoom()
    local win = sidekick_util.find_cli_win()
    if not win then
        return false
    end
    local zoomed = not vim.w[win]._sk_zoomed
    pcall(vim.api.nvim_win_set_config, win, zoomed and zoom_config() or half_config())
    vim.w[win]._sk_zoomed = zoomed
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
                -- Right-half float (see half_config) instead of a split.
                layout = "float",
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
