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
commands.toggle_inlay_hint = function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
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
