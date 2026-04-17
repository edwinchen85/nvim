-- https://github.com/nvim-treesitter/nvim-treesitter-context
--
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-treesitter-context.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-treesitter-context.lua
--
-- If on a markdown file, and you're inside a level 4 heading, this plugin shows
-- you the level 2 and 3 heading that you're under at the top of the screen
-- Really useful to know where you're at
--
-- This plugin used to be enabled by default in lazyvim, but it was moved to
-- extras lamw25wmal
--
-- I just copied Folke's config here
-- https://www.lazyvim.org/extras/ui/treesitter-context#nvim-treesitter-context

return {
    "nvim-treesitter/nvim-treesitter-context",
    commit = "b0c45cefe2c8f7b55fc46f34e563bc428ef99636", -- pinned: upstream fix needed for nvim 0.12 async parse nil node
    event = "VeryLazy",
    opts = {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = true, -- Enable multiwindow support.
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
    -- keys = {
    --     {
    --         "<leader>ut",
    --         function()
    --             local tsc = require("treesitter-context")
    --             tsc.toggle()
    --             if LazyVim.inject.get_upvalue(tsc.toggle, "enabled") then
    --                 LazyVim.info("Enabled Treesitter Context", { title = "Option" })
    --             else
    --                 LazyVim.warn("Disabled Treesitter Context", { title = "Option" })
    --             end
    --         end,
    --         desc = "Toggle Treesitter Context",
    --     },
    -- },
}
