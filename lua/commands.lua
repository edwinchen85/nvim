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

commands.bwipeall = function()
    for_each_buffer(function(b)
        vim.cmd("bdelete " .. b.bufnr)
    end)
end

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

commands.complete = (function()
    local complete_timer
    local banned_filetypes = { "TelescopePrompt" }
    local trigger_chars = "[.]"

    return function()
        local filetype = vim.bo.filetype
        if not filetype or vim.tbl_contains(banned_filetypes, filetype) then
            return
        end

        if complete_timer then
            complete_timer.restart()
            return
        end

        complete_timer = u.timer(100, nil, true, function()
            complete_timer = nil

            if vim.fn.pumvisible() == 1 or vim.fn.mode() ~= "i" then
                return
            end

            local col = api.nvim_win_get_cursor(0)[2]
            local prev_char = string.sub(api.nvim_get_current_line(), col, col)
            if not (string.match(prev_char, "%w") or string.match(prev_char, trigger_chars)) then
                return
            end

            local seq = vim.bo.omnifunc ~= "" and "<C-x><C-o>" or "<C-n>"
            -- prefer nvim_input, since it's non-blocking
            api.nvim_input(seq)
        end)
    end
end)()

commands.save_on_cr = function()
    return vim.bo.buftype == "quickfix" and u.t("<CR>") or u.t(":w<CR>")
end

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

commands.yank_highlight = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
end

commands.edit_test_file = function(cmd)
    cmd = cmd or "e"
    local scandir = require("plenary.scandir")

    local root, ft = vim.fn.expand("%:t:r"), vim.bo.filetype
    local pattern
    if ft == "lua" then
        pattern = "_spec"
    elseif ft == "typescript" or ft == "typescriptreact" then
        pattern = ".test"
    end
    assert(pattern, "pattern not defined for " .. ft)

    -- go from test file to non-test file
    if root:match(pattern) then
        pattern = u.replace(root, pattern, "")
    else
        pattern = root .. pattern
    end
    -- make sure extension matches
    pattern = pattern .. "." .. vim.fn.expand("%:e") .. "$"

    scandir.scan_dir_async(vim.fn.getcwd(), {
        depth = 5,
        search_pattern = pattern,
        on_exit = vim.schedule_wrap(function(files)
            assert(files[1], "file not found for pattern " .. pattern)

            vim.cmd(cmd .. " " .. files[1])
        end),
    })
end

-- gitsigns
commands.next_hunk = function()
    return require('gitsigns').next_hunk()
end

commands.prev_hunk = function()
    return require('gitsigns').prev_hunk()
end

commands.stage_hunk = function()
    return require('gitsigns').stage_hunk()
end

commands.undo_stage_hunk = function()
    return require('gitsigns').undo_stage_hunk()
end

commands.reset_hunk = function()
    return require('gitsigns').reset_hunk()
end

commands.reset_buffer = function()
    return require('gitsigns').reset_buffer()
end

commands.preview_hunk = function()
    return require('gitsigns').preview_hunk()
end

commands.blame_line = function()
    return require('gitsigns').blame_line()
end

-- lsp
commands.add_to_workspace_folder = function()
    vim.lsp.buf.add_workspace_folder()
end

commands.clear_references = function()
    vim.lsp.buf.clear_references()
end

commands.code_action = function()
    vim.lsp.buf.code_action()
end

commands.declaration = function()
    vim.lsp.buf.declaration()
end

commands.definition = function()
    vim.lsp.buf.definition()
end

commands.document_symbol = function()
    vim.lsp.buf.document_symbol()
end

commands.formatting = function()
    vim.lsp.buf.formatting()
end

commands.formatting_sync = function()
    vim.lsp.buf.formattin_sync()
end

commands.hover = function()
    vim.lsp.buf.hover()
end

commands.implementation = function()
    vim.lsp.buf.implementation()
end

commands.range_code_action = function()
    vim.lsp.buf.range_code_action()
end

commands.range_formatting = function()
    vim.lsp.buf.range_formatting()
end

commands.references = function()
    vim.lsp.buf.range_formatting()
end

commands.rename = function()
    vim.lsp.buf.rename()
end

commands.type_definition = function()
    vim.lsp.buf.type_definition()
end

commands.workspace_symbol = function()
    vim.lsp.buf.workspace_symbol()
end

commands.goto_next = function()
    vim.lsp.buf.goto_next()
end

commands.goto_prev = function()
    vim.lsp.buf.goto_prev()
end

commands.show_line_diagnostics = function()
    vim.lsp.buf.show_line_diagnostics()
end

u.command("Remove", "call delete(expand('%')) | lua global.commands.bdelete()")
u.command("VsplitLast", "vsplit #")
u.command("Lazygit", "term lazygit")
u.command("R", "w | :e")

u.lua_command("Bonly", "global.commands.bonly()")
u.lua_command("Bwipeall", "global.commands.bwipeall()")
u.lua_command("Wwipeall", "global.commands.wwipeall()")
u.lua_command("Bdelete", "global.commands.bdelete()")
u.lua_command("TestFile", "global.commands.edit_test_file()")

-- gitsigns
u.lua_command("NextHunk", "global.commands.next_hunk()")
u.lua_command("PrevHunk", "global.commands.prev_hunk()")
u.lua_command("StageHunk", "global.commands.stage_hunk()")
u.lua_command("UndoStageHunk", "global.commands.undo_stage_hunk()")
u.lua_command("ResetHunk", "global.commands.reset_hunk()")
u.lua_command("ResetBuffer", "global.commands.reset_buffer()")
u.lua_command("PreviewHunk", "global.commands.preview_hunk()")
u.lua_command("BlameLine", "global.commands.blame_line()")

-- lsp
u.lua_command("LspAddToWorkspaceFolder", "global.commands.add_to_workspace_folder()")
u.lua_command("LspClearReferences", "global.commands.clear_references()")
u.lua_command("LspCodeAction", "global.commands.code_action()")
u.lua_command("LspDeclaration", "global.commands.declaration()")
u.lua_command("LspDefintion", "global.commands.definition()")
u.lua_command("LspDocumentSymbol", "global.commands.document_symbol()")
u.lua_command("LspFormatting", "global.commands.formatting()")
u.lua_command("LspFormattingSync", "global.commands.formatting_async()")
u.lua_command("LspHover", "global.commands.hover()")
u.lua_command("LspImplementation", "global.commands.implementation()")
u.lua_command("LspRangeCodeAction", "global.commands.range_code_action()")
u.lua_command("LspRangeFormatting", "global.commands.range_code_formatting()")
u.lua_command("LspReferences", "global.commands.references()")
u.lua_command("LspRename", "global.commands.rename()")
u.lua_command("LspTypeDefintion", "global.commands.type_definition()")
u.lua_command("LspWorkspaceSymbol", "global.commands.workspace_symbol()")
u.lua_command("LspGotoNext", "global.commands.goto_next()")
u.lua_command("LspGotoPrev", "global.commands.goto_prev()")
u.lua_command("LspShowLineDiagnostics", "global.commands.show_line_diagnostics()")

u.map("n", "<CR>", "v:lua.global.commands.save_on_cr()", { expr = true })

u.map("n", "q", "v:lua.global.commands.stop_recording()", { expr = true })
u.map("n", "<Leader>q", "q", { silent = false })

u.augroup("Autocomplete", "InsertCharPre", "lua global.commands.complete()")
u.augroup("YankHighlight", "TextYankPost", "lua global.commands.yank_highlight()")

_G.global.commands = commands

return commands
