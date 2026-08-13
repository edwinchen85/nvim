local api = vim.api
-- Use spelling for markdown files ]s to find next, [s for previous, z= for suggestions when on one.
-- Source: http:--thejakeharding.com/tutorial/2012/06/13/using-spell-check-in-vim.html
vim.api.nvim_exec2(
    [[
        augroup markdownSpell
        autocmd!
        autocmd FileType markdown,md,txt setlocal spell
        autocmd BufRead,BufNewFile *.md,*.txt,*.markdown setlocal spell
        augroup END
    ]],
    {}
)

-- format markdown
vim.api.nvim_exec2(
    [[
        augroup markdownFormat
        autocmd!
        autocmd FileType md setlocal formatprg=pandoc\ -t\ commonmark_x
        autocmd FileType md setlocal equalprg=pandoc\ -t\ commonmark_x
        augroup END
    ]],
    {}
)

-- disable modifyOtherKeys after nvim terminal init (fixes Cmd+V paste in Ghostty+tmux)
-- restore is handled by shell wrapper in ~/.zshrc after nvim exits
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        io.write("\027[>4;0m")
        io.flush()
    end,
})

-- override for all file types
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    callback = function()
        vim.cmd("set formatoptions-=cro")
    end,
})

---@diagnostic disable-next-line: param-type-mismatch
vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
    callback = function()
        vim.cmd("quit")
    end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    pattern = { "*" },
    callback = function()
        vim.cmd("checktime")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("vertical_help", { clear = true }),
    pattern = "help",
    callback = function()
        vim.bo.bufhidden = "unload"
        vim.cmd.wincmd("L")
        vim.cmd.wincmd("=")
    end,
})

-- display brief highlight upon yank
api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 100 })
    end,
})

-- start hlslens immediately after a `/` or `?` search (not just on n/N)
vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = vim.api.nvim_create_augroup("hlslens_search", { clear = true }),
    callback = function()
        if vim.v.event.abort then
            return
        end
        local ct = vim.fn.getcmdtype()
        if ct == "/" or ct == "?" then
            vim.schedule(function()
                pcall(function()
                    require("hlslens").start()
                end)
            end)
        end
    end,
})

-- vimdows to close with 'q'
vim.cmd(
    [[autocmd FileType help,lspinfo,man,qf,fugitiveblame,netrw,tsplayground nnoremap <buffer><silent> q :close<CR>]]
)
vim.cmd([[autocmd FileType git nnoremap <buffer><silent> q <C-w>c]])
vim.cmd([[autocmd FileType fugitive,GV nmap <buffer><silent> q gq]])

-- wrap and spell for commit messages
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = vim.api.nvim_create_augroup("edit_text", { clear = true }),
    pattern = { "markdown", "txt" },
    desc = "Enable spell checking and text wrapping for certain filetypes",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 2
    end,
})

vim.api.nvim_create_autocmd({ "CursorHold" }, {
    callback = function()
        local status_ok, luasnip = pcall(require, "luasnip")
        if not status_ok then
            return
        end
        if luasnip.expand_or_jumpable() then
            -- ask maintainer for option to make this silent
            -- luasnip.unlink_current()
            vim.cmd([[silent! lua require("luasnip").unlink_current()]])
        end
    end,
})

-- treesitter powered fold
-- local parsers = require("nvim-treesitter.parsers")
-- local configs = parsers.get_parser_configs()
-- local ft_str = table.concat(
--     vim.tbl_map(function(ft)
--         return configs[ft].filetype or ft
--     end, parsers.available_parsers()),
--     ","
-- )
-- vim.cmd("autocmd Filetype " .. ft_str .. " setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()")

-- define custom Browse command to use GBrowse with range
vim.cmd([[ command! -bar -nargs=1 Browse silent! exe '!open' shellescape(<q-args>, 1) ]])

-- rotate windows
vim.api.nvim_create_user_command("RotateWindows", function()
    local ignored_filetypes = { "neo-tree", "fidget", "Outline", "toggleterm", "qf", "notify" }
    local window_numbers = vim.api.nvim_tabpage_list_wins(0)
    local windows_to_rotate = {}

    for _, window_number in ipairs(window_numbers) do
        local buffer_number = vim.api.nvim_win_get_buf(window_number)
        local filetype = vim.bo[buffer_number].filetype

        if not vim.tbl_contains(ignored_filetypes, filetype) then
            table.insert(windows_to_rotate, { window_number = window_number, buffer_number = buffer_number })
        end
    end

    local num_eligible_windows = vim.tbl_count(windows_to_rotate)

    if num_eligible_windows == 0 then
        return
    elseif num_eligible_windows == 1 then
        vim.notify("There is no other window to rotate with.", vim.log.levels.ERROR)
        return
    elseif num_eligible_windows == 2 then
        local firstWindow = windows_to_rotate[1]
        local secondWindow = windows_to_rotate[2]

        vim.api.nvim_win_set_buf(firstWindow.window_number, secondWindow.buffer_number)
        vim.api.nvim_win_set_buf(secondWindow.window_number, firstWindow.buffer_number)
    else
        vim.notify("You can only swap 2 open windows. Found " .. num_eligible_windows .. ".", vim.log.levels.ERROR)
    end
end, {})

