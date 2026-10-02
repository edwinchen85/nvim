-- Sign column that is always 1 cell wide and grows to 2 only while a diagnostic
-- sign and a gitsigns sign want the same line (the higher-priority diagnostic
-- would otherwise hide the git bar). 'signcolumn' has no native "min 1, grow on
-- demand" mode: auto:1-2 drops to 0 cells with no signs, yes:N never shrinks.
local M = {}

---@param diag_rows table<integer, true> 1-based lines carrying a diagnostic
---@param ranges {[1]: integer, [2]: integer}[] 1-based inclusive git sign ranges
function M.overlaps(diag_rows, ranges)
    for _, r in ipairs(ranges) do
        for row = r[1], r[2] do
            if diag_rows[row] then
                return true
            end
        end
    end
    return false
end

local function hunk_ranges(buf)
    local ok, hunks = pcall(require("gitsigns").get_hunks, buf)
    local ranges = {}
    for _, h in ipairs(ok and hunks or {}) do
        local first = math.max(h.added.start, 1) -- topdelete reports start 0
        ranges[#ranges + 1] = { first, h.added.count > 0 and h.added.start + h.added.count - 1 or first }
    end
    return ranges
end

local function update(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local rows = {}
    for _, d in ipairs(vim.diagnostic.get(buf)) do
        rows[d.lnum + 1] = true
    end
    local value = M.overlaps(rows, hunk_ranges(buf)) and "yes:2" or "yes:1"
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.wo[win].signcolumn = value
    end
end

function M.setup()
    vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufWinEnter" }, {
        callback = function(args)
            update(args.buf)
        end,
    })
    vim.api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        callback = function(args)
            update(args.data and args.data.buffer or args.buf)
        end,
    })
end

return M
