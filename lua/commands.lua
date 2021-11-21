local u = require("utils")

local api = vim.api

local commands = {}

-- make global to make ex commands easier
_G.inspect = function(...)
    print(vim.inspect(...))
end

commands.vsplit = function(args)
    if not args then
        vim.cmd("vsplit")
        return
    end

    local edit_in_win = function(winnr)
        vim.cmd(winnr .. "windo edit " .. args)
    end

    local current = vim.fn.winnr()
    local right_split = vim.fn.winnr("l")
    local left_split = vim.fn.winnr("h")
    if left_split < current then
        edit_in_win(left_split)
        return
    end
    if right_split > current then
        edit_in_win(right_split)
        return
    end

    vim.cmd("vsplit " .. args)
end

vim.cmd("command! -complete=file -nargs=* Vsplit lua global.commands.vsplit(<f-args>)")
u.command("VsplitLast", "Vsplit #")
u.nmap("<Leader>vv", ":VsplitLast<CR>")

commands.wwipeall = function()
    local win = api.nvim_get_current_win()
    u.for_each(vim.fn.getwininfo(), function(w)
        if w.winid ~= win then
            if w.loclist == 1 then
                vim.cmd("lclose")
            elseif w.quickfix == 1 then
                vim.cmd("cclose")
            else
                vim.cmd(w.winnr .. " close")
            end
        end
    end)
end

u.lua_command("Wwipeall", "global.commands.wwipeall()")

commands.save_on_cr = function()
    return vim.bo.buftype ~= "" and u.t("<CR>") or u.t(":w<CR>")
end

u.nmap("<CR>", "v:lua.global.commands.save_on_cr()", { expr = true })

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.nmap("q", "v:lua.global.commands.stop_recording()", { expr = true })

commands.yank_highlight = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
end

u.augroup("YankHighlight", "TextYankPost", "lua global.commands.yank_highlight()")

-- cmd should be in the form of "edit $FILE",
-- where $FILE is replaced with the found file's name
commands.edit_test_file = function(cmd)
    cmd = cmd or "edit"
    if not cmd:find("$FILE") then
        cmd = cmd .. " $FILE"
    end

    local done = function(file)
        vim.cmd(cmd:gsub("$FILE", file))
    end

    local root, ft = vim.pesc(vim.fn.expand("%:t:r")), vim.bo.filetype

    local patterns = {}
    if ft == "lua" then
        table.insert(patterns, "_spec")
    elseif ft == "typescript" or ft == "typescriptreact" then
        table.insert(patterns, "%.test")
        table.insert(patterns, "%.spec")
    end

    local final_patterns = {}
    for _, pattern in ipairs(patterns) do
        -- go from test file to non-test file
        if root:match(pattern) then
            pattern = root:gsub(vim.pesc(pattern), "")
        else
            pattern = root .. pattern
        end
        -- make sure extension matches
        pattern = pattern .. "%." .. vim.fn.expand("%:e") .. "$"
        table.insert(final_patterns, pattern)
    end

    -- check buffers first
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        for _, pattern in ipairs(final_patterns) do
            if b.name:match(pattern) then
                done(b.name)
                return
            end
        end
    end

    local scandir = function(path, depth, next)
        require("plenary.scandir").scan_dir_async(path, {
            depth = depth,
            search_pattern = final_patterns,
            on_exit = vim.schedule_wrap(function(found)
                if found[1] then
                    done(found[1])
                    return
                end

                if not next then
                    u.warn("test_file: corresponding file not found for file " .. vim.fn.expand("%:t"))
                    return
                end

                next()
            end),
        })
    end

    -- check same dir files first, then cwd
    scandir(vim.fn.expand("%:p:h"), 1, function()
        scandir(vim.fn.getcwd(), 5)
    end)
end

vim.cmd("command! -complete=command -nargs=* TestFile lua global.commands.edit_test_file(<f-args>)")
u.nmap("<Leader>tv", ":TestFile Vsplit<CR>")

-- gitsigns
commands.next_hunk = function()
    return require('gitsigns').next_hunk()
end

u.lua_command("NextHunk", "global.commands.next_hunk()")

commands.prev_hunk = function()
    return require('gitsigns').prev_hunk()
end

u.lua_command("PrevHunk", "global.commands.prev_hunk()")

