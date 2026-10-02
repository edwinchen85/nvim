return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "echasnovski/mini.icons", "folke/tokyonight.nvim" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count
        local tokyonight_colors = require("tokyonight.colors").setup()

        local colors = {
            color0 = "#092236",
            color1 = "#ff5874",
            color2 = "#c3ccdc",
            color3 = tokyonight_colors.bg,
            color6 = "#a1aab8",
            color7 = "#828697",
            color8 = "#ae81ff",
            color9 = tokyonight_colors.yellow,
            color10 = tokyonight_colors.green,
            color11 = tokyonight_colors.orange,
        }
        local my_lualine_theme = {
            replace = {
                a = { fg = colors.color0, bg = colors.color1, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            inactive = {
                a = { fg = colors.color6, bg = colors.color3, gui = "bold" },
                b = { fg = colors.color6, bg = colors.color3 },
                c = { fg = colors.color6, bg = colors.color3 },
            },
            normal = {
                a = { fg = colors.color0, bg = colors.color7, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
                c = { fg = colors.color2, bg = colors.color3 },
            },
            visual = {
                a = { fg = colors.color0, bg = colors.color8, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            insert = {
                a = { fg = colors.color0, bg = colors.color2, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            -- lualine renders select mode with the `visual` theme and has no
            -- `select` key of its own; these three exist for the statusline
            -- (command, terminal) and for modicator, which reads `a.bg` per mode
            -- and otherwise falls back to `normal`'s grey for all three.
            command = {
                a = { fg = colors.color0, bg = colors.color9, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            terminal = {
                a = { fg = colors.color0, bg = colors.color10, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            select = {
                a = { fg = colors.color0, bg = colors.color11, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
        }

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

        local branch = { "branch", icon = { "", color = { fg = "#A6D4DE" } }, "|" }

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
            },
            sections = {
                lualine_a = { mode },
                lualine_b = { branch },
                lualine_c = { diff, filename },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        function()
                            return "noeol"
                        end,
                        cond = function()
                            return not vim.bo.endofline and vim.bo.buftype == ""
                        end,
                        color = { fg = "#ff9e64" },
                    },
                    { "filetype" },
                },
            },
        })
    end,
}
