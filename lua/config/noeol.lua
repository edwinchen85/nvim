-- "\ No newline at end of file" marks.
--
-- Git's merge driver has to append a newline to the last line of a side before
-- it can write "=======" / ">>>>>>>", so two sides that differ ONLY in their
-- final newline look identical inside the markers. Ask the index for each
-- side's blob and mark the one that really lacks the newline. A missing final
-- newline can only affect the file's last line, so this is only decidable when
-- the conflict block runs to EOF.
--
-- The plain mark covers files with no final newline at all, conflict or not,
-- including the file you are left holding once the markers are gone. It reads
-- the last byte rather than 'endofline' on purpose: after a write with
-- 'fixendofline' on, Neovim appends the newline but leaves &eol at 0.
local M = {}

local marker = require("config.conflict_markers").marker
local conflict_ns = vim.api.nvim_create_namespace("conflict_noeol")
local buf_ns = vim.api.nvim_create_namespace("buf_noeol")

local function mark(buf, ns, row, label)
    vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
        virt_text = { { "  \\ No newline at end of file" .. label, "DiagnosticVirtualTextWarn" } },
        virt_text_pos = "eol",
    })
end

local function mark_conflict(buf)
    vim.api.nvim_buf_clear_namespace(buf, conflict_ns, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local last = #lines
    if last == 0 or marker(lines[last]) ~= "end" then
        return
    end

    -- Walk back over: theirs, [base (diff3/zdiff3)], ours.
    local sep, base, start
    for i = last - 1, 1, -1 do
        local kind = marker(lines[i])
        if kind == "start" then
            start = i
            break
        elseif kind == "base" then
            base = i
        elseif kind == "sep" and not sep then
            sep = i
        end
    end
    if not (start and sep) then
        return
    end

    -- ":<stage>:<path>" resolves against the repo root, so run git from the
    -- file's own directory and let "./name" do the resolving.
    local name = vim.api.nvim_buf_get_name(buf)
    local cwd = vim.fn.fnamemodify(name, ":h")
    local sides = {
        { stage = 2, line = (base or sep) - 1, label = "ours" },
        { stage = 3, line = last - 1, label = "theirs" },
    }
    for _, side in ipairs(sides) do
        vim.system(
            { "git", "show", ":" .. side.stage .. ":./" .. vim.fn.fnamemodify(name, ":t") },
            { cwd = cwd, text = true },
            vim.schedule_wrap(function(res)
                if
                    res.code == 0
                    and res.stdout ~= ""
                    and not res.stdout:match("\n$")
                    and vim.api.nvim_buf_is_valid(buf)
                then
                    mark(buf, conflict_ns, side.line - 1, " (" .. side.label .. ")")
                end
            end)
        )
    end
end

local function mark_plain(buf)
    vim.api.nvim_buf_clear_namespace(buf, buf_ns, 0, -1)

    local path = vim.api.nvim_buf_get_name(buf)
    local f = path ~= "" and io.open(path, "rb")
    if not f then
        return
    end
    local size = f:seek("end")
    if size == 0 then
        f:close()
        return
    end
    f:seek("set", size - 1)
    local last = f:read(1)
    f:close()
    if last == "\n" then
        return
    end
    mark(buf, buf_ns, vim.api.nvim_buf_line_count(buf) - 1, "")
end

function M.setup()
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("NoEol", { clear = true }),
        callback = function(ev)
            if vim.bo[ev.buf].buftype == "" then
                pcall(mark_conflict, ev.buf)
                pcall(mark_plain, ev.buf)
            end
        end,
    })
end

return M
