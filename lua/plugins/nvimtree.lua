vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_quit_on_open = 1 -- "0 by default, closes the tree when you open a file
vim.g.nvim_tree_indent_markers = 0 -- "0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_auto_ignore_ft = {"startify", "dashboard"} -- empty by default, don't auto open tree on specific filetypes.
vim.g.nvim_tree_root_folder_modifier = ":t" -- :~ by default, root folder display format
vim.g.nvim_tree_refresh_wait = 500 -- "1000 by default, control how often the tree can be refreshed

local tree_cb = require"nvim-tree.config".nvim_tree_callback

vim.g.nvim_tree_icons = {
    default = "",
    symlink = "",
    git = {
        unstaged = "",
        staged = "✓",
        unmerged = "",
        renamed = "➜",
        untracked = "★",
        deleted = "",
        ignored = "◌"
    },
    folder = {
        default = "",
        open = "",
        empty = "",
        empty_open = "",
        symlink = ""
    }
}

require'nvim-tree'.setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    open_on_setup       = false,
    ignore_ft_on_setup  = {},
    auto_close          = false,
    open_on_tab         = false,
    hijack_cursor       = false,
    update_cwd          = false,
    update_to_buf_dir   = {
        enable = true,
        auto_open = true,
    },
    diagnostics = {
        enable = false,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        }
    },
    update_focused_file = {
        enable      = false,
        update_cwd  = true
    },
    system_open = {
        cmd  = nil,
        args = {}
    },
    filters = {
        dotfiles = true,
        custom = { ".git", "node_modules", "backend", ".cache", "tags", ".DS_Store" }
    },
    view = {
        width = 40,
        height = 40,
        hide_root_folder = false,
        side = 'right',
        auto_resize = false,
        mappings = {
            custom_only = false,
            list = {
                { key = {"l", "<CR>", "o"}, cb = tree_cb("edit") },
                { key = "h", cb = tree_cb("close_node") },
                { key = "v", cb = tree_cb("vsplit") },
            },
        },
    },
}
