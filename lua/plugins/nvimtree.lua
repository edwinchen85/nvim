return {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeClose" },
    config = function()
        local function on_attach(bufnr)
            local api = require("nvim-tree.api")

            local function opts(desc)
                return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            -- default mappings
            api.map.on_attach.default(bufnr)

            -- custom overrides
            vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
            vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
        end

        require("nvim-tree").setup({
            disable_netrw = false,
            hijack_netrw = true,
            hijack_cursor = false,
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            actions = {
                open_file = {
                    quit_on_open = false,
                },
            },
            diagnostics = {
                enable = false,
                icons = {
                    hint = "",
                    info = "",
                    warning = "",
                    error = "",
                },
            },
            update_focused_file = {
                enable = true,
                update_root = { enable = false },
            },
            filters = {
                dotfiles = true,
                git_ignored = true,
                custom = { ".git/", ".cache", "tags", ".DS_Store" },
                exclude = { ".env", ".env.*" },
            },
            git = {
                enable = true,
                timeout = 200,
            },
            on_attach = on_attach,
            view = {
                width = 40,
                side = "left",
            },
            renderer = {
                indent_markers = {
                    enable = true,
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        none = "  ",
                    },
                },
                icons = {
                    web_devicons = {
                        file = { enable = true, color = true },
                        folder = { enable = false },
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        git = {
                            unstaged = "",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                        },
                    },
                },
                group_empty = true,
                special_files = {},
            },
        })
    end,
}
