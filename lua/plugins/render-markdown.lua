return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        render_modes = { "n", "c" },
        anti_conceal = { enabled = false },
        overrides = {
            buftype = {
                -- LSP floats are buftype=nofile, filetype=markdown, so they land
                -- here. `core/lsp.lua` pads float contents by one space to get
                -- horizontal padding, but it skips ``` fence lines (padding them
                -- would break code block detection) -- and render-markdown draws
                -- the language label in place of that fence, so the label ended
                -- up flush left while the code under it was indented by one.
                -- `language_pad` puts it back in line. Scoped to nofile so real
                -- markdown buffers, which get no content padding, stay aligned.
                nofile = { code = { language_pad = 1 } },
            },
        },
    },
}
