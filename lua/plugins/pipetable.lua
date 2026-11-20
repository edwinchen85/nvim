local M = {
    "dominic-righthere/markdown-pipetable.nvim",
    -- kulala_ui: kulala's response window draws its report (R) and headers (H)
    -- views as markdown pipe tables; see the kulala_ui section of `config`.
    ft = { "markdown", "kulala_ui" },
    cmd = { "Pipetable" },
    -- Repo name doesn't match the module name, so lazy can't infer it for `opts`.
    main = "pipetable",
    -- render-markdown's `pipe_table` is disabled to match -- both on stacks two
    -- sets of borders and they fight over `concealcursor`.
    -- `format_on_edit` repads the table source on commit; without it the raw
    -- text stays ragged even though the overlay renders aligned, which shows up
    -- in diffs and anywhere the file is read outside Neovim.
    -- `max_width` (default 40) caps every column and cuts the rest with `…`, even
    -- with room to spare. A table wider than the window scrolls sideways (‹/›,
    -- h/l) instead, so cap high. Display only: format.lua measures the file form.
    -- `cursor_cell` defaults to `reverse`, a white block on a dark theme; link to
    -- a soft tokyonight bg instead (defined in `plugins/tokyonight.lua`).
    -- `edit` (cell editor and the NAV/VIS/EDIT badge) defaults to IncSearch, an
    -- orange block. The badge gets a soft accent; the editor float is set back to
    -- plain Normal in `edit.open` below.
    opts = {
        filetypes = { "markdown", "kulala_ui" },
        format_on_edit = true,
        column = { max_width = 120 },
        highlights = { cursor_cell = "PipetableCursorCellSoft", edit = "PipetableBadge" },
    },
}