-- resize windows
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("WinResize", { clear = true }),
    pattern = "*",
    command = "wincmd =",
    desc = "Auto-resize windows on terminal buffer resize.",
})

-- diagnostic signs
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
        },
    },
})

-- toggle diagnostics
vim.api.nvim_create_user_command("ToggleDiagnostics", function()
    if vim.g.diagnostics_enabled == nil then
        vim.g.diagnostics_enabled = false
        vim.diagnostic.enable(false)
    elseif vim.g.diagnostics_enabled then
        vim.g.diagnostics_enabled = false
        vim.diagnostic.enable(false)
    else
        vim.g.diagnostics_enabled = true
        vim.diagnostic.enable()
    end
end, {})

-- lsp progress
vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
            id = "lsp_progress",
            title = "LSP Progress",
            opts = function(notif)
                notif.icon = ev.data.params.value.kind == "end" and " "
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})

-- refresh lualine when quickfix list changes
local function refresh_lualine()
    vim.schedule(function()
        local ok, lualine = pcall(require, "lualine")
        if ok then
            lualine.refresh()
        end
    end)
end

-- standard quickfix commands (:grep, :make, etc.)
vim.api.nvim_create_autocmd({ "QuickFixCmdPost", "BufWinEnter", "BufWinLeave" }, {
    callback = refresh_lualine,
})

-- quicker.nvim: clears modified flag AFTER setqflist() — fire when saved
vim.api.nvim_create_autocmd("BufModifiedSet", {
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "quickfix" and not vim.bo[ev.buf].modified then
            refresh_lualine()
        end
    end,
})

-- auto create missing parent directories when saving a file.
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.fn.mkdir(vim.fn.expand("%:p:h"), "p")
    end,
})

-- Warn on conflicts fugitive's status buffer cannot show:
--   * deletion conflicts (DU/UD/DD) — stage with `:Git rm`, not `-`
--   * binary conflicts (UU/AA/AU/UA with no text merge markers) — git cannot
--     text-merge them, so resolve via `:Git checkout --ours/--theirs <path>`.
--     Heuristic: unmerged path whose content has a NUL byte and no `<<<<<<<`.
-- Modern fugitive only renders the single-char status (e.g. `U file.txt`), so
-- the two-letter porcelain XY codes are unavailable in the buffer -- read them
-- from git directly.
--
-- Both checks share ONE `git status --porcelain`; the XY sets are disjoint, so a
-- single pass covers both. Process spawn costs ~44ms here (CrowdStrike Falcon
-- hooks exec via the Endpoint Security framework), and `:Gedit :` already pays
-- for ~17 git subprocesses -- this ran the identical command twice per refresh.
local function warn_fugitive_conflicts()
    vim.system(
        { "git", "status", "--porcelain" },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 or not result.stdout or result.stdout == "" then
                return
            end
            for line in result.stdout:gmatch("[^\r\n]+") do
                local xy = line:sub(1, 2)
                if xy == "DU" or xy == "UD" or xy == "DD" then
                    vim.notify(
                        "⚠️  Deletion conflict detected: " .. line .. "\nUse :Git rm instead of staging",
                        vim.log.levels.WARN,
                        { timeout = 5000 }
                    )
                elseif xy == "UU" or xy == "AA" or xy == "AU" or xy == "UA" then
                    local path = line:sub(4):gsub('^"(.*)"$', "%1")
                    local f = io.open(path, "rb")
                    if f then
                        local chunk = f:read(8192) or ""
                        f:close()
                        local has_marker = chunk:find("<<<<<<<", 1, true)
                        local has_nul = chunk:find("\0", 1, true)
                        if has_nul and not has_marker then
                            vim.notify(
                                "⚠️  Binary file conflict: "
                                    .. path
                                    .. "\nResolve via :Git checkout --ours/--theirs <path>",
                                vim.log.levels.WARN,
                                { timeout = 5000 }
                            )
                        end
                    end
                end
            end
        end)
    )
end

vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("FugitiveDeletionConflict", { clear = true }),
    pattern = { "FugitiveIndex", "FugitiveChanged" },
    callback = warn_fugitive_conflicts,
})

-- GitHub-style word-level diff highlights in fugitive status / git diff buffers.
require("config.fugitive_word_diff").attach()

-- Mark "\ No newline at end of file" inside conflict markers.
-- Git's merge driver has to append a newline to the last line of a side before
-- it can write "=======" / ">>>>>>>", so two sides that differ ONLY in their
-- trailing newline render as identical text. Read the real bytes back from the
-- index stages and hang the missing-newline note off the line it belongs to.
local noeol_ns = vim.api.nvim_create_namespace("conflict_noeol")

local function mark_conflict_noeol(buf)
    vim.api.nvim_buf_clear_namespace(buf, noeol_ns, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local last = #lines
    -- A missing final newline can only ever affect the file's last line, so this
    -- is only decidable when the conflict block runs to EOF.
    if last == 0 or not lines[last]:match("^>>>>>>>") then
        return
    end

    -- Walk back over: theirs, [base (diff3/zdiff3)], ours.
    local sep, base, start
    for i = last - 1, 1, -1 do
        local l = lines[i]
        if l:match("^<<<<<<<") then
            start = i
            break
        elseif l:match("^|||||||") then
            base = i
        elseif l:match("^=======$") and not sep then
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
        local res = vim.system({ "git", "show", ":" .. side.stage .. ":./" .. vim.fn.fnamemodify(name, ":t") }, {
            cwd = cwd,
            text = true,
        }):wait()
        if res.code == 0 and res.stdout ~= "" and not res.stdout:match("\n$") then
            vim.api.nvim_buf_set_extmark(buf, noeol_ns, side.line - 1, 0, {
                virt_text = { { "  \\ No newline at end of file (" .. side.label .. ")", "DiagnosticVirtualTextWarn" } },
                virt_text_pos = "eol",
            })
        end
    end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("ConflictNoEol", { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "" then
            pcall(mark_conflict_noeol, ev.buf)
        end
    end,
})

-- Detach which-key triggers from fugitive status buffer.
-- which-key's BufEnter runs before fugitive sets `filetype=fugitive`, so its
-- `disable.ft = { "fugitive" }` check misses and a `g` trigger gets installed,
-- shadowing fugitive's buffer-local `g?`, `gO`, `gq`, etc. The trigger install
-- itself is queued via `M.timer:start(0, 0, vim.schedule_wrap(...))` from
-- BufEnter, so a synchronous clear inside `User FugitiveIndex` runs BEFORE the
-- trigger keymap exists — and gets undone when the timer fires.
-- Defer the clear past the next event-loop tick so it runs AFTER the install,
-- then nuke any matching buffer-local `g` triggers directly to be safe.
vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("FugitiveWhichKeyDetach", { clear = true }),
    pattern = "FugitiveIndex",
    callback = function(ev)
        local buf = ev.buf
        local function detach()
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            local ok, wk_buf = pcall(require, "which-key.buf")
            if ok then
                wk_buf.clear({ buf = buf })
            end
            -- Belt-and-braces: scan buffer-local keymaps in every relevant mode and
            -- delete anything tagged as a which-key trigger. Covers all triggers
            -- (`<leader>`, `g`, `z`, `<C-w>`, `"`, `'`, `` ` ``, `<C-r>`, ...).
            for _, mode in ipairs({ "n", "v", "x", "o", "i", "c", "t" }) do
                for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
                    if km.desc and km.desc:find("which-key-trigger", 1, true) then
                        pcall(vim.keymap.del, mode, km.lhs, { buffer = buf })
                    end
                end
            end
        end
        -- Run synchronously (covers triggers already installed), then again on
        -- next ticks to catch whichkey's deferred re-install scheduler.
        detach()
        vim.schedule(detach)
        vim.defer_fn(detach, 50)
    end,
})

-- auto capitalize in markdown file
-- vim.api.nvim_create_autocmd("InsertCharPre", {
--     pattern = "*.md",
--     callback = function()
--         local pos = vim.fn.search([[\v(%^|[.!?]\_s+|\_^\-\s|\_^title\:\s|\n\n)%#]], "bcnw")
--         if pos ~= 0 then
--             vim.v.char = vim.fn.toupper(vim.v.char)
--         end
--     end,
-- })

-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "markdown",
--     callback = function()
--         vim.cmd("iabbrev i'm I'm")
--         vim.cmd("iabbrev i'll I'll")
--         vim.cmd("iabbrev i've I've")
--         vim.cmd("iabbrev i'd I'd")
--     end,
-- })
