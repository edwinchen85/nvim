local function relpath(abs)
    local ok, rel = pcall(vim.fs.relpath, vim.uv.cwd(), abs)
    return (ok and rel and rel ~= "" and rel ~= ".") and rel or abs
end

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

        -- `:mksession` (nvim 0.12's `:restart`) saves the tree window as `enew | file
        -- NvimTree_1`, so it comes back as an empty pane. Here, not in config: the
        -- plugin is cmd-loaded and may not be loaded when the session restores.
        vim.api.nvim_create_autocmd("SessionLoadPost", {
            desc = "Replace restored empty nvim-tree panes with a real tree",
            callback = function()
                local stale, tabs = {}, {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local name = vim.fs.basename(vim.api.nvim_buf_get_name(buf))
                    if name:match("^NvimTree_%d+$") and vim.bo[buf].filetype ~= "NvimTree" then
                        stale[buf] = true
                        tabs[vim.api.nvim_win_get_tabpage(win)] = true
                    end
                end
                if next(stale) == nil then
                    return
                end
                for buf in pairs(stale) do
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end
                local cur_tab, cur_win = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_win()
                for tab in pairs(tabs) do
                    if vim.api.nvim_tabpage_is_valid(tab) then
                        vim.api.nvim_set_current_tabpage(tab)
                        require("nvim-tree.api").tree.open()
                    end
                end
                vim.api.nvim_set_current_tabpage(cur_tab)
                if vim.api.nvim_win_is_valid(cur_win) then
                    vim.api.nvim_set_current_win(cur_win)
                end
            end,
        })
    end,
    config = function()
        -- With laststatus=3, nvim draws each corner where separators meet (┴, ├) with
        -- the highlight of the window drawn last, i.e. the one right of the tree. So a
        -- grey tick in the editor's bg pokes into the tree's otherwise invisible
        -- separator. No per-cell highlight exists, so cover the tree's separator
        -- column with a blank float in the tree's bg. The separator row under the tree
        -- and its corner are drawn as upper half blocks in NvimTreeWinSeparator (see
        -- plugins/tokyonight.lua), so the tree's bg ends level with the grey line.
        -- SIMPLIFIED: one cover for the current tab, rebuilt on TabEnter; per-tab covers if trees in several tabs matter
        local cover
        local ns = vim.api.nvim_create_namespace("nvim_tree_sep_cover")
        local function update_cover()
            local tree
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
                    tree = win
                end
            end
            if
                cover
                and vim.api.nvim_win_is_valid(cover)
                and vim.api.nvim_win_get_tabpage(cover) ~= vim.api.nvim_get_current_tabpage()
            then
                vim.api.nvim_win_close(cover, true)
            end
            local row, col, height, corner
            if tree and vim.api.nvim_win_get_config(tree).relative == "" then
                local pos = vim.api.nvim_win_get_position(tree)
                row, col = pos[1], pos[2] + vim.api.nvim_win_get_width(tree)
                height = vim.api.nvim_win_get_height(tree)
                -- below the tree is another window's row, not the global statusline
                corner = row + height < vim.o.lines - vim.o.cmdheight - 1
                if corner then
                    height = height + 1
                    if not vim.wo[tree].fillchars:find("horiz:▀", 1, true) then
                        vim.wo[tree].fillchars = vim.go.fillchars .. ",horiz:▀"
                    end
                end
            end
            if not row or col >= vim.o.columns then
                if cover and vim.api.nvim_win_is_valid(cover) then
                    vim.api.nvim_win_close(cover, true)
                end
                cover = nil
                return
            end
            local cfg = {
                relative = "editor",
                row = row,
                col = col,
                width = 1,
                height = height,
                focusable = false,
                mouse = false, -- clicks/drags reach the separator underneath
                zindex = 1,
                style = "minimal",
                border = "none", -- overrides the global winborder
                noautocmd = true,
            }
            if cover and vim.api.nvim_win_is_valid(cover) then
                cfg.noautocmd = nil
                vim.api.nvim_win_set_config(cover, cfg)
            else
                cover = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, cfg)
                vim.wo[cover].winhighlight = "Normal:NvimTreeNormal,EndOfBuffer:NvimTreeEndOfBuffer"
            end
            local buf = vim.api.nvim_win_get_buf(cover)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn["repeat"]({ " " }, height))
            if corner then
                vim.api.nvim_buf_set_lines(buf, -2, -1, false, { "▀" })
                vim.api.nvim_buf_set_extmark(
                    buf,
                    ns,
                    height - 1,
                    0,
                    { end_col = #"▀", hl_group = "NvimTreeWinSeparator" }
                )
            end
        end
        vim.api.nvim_create_autocmd({ "WinResized", "WinNew", "WinClosed", "BufWinEnter", "VimResized", "TabEnter" }, {
            desc = "Keep nvim-tree's separator cover in place",
            callback = function()
                vim.schedule(update_cover)
            end,
        })

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

            -- send the file under cursor to the sidekick AI panel as an @mention,
            -- overriding the buffer-based <leader>af (nvim-tree's buffer isn't a real file)
            vim.keymap.set("n", "<leader>af", function()
                local node = api.tree.get_node_under_cursor()
                if not node or node.type ~= "file" then
                    return
                end
                require("util.sidekick").send_no_newline({
                    msg = "@" .. relpath(node.absolute_path),
                    submit = false,
                })
            end, opts("Send File to Sidekick"))
        end

        require("nvim-tree").setup({
            disable_netrw = false,
            -- netrw is never loaded (config/options.lua), so there is no FileExplorer
            -- augroup to clear; `true` only ran `silent! autocmd! FileExplorer *`, which
            -- left a stale E216 in v:errmsg.
            hijack_netrw = false,
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
                -- fit the longest visible line, capped at the old fixed 40 columns
                width = { min = 20, max = 40 },
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
