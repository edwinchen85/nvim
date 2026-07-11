return {
    "bkad/camelcasemotion",
    keys = { ",w", ",b", ",e", ",ge" },
    config = function()
        vim.cmd([[
            map <silent> ,w <Plug>CamelCaseMotion_w
            map <silent> ,b <Plug>CamelCaseMotion_b
            map <silent> ,e <Plug>CamelCaseMotion_e
            map <silent> ,ge <Plug>CamelCaseMotion_ge
        ]])
    end,
}
