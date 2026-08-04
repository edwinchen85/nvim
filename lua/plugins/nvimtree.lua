return {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeClose" },
    dependencies = {
        -- lives here, not on lspconfig: its only job is subscribing to nvim-tree's
        -- file events. As an lspconfig dep it required nvim-tree.api at startup,
        -- which tripped lazy.nvim's auto_load and defeated the cmd trigger above.
        { "antosha417/nvim-lsp-file-operations", config = true },
    },
    init = function()
        -- First open otherwise blocks ~370ms: nvim-tree runs three synchronous git
        -- subprocesses (rev-parse, config status.showUntrackedFiles, status
        -- --ignored) and every exec() on this machine costs ~40ms because
        -- CrowdStrike Falcon hooks it. The result is cached per project -- which is
        -- why only the first open is slow -- so warm that cache while idle.
        local warmed = false
        local function warm()
            if warmed then
                return
            end
            warmed = true
            pcall(function()
                require("nvim-tree.git").load_project(vim.uv.cwd())
            end)
        end

        vim.api.nvim_create_autocmd("CursorHold", {
            once = true,
            desc = "Warm nvim-tree's git project cache off the keypress path",
            callback = warm,
        })

        -- CursorHold never fires until the first keypress, so it misses the case of
        -- launching nvim and going straight for <leader>e. Race it with a timer,
        -- skipping if we're mid-insert -- CursorHold covers that once typing pauses.
        vim.defer_fn(function()
            if vim.fn.mode() == "n" then
                warm()
            end
        end, 1000)
    end,
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
            hijack_directories = { enable = false },
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
                ignore_list = { "fugitive", "fugitiveblame", "git" },
            },
            filters = {
                dotfiles = true,
                git_ignored = true,
                custom = { ".git/", ".cache", "tags", ".DS_Store" },
                exclude = { ".env", ".env.*", ".dotfiles/", ".gitlab*" },
            },
            git = {
                enable = true,
                -- upstream default (was 200). Measured p90 for a bare `git rev-parse`
                -- here is ~152ms under load, so a 200ms cap had almost no headroom --
                -- and 5 timeouts make nvim-tree disable git integration for the session.
                timeout = 400,
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
                            unstaged = "",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
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
