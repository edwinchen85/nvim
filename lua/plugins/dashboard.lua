vim.g.dashboard_custom_header = {
"",
"",
"",
"",
"",
[[                               __                ]],
[[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
[[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
[[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
[[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
[[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
"",
"",
}

vim.g.dashboard_default_executive = 'telescope'

vim.g.dashboard_custom_section = {
    a = {description = {'         Recent File        '}, command = 'Telescope oldfiles'},
    b = {description = {'         Find File          '}, command = 'Telescope find_files'},
    c = {description = {'         Find Word          '}, command = 'Telescope live_grep'},
    d = {description = {'         New File           '}, command = ":ene!"},
    e = {description = {'         Settings           '}, command = ':e ~/.config/nvim/init.lua'}
}

vim.g.dashboard_custom_footer = {""}
