local u = require("config.utils")

local command = vim.api.nvim_create_user_command

-- `q` stops a recording; otherwise a no-op so it does not start one.
u.nmap("q", function()
    return vim.fn.reg_recording() ~= "" and "q" or ""
end, { expr = true })

-- loclist / quickfix
local function toggle_list(get_winid_fn, open_cmd, close_cmd)
    vim.cmd(get_winid_fn() > 0 and close_cmd or open_cmd)
end

local function toggle_loclist()
    local win = vim.api.nvim_get_current_win()
    toggle_list(function()
        return vim.fn.getloclist(win, { winid = 0 }).winid
    end, "lopen", "lclose")
end

local function toggle_quickfix()
    toggle_list(function()
        return vim.fn.getqflist({ winid = 0 }).winid
    end, "botright copen", "cclose")
end

command("ToggleLocList", toggle_loclist, {})
command("ToggleQuickFix", toggle_quickfix, {})

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

local function toggle_inlay_hint()
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

command("ToggleInlayHint", toggle_inlay_hint, {})

-- virtual text — read live state instead of tracking external variable
local function toggle_virtual_text()
    local enabled = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({
        virtual_text = not enabled,
        underline = not enabled,
    })
end

command("ToggleVirtualText", toggle_virtual_text, {})

-- tailwind fold
local function toggle_tailwind_fold()
    vim.cmd("TailwindFoldToggle")
end

command("ToggleTailwindFold", toggle_tailwind_fold, {})

-- misc
-- wipe all registers
local function wipe_registers()
    for i = 34, 122 do
        pcall(vim.fn.setreg, string.char(i), {})
    end
end

command("WipeReg", wipe_registers, {})

-- start vim with clean registers
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("WipeRegisters", { clear = true }),
    callback = wipe_registers,
})

-- spell check
local function toggle_spell()
    vim.wo.spell = not vim.wo.spell
end

command("ToggleSpell", toggle_spell, {})

-- get help for word under cursor
command("Help", 'execute ":help" expand("<cword>")', {})

-- reset treesitter and lsp diagnostics
command("R", "w | :e", {})

-- restore syntax highlighting
command("S", "syntax sync clear", {})

-- LspRestart removed in nvim-lspconfig v1.x — reimplement via vim.lsp API
command("LspRestart", function()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client:stop()
    end
    vim.cmd("edit")
end, { desc = "Restart LSP for current buffer" })
