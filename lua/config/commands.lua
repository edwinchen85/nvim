local u = require("config.utils")

local commands = {}

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.nmap("q", "v:lua.global.commands.stop_recording()", { expr = true })

-- loclist
commands.toggle_loclist = function()
    local win = vim.api.nvim_get_current_win()
    local qf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
    local action = qf_winid > 0 and "lclose" or "lopen"
    vim.cmd(action)
end

u.lua_command("ToggleLocList", "global.commands.toggle_loclist()")

-- quickfix
commands.toggle_quickfix = function()
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    local action = qf_winid > 0 and "cclose" or "copen"
    vim.cmd("botright " .. action)
end

u.lua_command("ToggleQuickFix", "global.commands.toggle_quickfix()")

-- inlay hint
commands.toggle_inlay_hint = function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

u.lua_command("ToggleInlayHint", "global.commands.toggle_inlay_hint()")

-- virtual text
local isLspDiagnosticsVisible = false
commands.toggle_virtual_text = function()
    isLspDiagnosticsVisible = not isLspDiagnosticsVisible
    vim.diagnostic.config({
        virtual_text = isLspDiagnosticsVisible,
        underline = isLspDiagnosticsVisible,
    })
end

u.lua_command("ToggleVirtualText", "global.commands.toggle_virtual_text()")

-- gitsigns
commands.next_hunk = function()
    return require("gitsigns").next_hunk()
end

u.lua_command("NextHunk", "global.commands.next_hunk()")

commands.prev_hunk = function()
    return require("gitsigns").prev_hunk()
end

u.lua_command("PrevHunk", "global.commands.prev_hunk()")

commands.stage_hunk = function()
    return require("gitsigns").stage_hunk()
end

u.lua_command("StageHunk", "global.commands.stage_hunk()")

commands.undo_stage_hunk = function()
    return require("gitsigns").undo_stage_hunk()
end

u.lua_command("UndoStageHunk", "global.commands.undo_stage_hunk()")

commands.reset_hunk = function()
    return require("gitsigns").reset_hunk()
end

u.lua_command("ResetHunk", "global.commands.reset_hunk()")

commands.reset_buffer = function()
    return require("gitsigns").reset_buffer()
end

u.lua_command("ResetBuffer", "global.commands.reset_buffer()")

commands.preview_hunk = function()
    return require("gitsigns").preview_hunk()
end

u.lua_command("PreviewHunk", "global.commands.preview_hunk()")

commands.preview_hunk_inline = function()
    return require("gitsigns").preview_hunk_inline()
end

u.lua_command("PreviewHunkInline", "global.commands.preview_hunk_inline()")

commands.blame_line = function()
    return require("gitsigns").blame_line()
end
-- end of gitsigns

u.lua_command("BlameLine", "global.commands.blame_line()")

-- misc
-- wipe all registers
u.command("WipeReg", "for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor")

-- start vim with clean registers
u.augroup("WipeRegisters", "VimEnter", "WipeReg")

-- get help for word under cursor
u.command("Help", 'execute ":help" expand("<cword>")')

-- reset treesitter and lsp diagnostics
u.command("R", "w | :e")
-- end of misc

-- restore syntax highlighting
u.command("S", "syntax sync clear")

_G.global.commands = commands

return commands
