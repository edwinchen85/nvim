local M = {
    "goolord/alpha-nvim",
    event = "VimEnter",
}

function M.config()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
        [[                                                                           ]],
        [[                                                                         ]],
        [[         ████ ██████           █████      ██                       ]],
        [[        ███████████             █████                               ]],
        [[        █████████ ███████████████████ ███   ███████████     ]],
        [[       █████████  ███    █████████████ █████ ██████████████     ]],
        [[      █████████ ██████████ █████████ █████ █████ ████ █████     ]],
        [[    ███████████ ███    ███ █████████ █████ █████ ████ █████    ]],
        [[   ██████  █████████████████████ ████ █████ █████ ████ ██████   ]],
        [[                                                                           ]],
    }

    dashboard.section.buttons.val = {
        dashboard.button("r", "  Recent files", "<cmd>lua Snacks.picker.recent()<CR>"),
        dashboard.button(
            "f",
            "󰱼  Find file",
            "<cmd>lua Snacks.picker.files({ finder = 'files', format = 'file', hidden = true, show_empty = true, supports_live = true })<CR>"
        ),
        dashboard.button("t", "  Find text", "<cmd>lua Snacks.picker.grep()<CR>"),
        dashboard.button("c", "  Configuration", "<cmd>e ~/.config/nvim/init.lua<CR>"),
        dashboard.button("q", "  Quit dashboard", "<cmd>Alpha<CR>"),
    }

    dashboard.section.footer.val = ""

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true
    require("alpha").setup(dashboard.opts)
end

return M
