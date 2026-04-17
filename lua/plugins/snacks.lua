return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = false },
        bufdelete = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        image = {
            enabled = false,
            force = true, -- try displaying the image, even if the terminal does not support it
            doc = {
                -- Personally I set this to false, I don't want to render all the
                -- images in the file, only when I hover over them
                -- render the image inline in the buffer
                -- if your env doesn't support unicode placeholders, this will be disabled
                -- takes precedence over `opts.float` on supported terminals
                inline = vim.g.neovim_mode == "skitty" and true or false,
                -- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
                -- render the image in a floating window
                -- only used if `opts.inline` is disabled
                float = true,
                -- Sets the size of the image
                -- max_width = 60,
                max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
                max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
                -- max_width = vim.g.neovim_mode == "skitty" and 5 or 60,
                -- max_height = vim.g.neovim_mode == "skitty" and 2.5 or 30,
                -- max_height = 30,
                -- Apparently, all the images that you preview in neovim are converted
                -- to .png and they're cached, original image remains the same, but
                -- the preview you see is a png converted version of that image
                --
                -- Where are the cached images stored?
                -- This path is found in the docs
                -- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
                -- For me returns `~/.cache/neobean/snacks/image`
                -- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
            },
        },
        gitbrowse = { enabled = false },
        indent = { enabled = false },
        input = { enabled = false },
        picker = {
            enabled = true,

            transform = function(item)
                if not item.file then
                    return item
                end
                return item
            end,

            -- In case you want to make sure that the score manipulation above works
            -- or if you want to check the score of each file
            debug = {
                scores = false, -- show scores in the list
            },
            -- I like the "ivy" layout, so I set it as the default globaly, you can
            -- still override it in different keymaps
            layout = {
                preset = "ivy",
                -- When reaching the bottom of the results in the picker, I don't want
                -- it to cycle and go back to the top
                cycle = false,
            },
            layouts = {
                -- I wanted to modify the ivy layout height and preview pane width,
                -- this is the only way I was able to do it
                -- NOTE: I don't think this is the right way as I'm declaring all the
                -- other values below, if you know a better way, let me know
                --
                -- Then call this layout in the keymaps above
                -- got example from here
                -- https://github.com/folke/snacks.nvim/discussions/468
                ivy = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        row = -1,
                        width = 0,
                        height = 0.5,
                        border = "top",
                        title = " {title} {live} {flags}",
                        title_pos = "left",
                        { win = "input", height = 1, border = "bottom" },
                        {
                            box = "horizontal",
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                        },
                    },
                },
                -- I wanted to modify the layout width
                --
                vertical = {
                    layout = {
                        backdrop = false,
                        width = 0.8,
                        min_width = 80,
                        height = 0.8,
                        min_height = 30,
                        box = "vertical",
                        border = "rounded",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "input", height = 1, border = "bottom" },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
                    },
                },
            },
            matcher = {
                frecency = true,
            },
            win = {
                input = {
                    keys = {
                        -- to close the picker on ESC instead of going to normal mode,
                        -- add the following keymap to your config
                        -- ["<Esc>"] = { "close", mode = { "n", "i" } },
                        -- I'm used to scrolling like this in LazyGit
                        -- ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
                        -- ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
                        -- ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
                        -- ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
                    },
                },
            },
            formatters = {
                file = {
                    filename_first = true, -- display filename before the file path
                    truncate = 80,
                },
            },
        },
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact", -- "compact", "fancy", "minimal"
            top_down = true,
        },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
    },
    keys = {
        {
            "<leader>fk",
            function()
                Snacks.picker.keymaps()
            end,
            desc = "Keymaps",
        },
        {
            "<leader>fh",
            function()
                Snacks.picker.help()
            end,
            desc = "Help Pages",
        },
        {
            "<leader>fm",
            function()
                Snacks.picker.man()
            end,
            desc = "Man Pages",
        },
        {
            "<leader>fa",
            function()
                Snacks.picker.grep_word({ hidden = true })
            end,
            desc = "Cursor",
            mode = { "n", "x" },
        },
        {
            "<leader>fq",
            function()
                Snacks.picker.qflist()
            end,
            desc = "Quickfix List",
        },
        {
            "<leader>fc",
            function()
                Snacks.picker.command_history()
            end,
            desc = "Command History",
        },
        {
            "<leader>fC",
            function()
                Snacks.picker.commands()
            end,
            desc = "Commands",
        },
        {
            "<leader>fs",
            function()
                Snacks.picker.grep({ hidden = true })
            end,
            desc = "Grep",
        },
        {
            "<leader>fp",
            function()
                Snacks.picker.projects()
            end,
            desc = "Projects",
        },
        {
            "<leader>fr",
            function()
                Snacks.picker.recent()
            end,
            desc = "Recent",
        },
        -- File picker
        {
            "<leader>ff",
            function()
                Snacks.picker.files({
                    finder = "files",
                    format = "file",
                    show_empty = true,
                    hidden = true,
                    supports_live = true,
                    exclude_dirs = { ".git" },
                    -- exclude = { "yarn.lock", "package-lock.json" },
                    -- In case you want to override the layout for this keymap
                    -- layout = "vscode",
                })
            end,
            desc = "Files",
        },
        -- Buffers picker
        {
            "<leader>fb",
            function()
                Snacks.picker.buffers({
                    -- I always want my buffers picker to start in normal mode
                    -- on_show = function()
                    --     vim.cmd.stopinsert()
                    -- end,
                    finder = "buffers",
                    format = "buffer",
                    hidden = false,
                    unloaded = true,
                    current = true,
                    sort_lastused = true,
                    win = {
                        input = {
                            keys = {
                                ["d"] = { "bufdelete", mode = { "n" } },
                                ["<c-d>"] = { "bufdelete", mode = { "i" } },
                            },
                        },
                        list = { keys = { ["d"] = "bufdelete" } },
                    },
                })
            end,
            desc = "Buffers",
        },
        -- Buffer lines
        {
            "<leader>fl",
            function()
                Snacks.picker.lines({
                    finder = "lines",
                    format = "lines",
                    layout = {
                        preview = "main",
                        preset = "ivy",
                    },
                    jump = { match = true },
                    -- allow any window to be used as the main window
                    main = { current = true },
                    ---@param picker snacks.Picker
                    on_show = function(picker)
                        local cursor = vim.api.nvim_win_get_cursor(picker.main)
                        local info = vim.api.nvim_win_call(picker.main, vim.fn.winsaveview)
                        picker.list:view(cursor[1], info.topline)
                        picker:show_preview()
                    end,
                    sort = { fields = { "score:desc", "idx" } },
                })
            end,
            desc = "Buffer Lines",
        },
        -- Clip History
        {
            "<leader>fv",
            function()
                Snacks.picker.cliphist({
                    finder = "system_cliphist",
                    format = "text",
                    preview = "preview",
                    confirm = { "copy", "close" },
                })
            end,
            desc = "Clipboard History",
        },
        -- LSP
        {
            "gd",
            function()
                Snacks.picker.lsp_definitions()
            end,
            desc = "Goto Definition",
        },
    },
}
