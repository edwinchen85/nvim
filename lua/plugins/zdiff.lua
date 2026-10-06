-- Vue's own highlights query only covers the SFC tag structure; the actual
-- script/template content is normally shown via treesitter language
-- injection, which zdiff's homemade single-language highlighter never
-- resolves. Split the hunk into SFC blocks (config/vue_blocks, shared with the
-- fugitive diff injections) and re-highlight each with its real language.
local vue = require("config.vue_blocks")

-- Zdiff paints once synchronously (bare hunk lines, no wrapper tags) before
-- its async git-show projection lands and repaints with the real thing; lines
-- before any tag get sniffed per line rather than skipped, so that first pass
-- is not blank.
local function vue_blocks(code)
    local blocks, block = {}, nil
    for i, line in ipairs(code) do
        local lang
        lang, block = vue.step(block, line)
        local prev = blocks[#blocks]
        if not lang then -- luacheck: ignore 542
            -- outside any block: nothing to highlight
        elseif prev and prev.lang == lang and prev.line_offset + #prev.lines == i - 1 then
            table.insert(prev.lines, line)
        else
            table.insert(blocks, { lang = lang, lines = { line }, line_offset = i - 1 })
        end
    end
    return blocks
end

local function patch_vue_highlighting()
    local syntax = require("zdiff.syntax")
    local get_highlights = syntax.get_highlights

    syntax.get_highlights = function(code, lang)
        if lang ~= "vue" then
            return get_highlights(code, lang)
        end

        local highlights = {}
        for _, block in ipairs(vue_blocks(code)) do
            for _, hl in ipairs(get_highlights(block.lines, block.lang)) do
                table.insert(highlights, {
                    line = block.line_offset + hl.line,
                    hl_group = hl.hl_group,
                    col_start = hl.col_start,
                    col_end = hl.col_end,
                })
            end
        end
        return highlights
    end
end

return {
    "martindur/zdiff.nvim",
    cmd = "Zdiff",
    keys = {
        { "<leader>zd", "<cmd>Zdiff<cr>", desc = "Zdiff (uncommitted)" },
        { "<leader>zD", "<cmd>Zdiff main<cr>", desc = "Zdiff (vs main)" },
    },
    opts = {
        keymaps = {
            goto_file = "o",
            toggle = "<Space>",
            yank_ref = "Y",
        },
        -- "projection" fetches the whole old+new file via an extra `git show`
        -- spawn (~55ms of pure process overhead, measured) on top of the hunk
        -- diff spawn; "hunk" highlights just the visible lines synchronously.
        syntax = {
            mode = "hunk",
        },
    },
    config = function(_, opts)
        require("zdiff").setup(opts)
        patch_vue_highlighting()
    end,
}
