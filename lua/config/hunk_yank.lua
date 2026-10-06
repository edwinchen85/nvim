-- Linewise yanks of hunk lines drop the diff markers.
--
-- In a diff view (fugitive commit and status buffers, GV), `Vy` over hunk lines
-- yanks the code without its leading `+`/`-`/space. Only when every yanked line
-- is a hunk body line: take a header (`diff --git`, `@@`, `+++`) along and the
-- yank stays a real patch, markers and all.
local M = {}

local FILETYPES = { git = true, diff = true, fugitive = true }

-- `lines` with the marker column cut, or nil when any line is not a hunk body
-- line. "" counts as a context line whose space was trimmed (trailing-space
-- strippers). File headers name a path (`--- a/x`, `+++ /dev/null`); a bare
-- `--- x` is a deleted `-- x` comment, a body line.
local function header(line)
    return line:match("^%-%-%- a/") or line:match("^%+%+%+ b/") or line:match("^[-+][-+][-+] /dev/null")
end

function M.strip(lines)
    local out = {}
    for i, line in ipairs(lines) do
        if header(line) or not line:match("^[-+ ]") and line ~= "" then
            return nil
        end
        out[i] = line:sub(2)
    end
    return out
end

function M.setup()
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("hunk_yank", { clear = true }),
        callback = function(args)
            local ev = vim.v.event
            if ev.operator ~= "y" or ev.regtype ~= "V" or not FILETYPES[vim.bo[args.buf].filetype] then
                return
            end
            local lines = M.strip(ev.regcontents)
            if not lines then
                return
            end
            -- An unnamed yank also lands in the clipboard registers named by 'clipboard', and
            -- setreg on `"` alone does not reach them, so rewrite each one.
            local regs = { ev.regname ~= "" and ev.regname or '"' }
            if ev.regname == "" or ev.regname == "+" or ev.regname == "*" then
                regs = { '"' }
                local cb = vim.o.clipboard
                if cb:find("unnamedplus") or ev.regname == "+" then
                    table.insert(regs, "+")
                end
                if cb:find("unnamed%f[,%z]") or ev.regname == "*" then
                    table.insert(regs, "*")
                end
            end
            for _, reg in ipairs(regs) do
                pcall(vim.fn.setreg, reg, lines, "V") -- no clipboard provider: skip, keep `"`
            end
        end,
    })
end

return M
