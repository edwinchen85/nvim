if not pcall(vim.cmd.colorscheme, "tokyonight") then
    vim.cmd.colorscheme("default")
    vim.o.background = "dark"
end

-- nvim follows the terminal's light/dark (OSC 11) by flipping 'background', but
-- that alone doesn't reload the colorscheme: Normal/StatusLine stay on the old
-- palette, and lualine rebuilds from those stale groups (wrong badge text colour).
-- Re-applying the scheme refreshes every group and fires ColorScheme for lualine.
vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "background",
    callback = function()
        vim.schedule(function()
            if vim.g.colors_name == "tokyonight" then
                vim.cmd.colorscheme("tokyonight")
            end
        end)
    end,
})