commands.stage_hunk = function()
    return require('gitsigns').stage_hunk()
end

u.lua_command("StageHunk", "global.commands.stage_hunk()")

commands.undo_stage_hunk = function()
    return require('gitsigns').undo_stage_hunk()
end

u.lua_command("UndoStageHunk", "global.commands.undo_stage_hunk()")

commands.reset_hunk = function()
    return require('gitsigns').reset_hunk()
end

u.lua_command("ResetHunk", "global.commands.reset_hunk()")

commands.reset_buffer = function()
    return require('gitsigns').reset_buffer()
end

u.lua_command("ResetBuffer", "global.commands.reset_buffer()")

commands.preview_hunk = function()
    return require('gitsigns').preview_hunk()
end

u.lua_command("PreviewHunk", "global.commands.preview_hunk()")

commands.blame_line = function()
    return require('gitsigns').blame_line()
end

u.lua_command("BlameLine", "global.commands.blame_line()")

-- lsp
commands.add_to_workspace_folder = function()
    vim.lsp.buf.add_workspace_folder()
end

u.lua_command("LspAddToWorkspaceFolder", "global.commands.add_to_workspace_folder()")

commands.clear_references = function()
    vim.lsp.buf.clear_references()
end

u.lua_command("LspClearReferences", "global.commands.clear_references()")

commands.code_action = function()
    vim.lsp.buf.code_action()
end

u.lua_command("LspCodeAction", "global.commands.code_action()")

commands.declaration = function()
    vim.lsp.buf.declaration()
end

u.lua_command("LspDeclaration", "global.commands.declaration()")

commands.definition = function()
    vim.lsp.buf.definition()
end

u.lua_command("LspDefintion", "global.commands.definition()")

commands.document_symbol = function()
    vim.lsp.buf.document_symbol()
end

u.lua_command("LspDocumentSymbol", "global.commands.document_symbol()")

commands.formatting = function()
    vim.lsp.buf.formatting()
end

u.lua_command("LspFormatting", "global.commands.formatting()")

commands.formatting_sync = function()
    vim.lsp.buf.formattin_sync()
end

u.lua_command("LspFormattingSync", "global.commands.formatting_async()")

commands.hover = function()
    vim.lsp.buf.hover()
end

u.lua_command("LspHover", "global.commands.hover()")

commands.implementation = function()
    vim.lsp.buf.implementation()
end

u.lua_command("LspImplementation", "global.commands.implementation()")

commands.range_code_action = function()
    vim.lsp.buf.range_code_action()
end

u.lua_command("LspRangeCodeAction", "global.commands.range_code_action()")

commands.range_formatting = function()
    vim.lsp.buf.range_formatting()
end

u.lua_command("LspRangeFormatting", "global.commands.range_code_formatting()")

commands.references = function()
    vim.lsp.buf.range_formatting()
end

u.lua_command("LspReferences", "global.commands.references()")

commands.rename = function()
    vim.lsp.buf.rename()
end

u.lua_command("LspRename", "global.commands.rename()")

commands.type_definition = function()
    vim.lsp.buf.type_definition()
end

u.lua_command("LspTypeDefintion", "global.commands.type_definition()")

commands.workspace_symbol = function()
    vim.lsp.buf.workspace_symbol()
end

u.lua_command("LspWorkspaceSymbol", "global.commands.workspace_symbol()")

commands.goto_next = function()
    vim.lsp.buf.goto_next()
end

u.lua_command("LspGotoNext", "global.commands.goto_next()")

commands.goto_prev = function()
    vim.lsp.buf.goto_prev()
end

u.lua_command("LspGotoPrev", "global.commands.goto_prev()")

commands.show_line_diagnostics = function()
    vim.lsp.buf.show_line_diagnostics()
end

u.lua_command("LspShowLineDiagnostics", "global.commands.show_line_diagnostics()")

-- misc
-- wipe all registers
u.command("WipeReg", "for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor")

-- start vim with clean registers
u.augroup("WipeRegisters", "VimEnter", "WipeReg")

-- delete current file and buffer
u.command("Remove", "call delete(expand('%')) | bdelete")

-- get help for word under cursor
u.command("Help", 'execute ":help" expand("<cword>")')

-- reset treesitter and lsp diagnostics
u.command("R", "w | :e")

_G.global.commands = commands

return commands
