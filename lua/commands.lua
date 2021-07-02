local u = require("utils")

local api = vim.api

local for_each_buffer = function(cb, force)
    u.for_each(vim.fn.getbufinfo({ buflisted = true }), function(b)
        if b.changed == 0 and not force then
            cb(b)
        end
    end)
end

local commands = {}

commands.bonly = function(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    for_each_buffer(function(b)
        if b.bufnr ~= bufnr then
            vim.cmd("bdelete " .. b.bufnr)
        end
    end)
end

u.lua_command("Bonly", "global.commands.bonly()")

commands.bwipeall = function()
    for_each_buffer(function(b)
        vim.cmd("bdelete " .. b.bufnr)
    end)
end

u.lua_command("Bwipeall", "global.commands.bwipeall()")

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

commands.bdelete = function(bufnr)
    local win = api.nvim_get_current_win()
    bufnr = bufnr or api.nvim_win_get_buf(win)

    local target
    local previous = vim.fn.bufnr("#")
    if previous ~= -1 and previous ~= bufnr and vim.fn.buflisted(previous) == 1 then
        target = previous
    end

    if not target then
        for_each_buffer(function(b)
            if not target and b.bufnr ~= bufnr then
                target = b.bufnr
            end
        end)
    end

    if not target then
        target = api.nvim_create_buf(false, false)
    end

    local windows = vim.fn.getbufinfo(bufnr)[1].windows
    u.for_each(windows, function(w)
        api.nvim_win_set_buf(w, target)
    end)

    vim.cmd("bdelete " .. bufnr)
end

u.lua_command("Bdelete", "global.commands.bdelete()")

commands.save_on_cr = function()
    return vim.bo.buftype == "quickfix" and u.t("<CR>") or u.t(":w<CR>")
end

u.map("n", "<CR>", "v:lua.global.commands.save_on_cr()", { expr = true })

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.map("n", "q", "v:lua.global.commands.stop_recording()", { expr = true })

commands.yank_highlight = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
end

u.augroup("YankHighlight", "TextYankPost", "lua global.commands.yank_highlight()")

commands.edit_test_file = function(cmd, post)
    cmd = cmd or "e"
    local scandir = require("plenary.scandir")

    local root, ft = vim.fn.expand("%:t:r"), vim.bo.filetype
    local patterns = {}
    if ft == "lua" then
        table.insert(patterns, "_spec")
    elseif ft == "typescript" or ft == "typescriptreact" then
        table.insert(patterns, ".test")
        table.insert(patterns, ".spec")
    end

    local final_patterns = {}
    for _, pattern in ipairs(patterns) do
        -- go from test file to non-test file
        if root:match(pattern) then
            pattern = u.replace(root, pattern, "")
        else
            pattern = root .. pattern
        end
        -- make sure extension matches
        pattern = pattern .. "." .. vim.fn.expand("%:e") .. "$"
        table.insert(final_patterns, pattern)
    end

    scandir.scan_dir_async(vim.fn.getcwd(), {
        depth = 5,
        search_pattern = final_patterns,
        on_exit = vim.schedule_wrap(function(files)
            assert(files[1], "test file not found")
            vim.cmd(cmd .. " " .. files[1])
            if post then
                post()
            end
        end),
    })
end

u.lua_command("TestFile", "global.commands.edit_test_file()")

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

u.command("Remove", "call delete(expand('%')) | lua global.commands.bdelete()")
u.command("VsplitLast", "vsplit #")
u.command("R", "w | :e")

_G.global.commands = commands

return commands
