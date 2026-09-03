local M = {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = false,
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
        dashboard.button("r", "  Recent files", "<cmd>lua require('fff_plus').smart()<CR>"),
        dashboard.button("f", "󰱼  Find file", "<cmd>lua require('fff').find_files()<CR>"),
        dashboard.button("t", "  Find text", "<cmd>lua require('fff').live_grep()<CR>"),
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
