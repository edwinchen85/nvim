local wilder = require("wilder")

wilder.setup({
    modes = { ":" },
    next_key = "<Tab>",
    previous_key = "<S-Tab>",
    accept_key = "<Space>",
    reject_key = "<Esc>",
})

wilder.set_option(
    "renderer",
    wilder.popupmenu_renderer({
        -- highlighter applies highlighting to the candidates
        highlighter = wilder.basic_highlighter(),
        highlights = {
            accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#f4468f" } }),
        },
        left = { " ", wilder.popupmenu_devicons() },
        right = { " ", wilder.popupmenu_scrollbar() },
    })
)
