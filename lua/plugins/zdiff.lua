-- Vue's own highlights query only covers the SFC tag structure; the actual
-- script/template content is normally shown via treesitter language
-- injection, which zdiff's homemade single-language highlighter never
-- resolves. Sniff out the <script>/<template>/<style> blocks ourselves and
-- re-highlight each with its real language.
-- SIMPLIFIED: blocks are found by matching literal opening/closing tag lines,
-- not by walking the vue tree; upgrade to a real query if a block ever shares
-- a line with its tag (e.g. prettier stops putting them on their own line).
local block_lang = { script = "typescript", template = "html", style = "css" }

-- Zdiff paints once synchronously (bare hunk lines, no wrapper tags) before
-- its async git-show projection lands and repaints with the real thing. An
-- empty first pass here means a visible flash from blank to colored once the
-- projection resolves, so bare lines with no tags in sight get sniffed
-- per-line (same heuristic as lua/config/diff_lang.lua) instead of skipped.
local function sniff_vue_line(line)
    return line:match("^%s*<") and "html" or "typescript"
end

local function vue_blocks(code)
    local blocks, block, found_tag = {}, nil, false
    for i, line in ipairs(code) do
        if block then
            if line:match("^%s*</" .. block.tag .. ">%s*$") then
                if #block.lines > 0 then
                    table.insert(blocks, block)
                end
                block = nil
            else
                table.insert(block.lines, line)
            end
        else
            local tag = line:match("^%s*<(%a+)[^>]*>%s*$")
            if tag and block_lang[tag] then
                found_tag = true
                block = { tag = tag, lang = block_lang[tag], lines = {}, line_offset = i }
            end
        end
    end

    if found_tag then
        return blocks
    end

    for i, line in ipairs(code) do
        local lang = sniff_vue_line(line)
        local prev = blocks[#blocks]
        if prev and prev.lang == lang then
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
