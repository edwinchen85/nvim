return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        filetypes = { "*", "!gitcommit", "!fugitive", "!NvimTree" },
        user_commands = true,
        options = {
            parsers = {
                css = true,
                css_fn = true,
                tailwind = {
                    enable = true,
                    lsp = true,
                },
            },
            display = {
                mode = "virtualtext",
                virtualtext = {
                    char = "■",
                    position = "inline",
                },
            },
        },
    },
}
