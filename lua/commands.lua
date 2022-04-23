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
u.nmap("<Leader>v", ":VsplitLast<CR>")

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

commands.stop_recording = function()
    return vim.fn.reg_recording() ~= "" and u.t("q") or ""
end

u.nmap("q", "v:lua.global.commands.stop_recording()", { expr = true })

api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
    end,
})

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

commands.blame_line = function()
    return require("gitsigns").blame_line()
end
-- end of gitsigns

-- harpoon
commands.add_mark = function()
    return require("harpoon.mark").add_file()
end

u.lua_command("AddMark", "global.commands.add_mark()")

commands.next_mark = function()
    return require("harpoon.ui").nav_next()
end

u.lua_command("NextMark", "global.commands.next_mark()")

commands.prev_mark = function()
    return require("harpoon.ui").nav_prev()
end

u.lua_command("PrevMark", "global.commands.prev_mark()")

commands.toggle_menu = function()
    return require("harpoon.ui").toggle_quick_menu()
end

u.lua_command("ToggleMenu", "global.commands.toggle_menu()")
-- end of harpoon

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

_G.global.commands = commands

return commands
