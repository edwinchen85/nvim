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

local VUE_BLOCK = { template = "html", script = "javascript", style = "css" }
local VUE_TAG = "^%s*<(/?)(%a+)([^>]*)>"

-- `<script setup lang="ts">` -> typescript, `<style lang="scss">` -> scss, etc.
local function vue_block_lang(tag, attrs)
    local lang = attrs:match("lang=[\"']?(%w+)")
    return lang and vim.filetype.match({ filename = "x." .. lang }) or VUE_BLOCK[tag]
end

-- Block open just before post-image line `lnum` of `path`, read from the working
-- tree; hunks that start mid-block show no tag to go on. Staged diffs may differ
-- from the working tree by a few lines, which almost never crosses a block tag.
local function vue_block_before(source, path, lnum)
    local lines = cache.files[path]
    if lines == nil then
        local root = type(source) == "number" and vim.fn.FugitiveWorkTree(source) or ""
        if root == "" then
            root = vim.uv.cwd()
        end
        lines = vim.fn.filereadable(root .. "/" .. path) == 1 and vim.fn.readfile(root .. "/" .. path) or false
        cache.files[path] = lines
    end
    for i = math.min(lnum - 1, lines and #lines or 0), 1, -1 do
        local close, tag, attrs = lines[i]:match(VUE_TAG)
        if VUE_BLOCK[tag] then
            return close == "" and vue_block_lang(tag, attrs) or false
        end
    end
end

-- fugitive's status line is "<status-char> <filename>" (see its
-- `dict.status . ' ' . dict.filename` format); strip that prefix or filetype
-- detection never matches a dotfile like `.env.development`, since
-- "M .env.development" satisfies no filetype pattern at all. Real diff headers
-- carry the `+++ b/` prefix, which only matters for reading the file back.
local function file_path(ty, text)
    if ty == "unrecognized" then
        return text:match("^%S+%s+(.*)$") or text
    end
    return text:match("^[-+]+ [ab]/(.*)$") or text
end

local function resolve(match, _, source, pred, metadata)
    local node = match[pred[2]] and match[pred[2]][1]
    if not node then
        return
    end

    local rows
    if type(source) == "number" then
        local tick = vim.b[source].changedtick
        if cache.buf ~= source or cache.tick ~= tick then
            cache = { buf = source, tick = tick, rows = {}, files = {} }
        end
        rows = cache.rows
    else
        cache = { rows = {}, files = {} }
        rows = cache.rows
    end

    local row = node:range()
    local info = rows[row]
    if info == nil then
        info = { ft = false }
        local hunk -- post-image start line when the walk crosses a `@@` header
        local n = node:prev_sibling() or node:parent()
        while n do
            local cached = rows[(n:range())]
            if cached ~= nil then
                info.ft, info.path = cached.ft, cached.path
                if not hunk then
                    info.block = cached.block
                end
                break
            end
            local ty = n:type()
            if ty == "location" then
                hunk = tonumber(vim.treesitter.get_node_text(n, source):match("%+(%d+)"))
            elseif NAMES_FILE[ty] then
                info.path = file_path(ty, vim.treesitter.get_node_text(n, source))
                info.ft = vim.filetype.match({ filename = info.path }) or false
                break
            end
            n = n:prev_sibling() or n:parent()
        end
        if info.ft == "vue" and info.block == nil and hunk then
            info.block = vue_block_before(source, info.path, hunk)
        end
        rows[row] = info
    end

    local ft = info.ft
    if ft == "vue" then
        -- Vue's grammar only highlights content wrapped in <script>/<template>/
        -- <style> tags, and a hunk rarely shows both ends of a block, so inject
        -- each line with the language of the SFC block it sits in instead.
        -- `info.block` is the block open after this row; lines inherit it from
        -- the previous row (matches arrive in document order, so it is cached).
        -- A block-tag line itself is parsed as html on its own, uncombined: a
        -- `<script>` start tag inside the combined html tree would otherwise turn
        -- every later template line into raw_text.
        local text = vim.treesitter.get_node_text(node, source):sub(2)
        local close, tag, attrs = text:match(VUE_TAG)
        if VUE_BLOCK[tag] then
            info.block = close == "" and vue_block_lang(tag, attrs) or false
            metadata["injection.combined"] = nil
            ft = "html"
        elseif info.block ~= nil then
            ft = info.block
        else
            -- file unreadable and no tag in sight: sniff the line itself
            ft = text:match("^%s*<") and "html" or "typescript"
        end
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
