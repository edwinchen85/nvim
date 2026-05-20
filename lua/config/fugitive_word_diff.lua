-- Word-level diff highlights inside fugitive status / git diff buffers.
-- Adjacent `-`/`+` line pairs get word-token diffed via vim.diff; changed
-- ranges painted with extmarks so only differing words stand out (GitHub style).

local M = {}

local NS = vim.api.nvim_create_namespace("fugitive_word_diff")

local function tokenize(s)
    local tokens = {}
    local pos = 1
    local n = #s
    while pos <= n do
        local ws_s, ws_e = s:find("^%s+", pos)
        if ws_s then
            tokens[#tokens + 1] = { text = s:sub(ws_s, ws_e), s = ws_s - 1, e = ws_e }
            pos = ws_e + 1
        else
            local wd_s, wd_e = s:find("^[%w_]+", pos)
            if wd_s then
                tokens[#tokens + 1] = { text = s:sub(wd_s, wd_e), s = wd_s - 1, e = wd_e }
                pos = wd_e + 1
            else
                tokens[#tokens + 1] = { text = s:sub(pos, pos), s = pos - 1, e = pos }
                pos = pos + 1
            end
        end
    end
    return tokens
end

local function diff_tokens(a_toks, b_toks)
    local a_strs, b_strs = {}, {}
    for i, t in ipairs(a_toks) do
        a_strs[i] = t.text:gsub("\n", " ")
    end
    for i, t in ipairs(b_toks) do
        b_strs[i] = t.text:gsub("\n", " ")
    end
    local a_text = table.concat(a_strs, "\n")
    local b_text = table.concat(b_strs, "\n")
    local ok, hunks = pcall(vim.diff, a_text, b_text, { result_type = "indices", algorithm = "histogram" })
    if not ok or type(hunks) ~= "table" then
        return {}, {}
    end
    local a_ranges, b_ranges = {}, {}
    for _, h in ipairs(hunks) do
        local a_s, a_c, b_s, b_c = h[1], h[2], h[3], h[4]
        if a_c > 0 then
            a_ranges[#a_ranges + 1] = { a_s, a_s + a_c - 1 }
        end
        if b_c > 0 then
            b_ranges[#b_ranges + 1] = { b_s, b_s + b_c - 1 }
        end
    end
    return a_ranges, b_ranges
end

local function paint_ranges(buf, lnum, toks, ranges, hl)
    for _, r in ipairs(ranges) do
        local s_tok = toks[r[1]]
        local e_tok = toks[r[2]]
        if s_tok and e_tok then
            pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum, s_tok.s + 1, {
                end_col = e_tok.e + 1,
                hl_group = hl,
                priority = 200,
            })
        end
    end
end

local function is_hunk_minus(line)
    return line and line:sub(1, 1) == "-" and line:sub(1, 3) ~= "---"
end

local function is_hunk_plus(line)
    return line and line:sub(1, 1) == "+" and line:sub(1, 3) ~= "+++"
end

function M.highlight_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local i = 1
    while i <= #lines do
        local cur = lines[i]
        local nxt = lines[i + 1]
        if is_hunk_minus(cur) and is_hunk_plus(nxt) then
            -- collect consecutive `-` lines then consecutive `+` lines (same hunk block)
            local minus_start = i
            local minus_end = i
            while is_hunk_minus(lines[minus_end + 1]) do
                minus_end = minus_end + 1
            end
            local plus_start = minus_end + 1
            local plus_end = plus_start
            while is_hunk_plus(lines[plus_end + 1]) do
                plus_end = plus_end + 1
            end

            -- pair line-by-line when counts match; else only diff first pair (cheap heuristic)
            local m_count = minus_end - minus_start + 1
            local p_count = plus_end - plus_start + 1
            local pair_count = math.min(m_count, p_count)
            for k = 0, pair_count - 1 do
                local rem = lines[minus_start + k]:sub(2)
                local add = lines[plus_start + k]:sub(2)
                local rem_toks = tokenize(rem)
                local add_toks = tokenize(add)
                local rem_changed, add_changed = diff_tokens(rem_toks, add_toks)
                paint_ranges(buf, minus_start + k - 1, rem_toks, rem_changed, "FugitiveWordDelete")
                paint_ranges(buf, plus_start + k - 1, add_toks, add_changed, "FugitiveWordAdd")
            end
            i = plus_end + 1
        else
            i = i + 1
        end
    end
end

local function set_default_hl()
    -- Tokyonight night palette: rose #f7768e, green #9ece6a; line bg ~#37222c/#20303b.
    -- Pick mid-saturation bg clearly brighter than fugitive's line bg, no fg override
    -- so original syntax colors stay readable.
    vim.api.nvim_set_hl(0, "FugitiveWordDelete", { bg = "#6b1e1e", default = true })
    vim.api.nvim_set_hl(0, "FugitiveWordAdd", { bg = "#2a4f37", default = true })
end

local function schedule_highlight(buf)
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
            M.highlight_buf(buf)
        end
    end)
end

local function is_target_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    local ft = vim.bo[buf].filetype
    if ft == "fugitive" or ft == "git" or ft == "diff" or ft == "gitcommit" then
        return true
    end
    local name = vim.api.nvim_buf_get_name(buf)
    -- fugitive object buffers (fugitive://...) may have ft set late
    if name:match("^fugitive://") then
        return true
    end
    return false
end

function M.attach()
    set_default_hl()
    local group = vim.api.nvim_create_augroup("FugitiveWordDiff", { clear = true })

    -- Re-apply highlight groups after colorscheme change (default = true would be cleared).
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = set_default_hl,
    })

    -- Fugitive status buffer: fires after status load and after each refresh (expand, stage, etc).
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "FugitiveIndex", "FugitiveChanged" },
        callback = function(ev)
            schedule_highlight(ev.buf)
        end,
    })

    -- Catch-all: fugitive's inline hunk expand (`=` keymap) may not fire User events.
    -- TextChanged fires after fugitive flips modifiable, rewrites lines, flips back.
    -- BufEnter/WinEnter catches already-open buffers after config reload.
    vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufWinEnter", "BufEnter", "WinEnter", "TextChanged" }, {
        group = group,
        callback = function(ev)
            if is_target_buf(ev.buf) then
                schedule_highlight(ev.buf)
            end
        end,
    })

    -- Manual trigger for debugging / forcing repaint.
    vim.api.nvim_create_user_command("FugitiveWordDiff", function()
        M.highlight_buf(vim.api.nvim_get_current_buf())
    end, { desc = "Repaint fugitive word-diff highlights in current buffer" })
end

return M
