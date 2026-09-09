-- Which language a line of a Vue SFC belongs to, one line at a time.
--
-- Shared by the diff-hunk treesitter injections (config/diff_lang) and the
-- zdiff highlighter patch (plugins/zdiff): both see hunk lines without the
-- surrounding SFC structure, so the block is tracked as a value the caller
-- threads through `step`.
--
-- Block state: a language string while inside a block, `false` when known to
-- be outside any block, `nil` when unknown (hunk starts mid-file with no tag in
-- sight) - in which case a line is sniffed on its own shape.
local M = {}

M.BLOCKS = { template = "html", script = "typescript", style = "css" }
local TAG = "^%s*<(/?)(%a+)([^>]*)>"

-- Block language opened (or `false` if closed) by `line`; nil if it is not a
-- block tag line. `<script setup lang="ts">` -> typescript, `<style lang="scss">`
-- -> scss, otherwise the BLOCKS default.
function M.open_block(line)
    local close, tag, attrs = line:match(TAG)
    if not M.BLOCKS[tag] then
        return nil
    end
    if close ~= "" then
        return false
    end
    local lang = attrs:match("lang=[\"']?(%w+)")
    return lang and vim.filetype.match({ filename = "x." .. lang }) or M.BLOCKS[tag]
end

-- Returns the line's language (nil for none), the block state after it, and
-- whether the line is itself a block tag. Tag lines are html.
function M.step(block, line)
    local opened = M.open_block(line)
    if opened ~= nil then
        return "html", opened, true
    end
    if block then
        return block, block, false
    end
    if block == false then
        return nil, false, false
    end
    return line:match("^%s*<") and "html" or "typescript", nil, false
end

return M
