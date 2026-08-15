local M = {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        render_modes = { "n", "c" },
        anti_conceal = { enabled = false },
        -- pipetable owns table rendering; leaving both on stacks two sets of
        -- borders and they fight over `concealcursor`. See `plugins/pipetable.lua`.
        pipe_table = { enabled = false },
        win_options = { concealcursor = { rendered = "nvic" } },
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

function M.config(_, opts)
    require("render-markdown").setup(opts)

    -- pipetable conceals each table line to zero width and redraws it as inline
    -- virt_text at the line end, so a link icon anchored to a byte offset inside
    -- that line collapses onto column 0 and surfaces in the left margin. It also
    -- draws its own icon in the cell, so ours would be a duplicate anyway. Skip
    -- link rendering on the lines pipetable owns and leave prose untouched --
    -- `setup()` returning false is render-markdown's own skip signal, see
    -- `render/inline/link.lua:16`.
    local link = require("render-markdown.render.inline.link")
    local setup = link.setup

    link.setup = function(self)
        local ok, state = pcall(require, "pipetable.state")
        local st = ok and state.peek(self.context.buf) or nil
        local row = self.node.start_row

        for _, tbl in ipairs(st and st.tables or {}) do
            if row >= tbl.range[1] and row <= tbl.range[2] then
                return false
            end
        end

        return setup(self)
    end
end

return M
