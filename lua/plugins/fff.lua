-- Rust-backed file finder + live grep, plus fff-plus for buffers / lines /
-- git-status pickers built on the same UI. Remaining snacks pickers (help,
-- keymaps, qflist, lsp, git log/branches, ...) have no fff equivalent and stay.
return {
    {
        "dmtrKovalenko/fff",
        build = function()
            require("fff.download").download_or_build_binary()
        end,
        lazy = false, -- the plugin lazy-initialises itself
        opts = {
            prompt = "❯ ",
            lazy_sync = true,
            wrap_around = false, -- matches snacks `cycle = false`
            -- Mirrors the snacks "ivy" layout: bottom-anchored, half height, preview right.
            layout = {
                height = 0.5,
                width = 1,
                anchor = "bottom",
                prompt_position = "top",
                preview_position = "right",
                preview_size = 0.5,
                show_path_first = false, -- filename first, like snacks `filename_first = true`
            },
            keymaps = {
                close = "<Esc>",
                select = "<CR>",
                move_up = { "<Up>", "<C-k>", "<C-p>" },
                move_down = { "<Down>", "<C-j>", "<C-n>" },
                preview_scroll_up = "<C-u>",
                preview_scroll_down = "<C-d>",
                toggle_select = "<Tab>",
                send_to_quickfix = "<C-q>",
                focus_list = "<leader>l",
                focus_preview = "<leader>p",
            },
        },
        keys = {
            {
                "<leader>ff",
                function()
                    require("fff").find_files()
                end,
                desc = "Files",
            },
            {
                "<leader>fs",
                function()
                    require("fff").live_grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>fa",
                function()
                    require("fff").live_grep_under_cursor()
                end,
                mode = { "n", "x" },
                desc = "Cursor",
            },
        },
    },
    {
        "vinitkumar/fff-plus.nvim",
        dependencies = { "dmtrKovalenko/fff" },
        lazy = false, -- must install the vim.ui.select override at startup
        -- Inherits fff's keymaps/layout via fff.conf, so the <C-j>/<C-k> above apply here too.
        opts = {},
        config = function(_, opts)
            require("fff_plus").setup(opts)

            -- vim.ui.select on fff-plus' shared picker (sidekick's tool chooser,
            -- code-action menus, ...). Replaces the snacks ui_select backend.
            vim.ui.select = function(items, sopts, on_choice)
                sopts = sopts or {}
                local fmt = sopts.format_item or tostring
                local picked = false
                return require("fff_plus.picker")
                    .create({
                        name = "ui_select",
                        title = (sopts.prompt or "Select"):gsub(":?%s*$", ""),
                        items = function()
                            local out = {}
                            for i, item in ipairs(items) do
                                out[i] = { idx = i, value = item, label = fmt(item) }
                            end
                            return out
                        end,
                        key = function(it)
                            return tostring(it.idx)
                        end,
                        text = function(it)
                            return it.label
                        end,
                        format = function(it)
                            return { text = ("%d. %s"):format(it.idx, it.label), match_offset = #tostring(it.idx) + 2 }
                        end,
                        confirm = function(_, it)
                            picked = true
                            return function()
                                on_choice(it.value, it.idx)
                            end
                        end,
                        on_close = function()
                            if not picked then
                                vim.schedule(on_choice)
                            end
                        end,
                    }, {
                        prompt = "❯ ",
                        preview = { enabled = false },
                        layout = { height = math.min(0.5, (#items + 4) / vim.o.lines) },
                        keymaps = { select_split = false, select_vsplit = false, select_tab = false },
                    })
                    :open()
            end
            -- fff-plus centres its frame and ignores `layout.anchor`; pin it to the
            -- bottom edge so it matches fff's ivy placement. It also lays out
            -- list + preview as `width + 2` (the shared border column is counted
            -- twice), so at width = 1 the preview spills off-screen and nvim shoves
            -- it left under the list border -- clamp the frame to leave room.
            -- SIMPLIFIED: only handles anchor = "bottom"; extend if another anchor is used.
            local layout = require("fff_plus.layout")
            local frame = layout.frame
            layout.frame = function(columns, lines, cfg, fullscreen)
                local f = frame(columns, lines, cfg, fullscreen)
                if not fullscreen and cfg.anchor == "bottom" then
                    f.width = math.min(f.width, columns - 2)
                    f.col = 0
                    f.row = lines - f.height - vim.o.cmdheight - 2 -- statusline + bottom border
                end
                return f
            end
        end,
        keys = {
            {
                "<leader>fb",
                function()
                    require("fff_plus").buffers()
                end,
                desc = "Buffers", -- <C-d> deletes the buffer under cursor
            },
            {
                "<leader>fl",
                function()
                    require("fff_plus").lines()
                end,
                desc = "Buffer Lines",
            },
            {
                -- buffers + oldfiles + indexed files, deduped and frecency-ranked.
                "<leader>fr",
                function()
                    require("fff_plus").smart()
                end,
                desc = "Recent",
            },
        },
    },
}
