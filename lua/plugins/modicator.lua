return {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lualine/lualine.nvim" },
    -- modicator's lualine integration only reads a *table* theme (or a theme
    -- name); `my_lualine_theme` (lualine.lua) is a function, so it finds no
    -- colours and CursorLineNr never changes. Define the `<Mode>Mode` groups
    -- ourselves from that theme's `a.bg`; modicator skips groups that exist.
    config = function()
        local modes = {
            Normal = "normal",
            Insert = "insert",
            Visual = "visual",
            Select = "select",
            Replace = "replace",
            Command = "command",
            Terminal = "terminal",
            TerminalNormal = "normal",
        }

        local function define_mode_groups()
            local theme = require("lualine").get_config().options.theme
            if type(theme) == "function" then
                theme = theme()
            end
            for name, key in pairs(modes) do
                local a = theme[key] and theme[key].a
                if a then
                    vim.api.nvim_set_hl(0, name .. "Mode", { fg = a.bg })
                end
            end
        end

        define_mode_groups()
        local modicator = require("modicator")
        modicator.setup()

        -- Registered after modicator's own ColorScheme autocmd, so redefine and
        -- re-apply the current mode's colour.
        vim.api.nvim_create_autocmd({ "ColorScheme", "OptionSet" }, {
            group = vim.api.nvim_create_augroup("ModicatorThemeColours", {}),
            pattern = { "*", "background" },
            callback = function()
                define_mode_groups()
                modicator.set_cursor_line_highlight(modicator.hl_name_from_mode(vim.api.nvim_get_mode().mode))
            end,
        })
    end,
}
