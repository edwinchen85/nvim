-- Language resolution for diff hunks, driving after/queries/diff/injections.scm.
--
-- Fugitive's :Git status buffer and its diff/show/log output are diffs as far as
-- treesitter is concerned, so the diff parser handles both filetypes; the vim
-- syntax stays on underneath for the section headers via the treesitter spec's
-- additional_vim_regex_highlighting.

local M = {}

-- Node types that name the file being diffed: `unrecognized` is fugitive's
-- `M lua/foo.lua` status line (its inline hunks carry no diff header at all),
-- the rest come from real diff output. Reaching one of these ends the walk
-- whether or not it resolves — otherwise a file with no detectable filetype
-- would inherit the language of the file above it.
local NAMES_FILE = {
    unrecognized = true,
    new_file = true,
    old_file = true,
    command = true,
}

-- Row -> filetype for one buffer, thrown away whenever the buffer changes. Every
-- hunk line would otherwise re-walk to the same file line, and vim.filetype.match
-- is expensive enough that doing so costs seconds on a large :Git status buffer.
-- Matches arrive in document order, so a line finds its predecessor's answer one
-- step back, and the post- and pre-image patterns share the work.
--
-- ponytail: one buffer at a time. Two windows on different diffs rebuild on each
-- alternation, which is just a cold parse; key it by bufnr if that ever shows up.
local cache = {}

local function resolve(match, _, source, pred, metadata)
    local node = match[pred[2]] and match[pred[2]][1]
    if not node then
        return
    end

    local rows
    if type(source) == "number" then
        local tick = vim.b[source].changedtick
        if cache.buf ~= source or cache.tick ~= tick then
            cache = { buf = source, tick = tick, rows = {} }
        end
        rows = cache.rows
    else
        rows = {}
    end

    local row = node:range()
    local ft = rows[row]
    if ft == nil then
        ft = false
        local n = node:prev_sibling() or node:parent()
        while n do
            local cached = rows[(n:range())]
            if cached ~= nil then
                ft = cached
                break
            end
            if NAMES_FILE[n:type()] then
                ft = vim.filetype.match({ filename = vim.treesitter.get_node_text(n, source) }) or false
                break
            end
            n = n:prev_sibling() or n:parent()
        end
        rows[row] = ft
    end

    if ft == "vue" then
        -- Vue's grammar only highlights content wrapped in <script>/<template>/
        -- <style> tags; a lone hunk line has none of that structure and parses
        -- to a bare ERROR node with no captures. Sniff the line itself instead
        -- of trusting the file's language -- cheap enough to redo every call,
        -- unlike the file-name walk above, so it isn't part of the row cache.
        local text = vim.treesitter.get_node_text(node, source)
        ft = text:match("^.%s*<") and "html" or "typescript"
    end

    if ft then
        metadata["injection.language"] = ft
    end
end

function M.setup()
    vim.treesitter.language.register("diff", "fugitive")
    vim.treesitter.language.register("diff", "git")
    vim.treesitter.query.add_directive("diff-filename!", resolve, { force = true })
end

return M
