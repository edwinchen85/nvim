local wilder = require("wilder")

wilder.setup({
    modes = { ":" },
    next_key = "<Tab>",
    previous_key = "<S-Tab>",
    accept_key = "<Space>",
    reject_key = "<Esc>",
    enable_cmdline_enter = 0,
})

wilder.set_option(
    "renderer",
    wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
        highlighter = wilder.basic_highlighter(),
        highlights = {
            accent = wilder.make_hl(
                "WilderAccent",
                "Pmenu",
                { { a = 1 }, { a = 1 }, { foreground = "#f4468f", background = "None" } }
            ),
            border = "FloatBorder", -- highlight to use for the border
        },
        -- 'single', 'double', 'rounded' or 'solid'
        -- can also be a list of 8 characters, see :h wilder#popupmenu_border_theme() for more details
        border = "rounded",
    }))
)
