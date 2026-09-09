-- Fugitive status buffer behaviours: conflict warnings, word-level diff
-- highlights (config/fugitive_word_diff) and keeping which-key off the buffer.
local M = {}

-- Conflicts fugitive's status buffer cannot show:
--   * deletion conflicts (DU/UD/DD) — stage with `:Git rm`, not `-`
--   * binary conflicts (UU/AA/AU/UA with no text merge markers) — git cannot
--     text-merge them, so resolve via `:Git checkout --ours/--theirs <path>`.
--     Heuristic: unmerged path whose content has a NUL byte and no `<<<<<<<`.
-- Modern fugitive only renders the single-char status (e.g. `U file.txt`), so
-- the two-letter porcelain XY codes are unavailable in the buffer -- read them
-- from `git status --porcelain` directly.
local function read_head(path)
    local f = io.open(path, "rb")
    if not f then
        return nil
    end
    local chunk = f:read(8192) or ""
    f:close()
    return chunk
end

-- porcelain stdout -> { { kind = "deletion"|"binary", path = ..., line = ... } }
function M.conflicts(porcelain, reader)
    reader = reader or read_head
    local out = {}
    for line in porcelain:gmatch("[^\r\n]+") do
        local xy = line:sub(1, 2)
        if xy == "DU" or xy == "UD" or xy == "DD" then
            out[#out + 1] = { kind = "deletion", line = line }
        elseif xy == "UU" or xy == "AA" or xy == "AU" or xy == "UA" then
            local path = line:sub(4):gsub('^"(.*)"$', "%1")
            local chunk = reader(path)
            if chunk and chunk:find("\0", 1, true) and not chunk:find("<<<<<<<", 1, true) then
                out[#out + 1] = { kind = "binary", path = path, line = line }
            end
        end
    end
    return out
end

-- Both checks share ONE `git status --porcelain`: process spawn costs ~44ms
-- here (CrowdStrike Falcon hooks exec) and `:Gedit :` already pays for ~17.
local function warn_conflicts()
    vim.system(
        { "git", "status", "--porcelain" },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 or not result.stdout or result.stdout == "" then
                return
            end
            for _, c in ipairs(M.conflicts(result.stdout)) do
                local msg = c.kind == "deletion"
                        and ("⚠️  Deletion conflict detected: " .. c.line .. "\nUse :Git rm instead of staging")
                    or (
                        "⚠️  Binary file conflict: "
                        .. c.path
                        .. "\nResolve via :Git checkout --ours/--theirs <path>"
                    )
                vim.notify(msg, vim.log.levels.WARN, { timeout = 5000 })
            end
        end)
    )
end

-- which-key's BufEnter runs before fugitive sets `filetype=fugitive`, so its
-- `disable.ft = { "fugitive" }` check misses and a `g` trigger gets installed,
-- shadowing fugitive's buffer-local `g?`, `gO`, `gq`, etc. The trigger install
-- itself is queued via `M.timer:start(0, 0, vim.schedule_wrap(...))` from
-- BufEnter, so a synchronous clear inside `User FugitiveIndex` runs BEFORE the
-- trigger keymap exists — and gets undone when the timer fires.
-- Clear now, next tick and 50ms later, and nuke any buffer-local trigger maps.
local function detach_which_key(buf)
    local function detach()
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        local ok, wk_buf = pcall(require, "which-key.buf")
        if ok then
            wk_buf.clear({ buf = buf })
        end
        for _, mode in ipairs({ "n", "v", "x", "o", "i", "c", "t" }) do
            for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
                if km.desc and km.desc:find("which-key-trigger", 1, true) then
                    pcall(vim.keymap.del, mode, km.lhs, { buffer = buf })
                end
            end
        end
    end
    detach()
    vim.schedule(detach)
    vim.defer_fn(detach, 50)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("Fugitive", { clear = true })

    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "FugitiveIndex", "FugitiveChanged" },
        callback = function(ev)
            warn_conflicts()
            if ev.match == "FugitiveIndex" then
                detach_which_key(ev.buf)
            end
        end,
    })

    -- close git windows with q
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "fugitive", "GV" },
        callback = function(ev)
            vim.keymap.set("n", "q", "gq", { buffer = ev.buf, silent = true, remap = true })
        end,
    })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "git",
        callback = function(ev)
            vim.keymap.set("n", "q", "<C-w>c", { buffer = ev.buf, silent = true })
        end,
    })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "fugitiveblame",
        callback = function(ev)
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
        end,
    })

    require("config.fugitive_word_diff").attach()
end

return M
