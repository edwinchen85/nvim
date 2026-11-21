-- SQL client: editable table grids, schema browser, query pad with saved
-- queries and history (per project, under .grip/). Usage guide: db.md.
-- No `cmd` list: the plugin's own lazy.lua declares every :Grip* command as a
-- lazy-load trigger.
-- Completion is left at the default (`completion = true`): the query pad uses
-- grip's built-in popup and turns blink off for that buffer
-- (dadbod-grip/completion.lua, "Disable nvim-cmp and blink.cmp").
return {
    "joryeugene/dadbod-grip.nvim",
    opts = {
        keymaps = {
            -- Upstream default is <C-CR> (dadbod-grip/keymaps.lua). It can't
            -- arrive here: config/settings.lua turns modifyOtherKeys off on
            -- VimEnter (the Cmd+V paste fix), so under tmux <C-CR> reaches
            -- nvim as a plain <CR>.
            qpad_execute = "<C-e>",
        },
    },
    keys = {
        -- <leader>D, not upstream's suggested <leader>db: that is dap's
        -- breakpoint toggle (lua/plugins/dap.lua).
        { "<leader>D", "<cmd>GripConnect<cr>", desc = "Database" },
    },
}
