return {
    "folke/tokyonight.nvim",
    lazy = "false",
    priority = 1000,
    config = function()
        local function highlight_treesitter_context(hl, c)
            local prompt = "#2d3149"
            hl.TreesitterContext = {
                bg = c.bg,
                fg = "NONE",
            }
            hl.TreesitterContextBottom = {
                underline = true,
                sp = c.comment,
            }
        end

        local function highlight_telescope(hl, c)
            local prompt = c.bg
            hl.TelescopeNormal = {
                bg = c.bg,
                fg = c.fg,
            }
            hl.TelescopeBorder = {
                bg = c.bg,
                fg = c.bg,
            }
            hl.TelescopePromptNormal = {
                bg = prompt,
            }
            hl.TelescopePromptBorder = {
                bg = prompt,
                fg = prompt,
            }
            hl.TelescopePromptTitle = {
                bg = c.bg_highlight,
                fg = c.fg,
            }
            hl.TelescopePreviewTitle = {
                bg = c.bg,
                fg = c.bg,
            }
            hl.TelescopeResultsTitle = {
                bg = c.bg,
                fg = c.bg,
            }
            hl.NoiceCmdlinePopupBorder = {
                bg = c.bg,
                fg = c.bg,
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
                keywords = { italic = true },
                functions = { italic = true },
                variables = { italic = true },
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
                -- highlight_telescope(hl, c)

                -- Neutral float chrome. tokyonight's default FloatBorder uses
                -- `border_highlight` (#27a1b9), which reads as a cyan accent on
                -- every hover/diagnostic/cmp float. `comment` (#565f89) keeps the
                -- rounded border visible without the accent.
                hl.FloatBorder = { fg = c.comment, bg = c.bg_float }

                -- render-markdown draws the fenced code block inside LSP hover
                -- (hover buffers are filetype=markdown) with an `hl_eol` extmark,
                -- so it paints the whole content rectangle. tokyonight backs that
                -- group with `bg_dark`, not `bg_float`, so `styles.floats =
                -- "transparent"` never reaches it.
                --
                -- Must be `c.bg`, NOT `c.none`: render-markdown registers its own
                -- groups as `{ link = "ColorColumn", default = true }`, and
                -- `default` only defers to an *existing* definition. `{ bg =
                -- "NONE" }` alone is an empty definition, which nvim treats as
                -- undefined -- so the ColorColumn link (#15161e) won once
                -- render-markdown lazy-loaded on the hover buffer. `c.bg` is a
                -- real definition and matches both the editor and ghostty's
                -- `background = 1a1b26`, so the block disappears into the float.
                -- If ghostty ever gets `background-opacity`, revisit: this stays
                -- opaque while the float around it would go translucent.
                hl.RenderMarkdownCode = { bg = c.bg }

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

                -- local prompt = "#2d3149"
                -- hl.LineNr = {
                --     fg = c.comment,
                -- }
                -- hl.TelescopeNormal = {
                --     bg = c.bg_dark,
                --     fg = c.fg_dark,
                -- }
                -- hl.TelescopeBorder = {
                --     bg = c.bg_dark,
                --     fg = c.bg_dark,
                -- }
                -- hl.TelescopePromptNormal = {
                --     bg = prompt,
                -- }
                -- hl.TelescopePromptBorder = {
                --     bg = prompt,
                --     fg = prompt,
                -- }
                -- hl.TelescopePromptTitle = {
                --     bg = prompt,
                --     fg = prompt,
                -- }
                -- hl.TelescopePreviewTitle = {
                --     bg = c.bg_dark,
                --     fg = c.bg_dark,
                -- }
                -- hl.TelescopeResultsTitle = {
                --     bg = c.bg_dark,
                --     fg = c.bg_dark,
                -- }
                -- hl.FloatBorder = {
                --     bg = c.none,
                --     fg = c.comment,
                -- }
                -- hl.NormalFloat = {
                --     bg = c.none,
                -- }
                -- hl.WhichKeyFloat = {
                --     bg = c.none,
                -- }
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
