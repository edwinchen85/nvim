local u = require("config.utils")

local api = vim.api

local commands = {}

-- make global to make ex commands easier
_G.inspect = function(...)
    print(vim.inspect(...))
end

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.nmap("q", "v:lua.global.commands.stop_recording()", { expr = true })

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

u.lua_command("LiveGrepArgs", "require('telescope').extensions.live_grep_args.live_grep_args()")

u.lua_command(
    "GrepWordUnderCursor",
    "require('telescope-live-grep-args.shortcuts').grep_word_under_cursor({ postfix = ' -ig ' })"
)

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
