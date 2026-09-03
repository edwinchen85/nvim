return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = false },
        bufdelete = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        image = {
            enabled = true,
            force = true, -- try displaying the image, even if the terminal does not support it
            doc = {
                -- Personally I set this to false, I don't want to render all the
                -- images in the file, only when I hover over them
                -- render the image inline in the buffer
                -- if your env doesn't support unicode placeholders, this will be disabled
                -- takes precedence over `opts.float` on supported terminals
                inline = vim.g.neovim_mode == "skitty" and true or false,
                -- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
                -- render the image in a floating window
                -- only used if `opts.inline` is disabled
                float = true,
                -- Sets the size of the image
                -- max_width = 60,
                max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
                max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
                -- max_width = vim.g.neovim_mode == "skitty" and 5 or 60,
                -- max_height = vim.g.neovim_mode == "skitty" and 2.5 or 30,
                -- max_height = 30,
                -- Apparently, all the images that you preview in neovim are converted
                -- to .png and they're cached, original image remains the same, but
                -- the preview you see is a png converted version of that image
                --
                -- Where are the cached images stored?
                -- This path is found in the docs
                -- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
                -- For me returns `~/.cache/neobean/snacks/image`
                -- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
            },
        },
        gitbrowse = { enabled = false },
        indent = { enabled = false },
        -- took over vim.ui.input from dressing.nvim, which was removed
        input = { enabled = true },
        picker = { enabled = false }, -- fff.lua provides pickers and vim.ui.select
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact", -- "compact", "fancy", "minimal"
            top_down = true,
        },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
    },
}
