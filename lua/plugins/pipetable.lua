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
    opts = { format_on_edit = true },
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
end

return M
