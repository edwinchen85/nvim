-- Shows `colorcolumn` only while a line actually overruns it, so the ruler is
-- absent until it has something to say. `options.lua` keeps the global
-- `colorcolumn = ""`; this plugin drives it per window.
return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        -- prettier's default printWidth, which formatting.lua relies on for
        -- ts/js/vue/css/json -- none of those projects ship a printWidth override.
        colorcolumn = "80",
        custom_colorcolumn = {
            lua = "120", -- stylua.toml column_width
        },
        -- Default list plus the UI buffers this config opens. Filetypes with
        -- `wrap` on (markdown, text) stay out by default: they soft-wrap, so a
        -- hard column is noise.
        disabled_filetypes = {
            "help",
            "text",
            "markdown",
            "alpha",
            "NvimTree",
            "lazy",
            "mason",
            "checkhealth",
            "toggleterm",
            "fugitive",
            "git",
            "zdiff",
            "qf",
        },
        -- "file" (the default) re-scans every line of the buffer on each
        -- CursorMoved / CursorMovedI. "window" checks only the visible range --
        -- same result on screen, bounded by window height instead of file length.
        scope = "window",
    },
}
