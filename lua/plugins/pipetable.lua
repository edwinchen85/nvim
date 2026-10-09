local M = {
    "dominic-righthere/markdown-pipetable.nvim",
    ft = { "markdown" },
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
    -- orange block; plain Normal text instead.
    opts = {
        format_on_edit = true,
        column = { max_width = 120 },
        highlights = { cursor_cell = "PipetableCursorCellSoft", edit = "Normal" },
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

        return paint_table(buf, tbl, W, scroll, active, sel, popts, hl, skip)
    end

    -- edit.open paints nothing after opening the editor, so repaint to drop the
    -- bg. commit/cancel already repaint after clearing `st.edit`.
    -- The editor's scratch buffer has no filetype, which lualine's
    -- `disabled_filetypes` blanks; name it so lualine's `ignore_focus` keeps
    -- showing the markdown window underneath (see `plugins/lualine.lua`).
    local edit = require("pipetable.edit")
    local open = edit.open

    edit.open = function(buf, start_insert)
        open(buf, start_insert)
        local e = state.get(buf).edit
        if e then
            vim.bo[e.ebuf].filetype = "pipetable_cell"
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

    width.fit = function(s, n, side, ellipsis)
        if type(s) == "string" and s:find("](", 1, true) then
            s = s:gsub("!%[([^%]]*)%]%([^%)]*%)", ICON.image .. "%1")
            s = s:gsub("%[([^%]]*)%]%([^%)]*%)", ICON.link .. "%1")
        end
        if type(s) == "string" and s:find("`", 1, true) then
            s = s:gsub("`([^`]+)`", "%1")
        end
        if type(s) == "string" and s:find("**", 1, true) then
            s = s:gsub("%*%*(.-)%*%*", "%1")
        end

        return fit(s, n, side, ellipsis)
    end
end

return M
