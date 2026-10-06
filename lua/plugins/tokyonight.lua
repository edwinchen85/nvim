return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local function highlight_treesitter_context(hl, c)
            hl.TreesitterContext = {
                bg = c.bg,
                fg = "NONE",
            }
            hl.TreesitterContextBottom = {
                underline = true,
                sp = c.comment,
            }
        end

        require("tokyonight").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            style = "night", -- The theme comes in four styles, `storm`, `moon`, a darker variant `night` and `day`
            light_style = "day", -- The theme is used when the background is set to light
            transparent = false, -- Enable this to disable setting the background color
            terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
            styles = {
                -- Style to be applied to different syntax groups
                -- Value is any valid attr-list value for `:help nvim_set_hl`
                comments = { italic = true },
                keywords = { italic = false },
                functions = { italic = false },
                variables = { italic = false },
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "dark", -- style for sidebars, see below
                floats = "transparent", -- style for floating windows
            },
            sidebars = { "qf", "help", "terminal", "packer" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
            day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
            hide_inactive_statusline = true, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
            dim_inactive = false, -- dims inactive windows
            lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold

            --- You can override specific color groups to use other groups or a hex color
            --- function will be called with a ColorScheme table
            ---@param colors ColorScheme
            on_colors = function(colors)
                -- colors.border = "#565f89"
            end,

            --- You can override specific highlights to use other groups or a hex color
            --- function will be called with a Highlights and ColorScheme table
            ---@param hl Highlights
            ---@param c ColorScheme
            on_highlights = function(hl, c)
                highlight_treesitter_context(hl, c)

                -- Neutral float chrome. tokyonight's default FloatBorder uses
                -- `border_highlight` (#27a1b9), which reads as a cyan accent on
                -- every hover/diagnostic/cmp float. `comment` (#565f89) keeps the
                -- rounded border visible without the accent.
                hl.FloatBorder = { fg = c.comment, bg = c.bg_float }

                -- Git conflict markers in markdown, see after/queries/markdown/
                -- highlights.scm. Needs a real fg: an empty group like @none
                -- never overrides the quote/heading colour underneath, and the heading
                -- bg and bold / quote italic only go away with an explicit bg and nocombine.
                hl["@conflict.marker"] = { fg = c.fg, bg = c.bg, nocombine = true }

                -- Default WinSeparator is near-black, reading as a heavy line
                -- between splits. `comment` (#565f89) matches FloatBorder above
                -- for a subtle grey divider instead.
                hl.WinSeparator = { fg = c.comment }

                -- render-markdown draws the fenced code block inside LSP hover
                -- (hover buffers are filetype=markdown) with an `hl_eol` extmark,
                -- so it paints the whole content rectangle. tokyonight backs
                -- RenderMarkdownCode with `bg_dark`, not `bg_float`, so `styles.floats
                -- = "transparent"` never reaches it. Hover buffers are buftype=nofile,
                -- and `plugins/render-markdown.lua` points their code blocks at this
                -- group instead; real markdown files keep the `bg_dark` box.
                --
                -- `c.bg` matches both the editor and ghostty's `background =
                -- 1a1b26`, so the block disappears into the float. If ghostty ever
                -- gets `background-opacity`, revisit: this stays opaque while the
                -- float around it would go translucent.
                hl.RenderMarkdownCodeFloat = { bg = c.bg }

                -- tokyonight links inline code to `@markup.raw.markdown_inline`, whose
                -- `terminal_black` bg reads as a heavy block. A subtler bg instead; bg
                -- only, so that group's blue fg still shows through. Padding is in
                -- `plugins/render-markdown.lua` (`code.inline_pad`).
                hl.RenderMarkdownCodeInline = { bg = c.bg_highlight }

                -- Unused code (LSP DiagnosticTag.Unnecessary, e.g. ts 6133).
                --
                -- VS Code dims these by lowering opacity, so each token keeps its
                -- own hue. That is not reproducible here: `blend` applies only
                -- inside the popupmenu and floating windows (:h highlight-blend),
                -- and a highlight group resolves to one concrete colour, so every
                -- unused token must share it.
                --
                -- The closest single-colour approximation is a faded version of the
                -- normal foreground. tokyonight's `terminal_black` (#414868) sits
                -- only ~24% of the way from bg to fg by luminance (73 against bg 28
                -- and fg 203), which reads as blacked-out rather than dimmed;
                -- blending fg halfway to bg gives #6d738e -- muted but still
                -- legible. Lower the 0.5 to dim harder.
                --
                -- fg only, so the undercurl from DiagnosticUnderlineHint survives.
                hl.DiagnosticUnnecessary = { fg = require("tokyonight.util").blend_bg(c.fg, 0.5) }
            end,

            cache = true, -- When set to true, the theme will be cached for better performance
            plugins = {
                -- enable all plugins when not using lazy.nvim
                -- set to false to manually enable/disable plugins
                all = package.loaded.lazy == nil,
                -- uses your plugin manager to automatically enable needed plugins
                -- currently only lazy.nvim is supported
                auto = true,
                -- add any plugins here that you want to enable
                -- for all possible plugins, see:
                --   * https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
                -- telescope = true,
            },
        })

        vim.cmd([[colorscheme tokyonight]])
    end,
}
