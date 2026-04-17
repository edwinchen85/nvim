local M = {
    "ahmedkhalf/project.nvim",
}

function M.config()
    require("project_nvim").setup({
        active = true,
        manual_mode = false,
        detection_methods = { "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile" },
        show_hidden = false,
        silent_chdir = true,
        ignore_lsp = {},
    })
end

return M
