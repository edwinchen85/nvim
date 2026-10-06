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
        -- Code blocks: a box only as wide as the code (`min_width` keeps short
        -- ones from looking like a stray chip), one space inside it on each side.
        -- Inline code: one space inside its box; colour in `plugins/tokyonight.lua`.
        code = { width = "block", left_pad = 1, right_pad = 1, min_width = 40, inline_pad = 1 },
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
                -- The float group hides the block's box (see `plugins/tokyonight.lua`);
                -- the language bar too, since RenderMarkdownCodeBorder links to the
                -- block group. `left_pad = 0` keeps that existing one-space content
                -- padding the only indent.
                nofile = {
                    code = {
                        language_pad = 1,
                        left_pad = 0,
                        highlight = "RenderMarkdownCodeFloat",
                        highlight_border = "RenderMarkdownCodeFloat",
                    },
                },
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

    -- Git conflict markers parse as markdown: `>>>>>>> branch` is seven nested
    -- block quotes (a wall of quote bars), `<<<<<<< HEAD` over `=======` is a
    -- setext H1. Skip rendering nodes whose first line is a marker.
    local marker = require("config.conflict_markers").marker
    for _, name in ipairs({ "quote", "heading" }) do
        local render = require("render-markdown.render.markdown." .. name)
        local render_setup = render.setup
        render.setup = function(self)
            local row = self.node.start_row
            local line = vim.api.nvim_buf_get_lines(self.context.buf, row, row + 1, false)[1] or ""
            if marker(line) then
                return false
            end
            return render_setup(self)
        end
    end
end

return M
