local u = require("config.utils")

local commands = {}

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.nmap("q", "v:lua.global.commands.stop_recording()", { expr = true })

-- loclist / quickfix
local function toggle_list(get_winid_fn, open_cmd, close_cmd)
    vim.cmd(get_winid_fn() > 0 and close_cmd or open_cmd)
end

commands.toggle_loclist = function()
    local win = vim.api.nvim_get_current_win()
    toggle_list(function()
        return vim.fn.getloclist(win, { winid = 0 }).winid
    end, "lopen", "lclose")
end

commands.toggle_quickfix = function()
    toggle_list(function()
        return vim.fn.getqflist({ winid = 0 }).winid
    end, "botright copen", "cclose")
end

u.lua_command("ToggleLocList", "global.commands.toggle_loclist()")
u.lua_command("ToggleQuickFix", "global.commands.toggle_quickfix()")

-- inlay hint
-- nvim 0.12.2 bug: with multiple LSP clients (vue: vtsls + vue_ls), the decoration
-- provider's per-line `applied` cache blocks the second client's response from rendering.
-- Workaround: reach into the inlay_hint module's local `bufstates` table via
-- debug.getupvalue and clear `applied[]` after each client responds.
local function get_bufstates()
    local fn = vim.lsp.inlay_hint.is_enabled
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, i)
        if not name then
            break
        end
        if name == "bufstates" then
            return value
        end
    end
    return nil
end

commands.toggle_inlay_hint = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local was_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    vim.lsp.inlay_hint.enable(not was_enabled, { bufnr = bufnr })
    if not was_enabled then
        local bufstates = get_bufstates()
        if not bufstates then
            return
        end
        -- After each response window, clear applied[] and force redraw so newly arrived
        -- hints from slower clients get rendered.
        for _, ms in ipairs({ 150, 400, 800 }) do
            vim.defer_fn(function()
                local state = rawget(bufstates, bufnr)
                if state then
                    state.applied = {}
                end
                vim.api.nvim__redraw({ buf = bufnr, valid = false, flush = true })
            end, ms)
        end
    end
end

u.lua_command("ToggleInlayHint", "global.commands.toggle_inlay_hint()")

-- virtual text — read live state instead of tracking external variable
commands.toggle_virtual_text = function()
    local enabled = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({
        virtual_text = not enabled,
        underline = not enabled,
    })
end

u.lua_command("ToggleVirtualText", "global.commands.toggle_virtual_text()")

-- tailwind fold
commands.toggle_tailwind_fold = function()
    vim.cmd("TailwindFoldToggle")
end

u.lua_command("ToggleTailwindFold", "global.commands.toggle_tailwind_fold()")

-- misc
-- wipe all registers
commands.wipe_registers = function()
    for i = 34, 122 do
        pcall(vim.fn.setreg, string.char(i), {})
    end
end

u.lua_command("WipeReg", "global.commands.wipe_registers()")

-- start vim with clean registers
u.augroup("WipeRegisters", "VimEnter", "WipeReg")

-- get help for word under cursor
u.command("Help", 'execute ":help" expand("<cword>")')

-- reset treesitter and lsp diagnostics
u.command("R", "w | :e")

-- restore syntax highlighting
u.command("S", "syntax sync clear")

-- LspRestart removed in nvim-lspconfig v1.x — reimplement via vim.lsp API
vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client:stop()
    end
    vim.cmd("edit")
end, { desc = "Restart LSP for current buffer" })

_G.global.commands = commands

return commands
