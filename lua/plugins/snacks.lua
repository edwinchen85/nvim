-- snacks.image renders ```mermaid blocks with `mmdc`, whose puppeteer wants its
-- own Chrome download; npm's allow-scripts blocks that, so point it at the
-- installed Chrome instead. An explicit env var still wins.
local chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if not vim.env.PUPPETEER_EXECUTABLE_PATH and vim.uv.fs_stat(chrome) then
    vim.env.PUPPETEER_EXECUTABLE_PATH = chrome
end

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
    config = function(_, opts)
        -- Image previews only in prose files. snacks attaches to every language with a
        -- queries/<lang>/images.scm (snacks/image/init.lua `M.langs`), which includes
        -- html, css, js/tsx, vue and svelte: an `<img src>` under the cursor there opens a float.
        local docs = { markdown = true, markdown_inline = true, norg = true, latex = true, typst = true }
        local image = require("snacks.image")
        local langs = image.langs
        image.langs = function(...)
            return vim.tbl_filter(function(lang)
                return docs[lang]
            end, langs(...))
        end
        -- Herdr reports the pane's rows/cols but 0 pixels (TIOCGWINSZ xpixel/ypixel), and
        -- snacks only falls back to its 9x18 guess when rows/cols are 0. A 0-pixel cell
        -- makes every image `nan` cells wide, so nothing is drawn: use the guess then too.
        local terminal = require("snacks.image.terminal")
        local size = terminal.size
        terminal.size = function()
            local s = size()
            if s.cell_width > 0 and s.cell_height > 0 then
                return s
            end
            local dw, dh = 9, 18 -- snacks' own fallback cell size
            return {
                width = s.columns * dw,
                height = s.rows * dh,
                columns = s.columns,
                rows = s.rows,
                cell_width = dw,
                cell_height = dh,
                scale = dw / 8,
            }
        end
        -- Under Herdr, send the image bytes (kitty `t=d`, snacks' remote path) instead of
        -- a file path for the terminal to read (`t=f`), which Herdr doesn't display.
        if vim.env.HC_TERMINAL_ID then
            local env = terminal.env
            terminal.env = function()
                local e = env()
                e.remote = true
                return e
            end
        end
        require("snacks").setup(opts)
    end,
}
