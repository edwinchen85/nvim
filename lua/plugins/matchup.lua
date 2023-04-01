local u = require("config.utils")

vim.g.matchup_matchparen_offscreen = { method = "popup" }
vim.g.matchup_surround_enabled = true
vim.g.matchup_matchparen_deferred = true

u.xmap("i<Tab>", "<Plug>(matchup-i%)", { remap = true })
u.omap("i<Tab>", "<Plug>(matchup-i%)", { remap = true })
u.xmap("a<Tab>", "<Plug>(matchup-a%)", { remap = true })
u.omap("a<Tab>", "<Plug>(matchup-a%)", { remap = true })
