local M = {
    "dhruvasagar/vim-table-mode",
    cmd = { "TableModeToggle", "Tableize" },
    ft = { "markdown" },
}

function M.init()
    vim.g.table_mode_corner = "|"
    vim.g.table_mode_always_active = 1
end

return M