function M.config(_, opts)
    require("pipetable").setup(opts)

    -- Upstream bug: pipetable's CursorMoved handler runs synchronously, so it
    -- beats the TextChanged handler that marks the table cache dirty. Delete a
    -- whole table and the next cursor move repaints the pre-delete line ranges,
    -- and nvim_buf_set_extmark throws "Invalid 'line': out of range"
    -- (render.lua:66). changedtick catches the edit TextChanged hasn't reported
    -- yet. Drop this once upstream invalidates the cache itself.
    local manager = require("pipetable.manager")
    local state = require("pipetable.state")
    local on_cursor = manager.on_cursor

    -- The autocmd calls `M.on_cursor(buf)`, a table lookup at call time, so
    -- replacing the field is enough -- no need to touch the plugin's source.
    manager.on_cursor = function(buf)
        if vim.api.nvim_buf_is_valid(buf) then
            local st = state.get(buf)
            local tick = vim.api.nvim_buf_get_changedtick(buf)
            if st.seen_changedtick ~= tick then
                st.seen_changedtick = tick
                st.dirty = true
            end
        end

        return on_cursor(buf)
    end

    -- kulala_ui is read-only, and its own buffer-local keys (q close, V
    -- verbose) must win; <CR> (kulala: jump to request) is the exception,
    -- taken over by the cell peek below while in table mode. Table modes there keep only moving,
    -- yanking and selecting; the rest of `keymaps.lua` install_navigate /
    -- install_visual (cell editor, row/column ops, undo) would edit the buffer
    -- or shadow a kulala key. keymaps.install is called by field lookup.
    local function is_kulala(buf)
        return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "kulala_ui"
    end

    local keymaps = require("pipetable.keymaps")
    local install = keymaps.install

    local function kulala_drop()
        local keys = require("pipetable.config").get().keys
        local drop = { u = true, ["<C-r>"] = true }
        local function add(lhs)
            for _, k in ipairs(type(lhs) == "table" and lhs or { lhs }) do
                if type(k) == "string" then
                    drop[k] = true
                end
            end
        end
        for _, name in ipairs({
            "quit",
            "into_cell",
            "edit",
            "edit_append",
            "new_row_below",
            "new_row_above",
            "delete_row",
            "paste_below",
            "paste_above",
            "visual_row",
        }) do
            add(keys.nav[name])
        end
        add(keys.visual.delete)
        add(keys.visual.clear)
        add(keys.visual.switch_row)
        return drop, keys.leader
    end

    -- With the cell editor gone, a cell cut by `max_width` (`…`) has no way to
    -- show its full text. <CR> opens it read-only in a wrapped float (q/<Esc>
    -- close; focus it with <C-w>w to scroll or yank). Table moves (h/l) shift
    -- only the painted cursor, not the real one, so CursorMoved can't close it:
    -- every table key closes it first instead (see keymaps.install below).
    local peek_win

    local function close_peek()
        if peek_win and vim.api.nvim_win_is_valid(peek_win) then
            vim.api.nvim_win_close(peek_win, true)
        end
        peek_win = nil
    end

    local function peek_cell(buf)
        local st = state.get(buf)
        local a = st.active
        local tbl = a and st.tables[a.ti]
        local row = tbl and tbl.rows[a.row]
        local cell = row and row.cells[a.col]
        if not cell then
            return
        end
        local text = require("pipetable.width").unescape_pipe(cell.text or "")
        -- JSON objects/arrays (common in kulala headers) get pretty-printed.
        local ok, decoded = pcall(vim.json.decode, text)
        local lines = ok and type(decoded) == "table" and vim.split(vim.json.encode(decoded, { indent = "  " }), "\n")
            or { text }
        local ft = #lines > 1 and "json" or ""
        local width = math.min(math.max(vim.fn.strdisplaywidth(text), 20), math.floor(vim.o.columns * 0.6))
        close_peek()
        _, peek_win = vim.lsp.util.open_floating_preview(lines, ft, {
            max_width = width,
            wrap = true,
            focus_id = "pipetable_kulala_peek",
            close_events = { "CursorMoved", "BufLeave", "WinScrolled" },
        })
    end

    keymaps.install = function(buf, mode_name, maps)
        if is_kulala(buf) then
            local drop, leader = kulala_drop()
            maps = vim.tbl_filter(function(m)
                local lhs = m[1]
                return type(lhs) ~= "string" or not (drop[lhs] or (leader and vim.startswith(lhs, leader)))
            end, maps)
            maps = vim.tbl_map(function(m)
                local fn = m[2]
                return {
                    m[1],
                    function(...)
                        close_peek()
                        return fn(...)
                    end,
                    m[3],
                }
            end, maps)
            if mode_name == "table-navigate" then
                table.insert(maps, {
                    "<CR>",
                    function()
                        peek_cell(buf)
                    end,
                    "pipetable: show full cell",
                })
            end
        end

        return install(buf, mode_name, maps)
    end

    -- kulala rewrites the whole buffer on every view switch or new response,
    -- usually while focus is in the .http window, so TextChanged never fires
    -- there. It re-sets filetype after each write (`kulala/ui/init.lua`
    -- set_buffer_contents), which re-fires FileType: leave table mode (its
    -- active table is gone) and repaint.
    local pt_mode = require("pipetable.mode")

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("pipetable_kulala", { clear = true }),
        pattern = "kulala_ui",
        callback = function(ev)
            local st = state.get(ev.buf)
            if st.mode ~= "inactive" then
                pt_mode.exit(ev.buf)
            end
            st.dirty = true
            manager.request_redraw(ev.buf)
        end,
    })

    -- refresh writes conceallevel=2 and, outside table mode, concealcursor=""
    -- on every repaint (cursor moves, BufWinEnter), and render-markdown writes
    -- its own 3/"nvic" back on its next debounced render. In between the
    -- screen draws with the cursor line unconcealed, so a link under the cursor
    -- flashes its raw `[text](url)`. Hand render-markdown's values back in the
    -- same tick, while it renders (its `render_modes`); the cursor row of an
    -- inactive table is skipped by paint_table anyway, so it still shows raw.
    -- SIMPLIFIED: values restated from `plugins/render-markdown.lua`
    -- (conceallevel is its default `rendered`); read its config if they diverge.
    local refresh = manager.refresh

    manager.refresh = function(buf)
        refresh(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_buf_is_valid(buf) and manager.win_for(buf)
        local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
        -- No render-markdown in kulala_ui. Its tables are painted on the cursor
        -- row too (paint_table below), so keep that row concealed as well.
        if win and is_kulala(buf) then
            vim.wo[win].concealcursor = "nvic"
            return
        end
        if win and (mode == "n" or mode == "c") then
            if vim.wo[win].conceallevel ~= 3 then
                vim.wo[win].conceallevel = 3
            end
            if vim.wo[win].concealcursor ~= "nvic" then
                vim.wo[win].concealcursor = "nvic"
            end
        end
    end

    -- The cell editor float covers only the cell text, so the focused cell's
    -- padding still shows PipetableCursorCell's bg on both sides of it. Paint the
    -- focused cell plain while the editor is open, and drop the row tint too.
    -- The tint is stacked on each chunk's own group (`{ border, cursor_row }`),
    -- so it swaps to an empty group rather than `cell`, whose fg would recolour
    -- the borders. manager calls `render.paint_table` by field lookup, so
    -- replacing the field is enough.
    local render = require("pipetable.render")
    local paint_table = render.paint_table
    vim.api.nvim_set_hl(0, "PipetableEditRow", {})

    render.paint_table = function(buf, tbl, W, scroll, active, sel, popts, hl, skip)
        if active and state.get(buf).edit then
            hl = vim.tbl_extend("force", hl, { cursor_cell = hl.cell, cursor_row = "PipetableEditRow" })
        end
        -- manager.refresh leaves the cursor row of an inactive table raw so it
        -- can be edited (manager.lua `skip`); kulala_ui is never edited.
        if is_kulala(buf) then
            skip = nil
        end

        return paint_table(buf, tbl, W, scroll, active, sel, popts, hl, skip)
    end

    -- edit.open paints nothing after opening the editor, so repaint to drop the
    -- bg. commit/cancel already repaint after clearing `st.edit`.
    -- The editor's scratch buffer has no filetype, which lualine's
    -- `disabled_filetypes` blanks; name it so lualine's `ignore_focus` keeps
    -- showing the markdown window underneath (see `plugins/lualine.lua`).
    -- Upstream's ModeChanged handler flips `st.mode` between in-cell and
    -- in-cell-edit without repainting, so the badge keeps the old label until
    -- something else redraws. Ours is registered after it, so it repaints with
    -- the new mode.
    -- lualine has the same lag: with globalstatus it refreshes only non-float
    -- windows on events, while laststatus=3 draws the focused float's own
    -- 'statusline', a copy made at open that only lualine's 1s timer updates.
    -- Force a refresh and copy the markdown window's line into the float.
    local function sync_statusline(buf, ewin)
        local win = manager.win_for(buf)
        local ok, lualine = pcall(require, "lualine")
        if ok and win and vim.api.nvim_win_is_valid(ewin) then
            lualine.refresh({ place = { "statusline" }, force = true })
            vim.wo[ewin].statusline = vim.wo[win].statusline
        end
    end

    -- Upstream sizes the editor to the whole value (edit.lua:66), so a long cell
    -- spills over its neighbours, and past the window edge nvim shifts the float
    -- left over the line numbers. Clamp it to the cell's column width; the float
    -- is nowrap, so the rest scrolls sideways. Same plan call as upstream's.
    local layout = require("pipetable.layout")
    local config = require("pipetable.config")

    local function cell_width(buf)
        local st = state.get(buf)
        local win = manager.win_for(buf)
        local tbl = st.active and st.tables[st.active.ti]
        if not (win and tbl) then
            return nil
        end
        local plan = layout.plan(tbl, manager.usable_width(win), st.scroll.col_off, config.get())
        for _, c in ipairs(plan.columns) do
            if c.idx == st.active.col then
                return c.width
            end
        end
    end

    local edit = require("pipetable.edit")
    local open = edit.open

    edit.open = function(buf, start_insert)
        open(buf, start_insert)
        local e = state.get(buf).edit
        if e then
            local cw = cell_width(buf)
            if cw and cw > 0 and cw < vim.api.nvim_win_get_width(e.ewin) then
                vim.api.nvim_win_set_config(e.ewin, { width = cw })
                -- global sidescrolloff (8) would eat a narrow cell
                vim.wo[e.ewin].sidescrolloff = math.min(vim.o.sidescrolloff, math.floor(cw / 4))
            end
            vim.bo[e.ebuf].filetype = "pipetable_cell"
            vim.wo[e.ewin].winhighlight = "Normal:Normal"
            vim.api.nvim_create_autocmd("ModeChanged", {
                buffer = e.ebuf,
                callback = function()
                    local cur = state.get(buf).edit
                    if cur then
                        manager.refresh(buf)
                        sync_statusline(buf, cur.ewin)
                    end
                end,
            })
            manager.refresh(buf)
        end
    end

    -- Upstream bug: commit writes the cell back (and `format_on_edit` rewrites
    -- the whole table) even when the text is unchanged, so leaving a cell marks
    -- the buffer modified and adds an undo step. Leave an untouched cell the way
    -- `q` (cancel) does; for <Tab>, advance as commit would. Same trim/join as
    -- commit's own read of the editor buffer.
    local navigate = require("pipetable.navigate")
    local commit = edit.commit

    edit.commit = function(buf, move_next)
        local st = state.get(buf)
        local e = st.edit
        if not e or not vim.api.nvim_buf_is_valid(e.ebuf) then
            return commit(buf, move_next)
        end
        local value = vim.trim(table.concat(vim.api.nvim_buf_get_lines(e.ebuf, 0, -1, false), " "))
        if value ~= vim.trim(e.orig) then
            return commit(buf, move_next)
        end

        edit.cancel(buf)
        local tbl = st.tables[st.active.ti]
        local win = manager.win_for(buf)
        if move_next and tbl and st.active.col < tbl.ncols and win then
            st.active.col = st.active.col + 1
            navigate.ensure_visible(buf, tbl, manager.usable_width(win))
            manager.refresh(buf)
            edit.open(buf, true)
        end
    end

    -- pipetable prints cell text verbatim, so a link shows as `[label](url)`
    -- while prose a few lines down renders it as `󰌹 label`, inline code keeps
    -- its backticks and bold keeps its `**`. Rewrite them for display only:
    -- `width.fit` is the sole display-side consumer of cell text (layout.lua:118),
    -- while `format.lua` rewrites the buffer through `width.align`, so this can
    -- never reach the file. fit() still pads to the column width, so columns stay
    -- aligned. Inline code gets no box and bold no weight: a cell is one
    -- virt_text chunk with one highlight.
    -- SIMPLIFIED: plain patterns, no nested brackets, escaped `\]` or ``double``
    -- backtick spans; single-`*` italics and `__bold__` stay as typed (`__`
    -- collides with identifiers like `__init__`); icons are render-markdown's
    -- defaults, restated because it exposes no accessor.
    local width = require("pipetable.width")
    local fit = width.fit
    local ICON = { link = "󰌹 ", image = "󰥶 " }

    local function display(s)
        if s:find("](", 1, true) then
            s = s:gsub("!%[([^%]]*)%]%([^%)]*%)", ICON.image .. "%1")
            s = s:gsub("%[([^%]]*)%]%([^%)]*%)", ICON.link .. "%1")
        end
        if s:find("`", 1, true) then
            s = s:gsub("`([^`]+)`", "%1")
        end
        if s:find("**", 1, true) then
            s = s:gsub("%*%*(.-)%*%*", "%1")
        end
        return s
    end

    width.fit = function(s, n, side, ellipsis)
        if type(s) == "string" then
            s = display(s)
        end

        return fit(s, n, side, ellipsis)
    end

    -- The parser sizes columns on the file form, so a link's hidden URL still
    -- widens its column and the shortened label sits in a wall of padding.
    -- Re-measure on the display form. `cell.width` and `tbl.widths` feed only
    -- layout (display); format.lua measures the file form itself, so the file
    -- stays aligned. parse_buffer calls `M.build_table` by field lookup.
    local parser = require("pipetable.parser")
    local build_table = parser.build_table

    parser.build_table = function(...)
        local tbl = build_table(...)
        if not tbl then
            return tbl
        end
        local cfg = require("pipetable.config").get().column
        for c = 1, tbl.ncols do
            tbl.widths[c] = 0
        end
        for _, row in ipairs(tbl.rows) do
            for c = 1, tbl.ncols do
                local cell = row.cells[c]
                if cell then
                    cell.width = width.width(display(width.unescape_pipe(cell.text)))
                    tbl.widths[c] = math.max(tbl.widths[c], cell.width)
                end
            end
        end
        for c = 1, tbl.ncols do
            tbl.widths[c] = math.max(cfg.min_width, math.min(cfg.max_width, tbl.widths[c]))
        end

        return tbl
    end
end

return M
