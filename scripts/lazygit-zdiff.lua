-- Lazygit diff renderer: stdin (plain git diff/show) -> zdiff-styled ANSI.
-- Reuses zdiff's own render + syntax modules (incl. the vue patch in
-- plugins/zdiff.lua), so lazygit diffs look like :Zdiff.
-- Each row carries an OSC 1717 record (lazygit's diff-line protocol, v1:
-- "1;type;new-line;old-line;path") so lazygit can stage/select on this
-- rendering when the main view is focused instead of falling back to raw git.
-- lazygit config: command: nvim --headless -c 'luafile ~/.config/nvim/scripts/lazygit-zdiff.lua' -c 'qa!'
--                 colorArg: never
vim.notify = function() end -- zdiff's setup() deprecation warning would land in the diff

local input = {}
for l in io.lines() do
    input[#input + 1] = l
end

-- Parse into zdiff's model shape (see zdiff/git.lua M.patch + parse_statuses).
local preamble, files, file, hunk, old_line, new_line = {}, {}, nil, nil, 0, 0
for _, line in ipairs(input) do
    -- prefix is a/ b/ or mnemonic (i/ w/ c/ ...); strip the first component
    local a, b = line:match("^diff %-%-git [^/ ]+/(.-) [^/ ]+/(.*)$")
    if a or line:match("^diff %-%-git ") or line:match("^diff %-%-cc ") then
        file = {
            path = b or line:match("(%S+)$"),
            status = "M",
            additions = 0,
            deletions = 0,
            expanded = true,
            patch = {},
        }
        files[#files + 1] = file
        hunk = nil
    elseif not file then
        preamble[#preamble + 1] = line
    elseif not hunk then
        if line:match("^new file mode") then
            file.status = "A"
        elseif line:match("^deleted file mode") then
            file.status = "D"
        elseif line:match("^rename from ") then
            file.status = "R"
            file.old_path = line:sub(13)
        elseif line:match("^rename to ") then
            file.path = line:sub(11)
        elseif line:match("^copy from ") then
            file.status = "C"
            file.old_path = line:sub(11)
        elseif line:match("^copy to ") then
            file.path = line:sub(9)
        elseif line:match("^%+%+%+ [^/ ]+/") then
            file.path = line:match("^%+%+%+ [^/ ]+/(.*)$")
        elseif line:match("^%-%-%- [^/ ]+/") and file.status == "D" then
            file.path = line:match("^%-%-%- [^/ ]+/(.*)$")
        end
    end
    if file and line:match("^@@") then
        local os_, ns = line:match("^@@ %-(%d+),?%d* %+(%d+),?%d* @@")
        old_line, new_line = tonumber(os_) or 0, tonumber(ns) or 0
        hunk = { header = line, lines = {}, new_start = new_line }
        table.insert(file.patch, hunk)
    elseif hunk and line:sub(1, 1) ~= "\\" then
        local p, e = line:sub(1, 1), { text = line:sub(2) }
        if p == "+" then
            e.kind, e.new_line = "add", new_line
            new_line = new_line + 1
            file.additions = file.additions + 1
        elseif p == "-" then
            e.kind, e.old_line, e.new_pos = "delete", old_line, new_line
            old_line = old_line + 1
            file.deletions = file.deletions + 1
        elseif p == " " or line == "" then
            e.kind, e.old_line, e.new_line = "context", old_line, new_line
            old_line, new_line = old_line + 1, new_line + 1
        end
        if e.kind then
            table.insert(hunk.lines, e)
        end
    end
end

local out = {}
local announce = "\27]1717;1\7" -- protocol version record
local function rgb(n)
    return string.format("%d;%d;%d", bit.rshift(n, 16), bit.band(bit.rshift(n, 8), 255), bit.band(n, 255))
end
local cache = {}
local function attrs(group)
    if cache[group] then
        return cache[group]
    end
    local g, hl = group, {}
    while g do
        hl = vim.api.nvim_get_hl(0, { name = g, link = false })
        if next(hl) then
            break
        end
        g = g:match("^(.*)%.[^.]+$")
    end
    cache[group] = hl
    return hl
end

-- preamble (git show's commit header): hash line + dim message, as is
local c_title, c_dim = attrs("Title"), attrs("Comment")
for _, l in ipairs(preamble) do
    local hl = l:match("^commit ") and c_title or (l:match("^%a+:") and c_dim) or nil
    out[#out + 1] = (hl and hl.fg) and ("\27[38;2;" .. rgb(hl.fg) .. "m" .. l .. "\27[0m") or l
end

if #files > 0 then
    local ok_r, render = pcall(require, "zdiff.render")
    local ok_s, syntax = pcall(require, "zdiff.syntax")
    local r = ok_r and render.render({ base = "", files = files }) or { lines = {}, highlights = {}, patch_rows = {} }
    local hls = vim.deepcopy(r.highlights)
    if ok_s then
        vim.list_extend(hls, syntax.highlights(files, r.patch_rows))
    end

    -- OSC 1717 record per rendered row
    local meta = {}
    for line, fi in pairs(r.file_lines or {}) do
        meta[line] = "1;f;;;" .. files[fi].path
    end
    for fi, hunks_rows in pairs(r.patch_rows or {}) do
        local f = files[fi]
        for hi, rows in pairs(hunks_rows) do
            local h = f.patch[hi]
            if rows[1] then
                meta[rows[1] - 1] = "1;h;" .. h.new_start .. ";;" .. f.path
            end
            for li, row in pairs(rows) do
                local e = h.lines[li]
                if e.kind == "add" then
                    meta[row] = "1;a;" .. e.new_line .. ";;" .. f.path
                elseif e.kind == "delete" then
                    meta[row] = "1;d;" .. e.new_pos .. ";" .. e.old_line .. ";" .. f.path
                else
                    meta[row] = "1;c;" .. e.new_line .. ";;" .. f.path
                end
            end
        end
    end

    -- per line: column -> {fg, fgprio, bg, italic, bold}
    local by_line = {}
    for i, h in ipairs(hls) do
        by_line[h.line] = by_line[h.line] or {}
        table.insert(by_line[h.line], { h, i })
    end
    -- skip zdiff's "Uncommitted changes" title + blank line
    for ln = 3, #r.lines do
        local text = r.lines[ln]
        local cells = {}
        local list = by_line[ln] or {}
        table.sort(list, function(x, y)
            local px, py = x[1].priority or 0, y[1].priority or 0
            if px ~= py then
                return px < py
            end
            return x[2] < y[2]
        end)
        for _, item in ipairs(list) do
            local h = item[1]
            local a = attrs(h.group)
            local e = (h.end_col == -1 or h.end_col > #text) and #text or h.end_col
            for c = h.start_col, e - 1 do
                local cell = cells[c] or {}
                if a.fg then
                    cell.fg = a.fg
                end
                if a.bg then
                    cell.bg = a.bg
                end
                if a.italic ~= nil then
                    cell.italic = a.italic
                end
                if a.bold ~= nil then
                    cell.bold = a.bold
                end
                cells[c] = cell
            end
        end
        local parts, prev = { meta[ln] and ("\27]1717;" .. meta[ln] .. "\7") or "" }, ""
        for c = 0, #text - 1 do
            local cell = cells[c]
            local sgr = "\27[0"
            if cell then
                if cell.bold then
                    sgr = sgr .. ";1"
                end
                if cell.italic then
                    sgr = sgr .. ";3"
                end
                if cell.fg then
                    sgr = sgr .. ";38;2;" .. rgb(cell.fg)
                end
                if cell.bg then
                    sgr = sgr .. ";48;2;" .. rgb(cell.bg)
                end
            end
            sgr = sgr .. "m"
            if sgr ~= prev then
                parts[#parts + 1] = sgr
                prev = sgr
            end
            parts[#parts + 1] = text:sub(c + 1, c + 1)
        end
        parts[#parts + 1] = "\27[0m"
        out[#out + 1] = table.concat(parts)
    end
end
io.stdout:write(announce, table.concat(out, "\n"), "\n")
