require("onenord").setup({
    theme = nil, -- "dark" or "light". Alternatively, remove the option and set vim.o.background instead
    borders = true, -- Split window borders
    fade_nc = true, -- Fade non-current windows, making them more distinguishable
    -- Style that is applied to various groups: see `highlight-args` for options
    styles = {
        comments = "NONE",
        strings = "NONE",
        keywords = "NONE",
        functions = "NONE",
        variables = "NONE",
        diagnostics = "undercurl",
    },
    disable = {
        background = false, -- Disable setting the background color
        cursorline = false, -- Disable the cursorline
        eob_lines = true, -- Hide the end-of-buffer lines
    },
    -- Inverse highlight for different groups
    inverse = {
        match_paren = false,
    },
    custom_highlights = {}, -- Overwrite default highlight groups
    custom_colors = {}, -- Overwrite default colors
})
