return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "echasnovski/mini.icons" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count
        local hl = require("util.hl")

        -- Colours come from standard highlight groups, not hex codes, so the bar
        -- follows any colorscheme. A function theme is re-run by lualine's own
        -- ColorScheme / OptionSet background autocmds (`lualine.lua` `setup_theme`).
        local function my_lualine_theme()
            local bg = hl.get("Normal", "bg")
            local fg = hl.get("Normal", "fg")
            local badge = function(accent)
                return {
                    a = { fg = bg, bg = accent, gui = "bold" },
                    b = { fg = fg, bg = bg },
                    c = { fg = fg, bg = bg },
                }
            end
            local dim = hl.get("StatusLine", "fg")
            return {
                normal = badge(hl.blend(fg, bg, 0.5)),
                replace = badge(hl.get("DiagnosticError", "fg")),
                visual = badge(hl.get("Statement", "fg")),
                insert = badge(fg),
                -- lualine renders select mode with the `visual` theme and has no
                -- `select` key of its own; these three exist for the statusline
                -- (command, terminal) and for modicator, which reads `a.bg` per mode
                -- and otherwise falls back to `normal`'s grey for all three.
                command = badge(hl.get("DiagnosticWarn", "fg")),
                terminal = badge(hl.get("String", "fg")),
                select = badge(hl.get("Constant", "fg")),
                inactive = {
                    a = { fg = dim, bg = bg, gui = "bold" },
                    b = { fg = dim, bg = bg },
                    c = { fg = dim, bg = bg },
                },
            }
        end

        -- Component colours as functions so they too re-read after a theme change.
        local function fg_of(group)
            return function()
                return { fg = hl.get(group, "fg") }
            end
        end

        local mode = {
            "mode",
            fmt = function(str)
                -- return ' '
                -- displays only the first character of the mode
                return " " .. str
            end,
        }

        local diff = {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
            -- cond = hide_in_width,
        }

        local filename = {
            "filename",
            file_status = true,
            path = 1,
            -- these buffer names are just URIs (nvim:// job + command, fugitive:///.git//)
            cond = function()
                return vim.bo.filetype ~= "sidekick_terminal" and vim.bo.filetype ~= "fugitive"
            end,
        }

        local branch = { "branch", icon = { "", color = fg_of("Special") }, "|" }

        lualine.setup({
            icons_enabled = true,
            options = {
                theme = my_lualine_theme,
                component_separators = { left = "|", right = "" },
                section_separators = { left = "|", right = "" },
                disabled_filetypes = {
                    statusline = { "alpha", "dashboard", "snacks_dashboard", "NvimTree", "" },
                    winbar = { "alpha", "dashboard", "snacks_dashboard", "NvimTree", "" },
                },
                -- pipetable's cell editor float (see `plugins/pipetable.lua`): keep
                -- the markdown window's statusline while typing in a cell.
                ignore_focus = { "pipetable_cell" },
            },
            sections = {
                lualine_a = { mode },
                lualine_b = { branch },
                lualine_c = { diff, filename },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = fg_of("DiagnosticWarn"),
                    },
                    {
                        function()
                            return "noeol"
                        end,
                        cond = function()
                            return not vim.bo.endofline and vim.bo.buftype == ""
                        end,
                        color = fg_of("DiagnosticWarn"),
                    },
                    { "filetype" },
                },
            },
        })
    end,
}
