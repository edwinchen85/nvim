vim.g.nvim_tree_ignore = {
    ".git", "node_modules", "backend", ".cache", "tags", ".DS_Store"
} -- "empty by default
vim.g.nvim_tree_side = "right" -- "left by default
vim.g.nvim_tree_width = 40 -- "30 by default
vim.g.nvim_tree_quit_on_open = 1 -- "0 by default, closes the tree when you open a file
vim.g.nvim_tree_hide_dotfiles = 1 -- 0 by default, this option hides files and folders starting with a dot `.`
vim.g.nvim_tree_indent_markers = 1 -- "0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_follow = 0 -- "0 by default, this option allows the cursor to be updated when entering a buffer
vim.g.nvim_tree_auto_close = 1 -- 0 by default, closes the tree when it's the last window
vim.g.nvim_tree_auto_ignore_ft = {"startify", "dashboard"} -- empty by default, don't auto open tree on specific filetypes.
vim.g.nvim_tree_root_folder_modifier = ":t" -- :~ by default, root folder display format

local tree_cb = require"nvim-tree.config".nvim_tree_callback
vim.g.nvim_tree_bindings = {
    {key = {"l", "<CR>", "o"}, cb = tree_cb("edit")},
    {key = "h", cb = tree_cb("close_node")},
    {key = "v", cb = tree_cb("vsplit")}
}

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
