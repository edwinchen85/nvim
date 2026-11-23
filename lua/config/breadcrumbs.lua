-- Zed-style breadcrumbs for the winbar, drawn by dropbar.nvim (`plugins/dropbar.lua`):
--
--   src/components/button.tsx › function MarkPaidButton( )
--
-- Mirrors Zed's `render_breadcrumb_text` (crates/editor/src/element.rs): the
-- path is one muted segment, then one segment per symbol around the cursor,
-- joined by a dimmer "›"; no icons. A symbol's text is built the way Zed's
-- `next_outline_item` (crates/language/src/buffer.rs) builds it: the @context
-- and @name captures of `queries/<lang>/outline.scm`, each keeping its syntax
-- colour, with a space wherever two captures are not adjacent in the buffer.
local hl = require("util.hl")

local M = {}

-- Zed's MAX_SEGMENTS: more than this and the middle collapses to "⋯".
M.max_segments = 12

---@class breadcrumbs.Chunk
---@field [1] string text
---@field [2] string? highlight group; nil is the bar's own muted colour

---@class breadcrumbs.Segment
---@field text string
---@field chunks breadcrumbs.Chunk[]
---@field range integer[]? 0-based { start_row, start_col, end_row, end_col } of the symbol

-- { row, col } <= { row, col }
local function le(arow, acol, brow, bcol)
    return arow < brow or (arow == brow and acol <= bcol)
end

-- The highlight group the buffer shows at a position: the last treesitter
-- capture of the highest priority, as the highlighter itself resolves ties.
local function hl_at(buf, row, col)
    local best, best_priority
    for _, cap in ipairs(vim.treesitter.get_captures_at_pos(buf, row, col)) do
        local name = cap.capture
        if name ~= "spell" and name ~= "nospell" and name ~= "conceal" and name:sub(1, 1) ~= "_" then
            local priority = tonumber(cap.metadata.priority) or vim.hl.priorities.treesitter
            if not best_priority or priority >= best_priority then
                best, best_priority = "@" .. name .. "." .. cap.lang, priority
            end
        end
    end
    return best
end

local function leaves(node, out)
    if node:child_count() == 0 then
        out[#out + 1] = node
        return
    end
    for child in node:iter_children() do
        leaves(child, out)
    end
end

-- Append `node`'s text to `chunks`, one chunk per token so each keeps its own
-- colour. Only the node's first line counts, as in Zed.
local function add_node(buf, node, chunks)
    local row, scol, erow, ecol = node:range()
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    if erow > row then
        ecol = #line
    end
    local tokens = {}
    leaves(node, tokens)
    local pos = scol
    for _, token in ipairs(tokens) do
        local trow, tscol, terow, tecol = token:range()
        if trow ~= row or tscol >= ecol then
            break
        end
        if terow > row then
            tecol = ecol
        end
        if tscol > pos then
            chunks[#chunks + 1] = { line:sub(pos + 1, tscol) }
        end
        if tecol > tscol then
            chunks[#chunks + 1] = { line:sub(tscol + 1, tecol), hl_at(buf, row, tscol) }
        end
        pos = math.max(pos, tecol)
    end
    if ecol > pos then
        chunks[#chunks + 1] = { line:sub(pos + 1, ecol) }
    end
end

local function segment_of(buf, item, parts)
    table.sort(parts, function(a, b)
        local arow, acol = a:start()
        local brow, bcol = b:start()
        return arow < brow or (arow == brow and acol < bcol)
    end)
    local chunks, last_row, last_col = {}, nil, nil
    for _, node in ipairs(parts) do
        local row, col = node:start()
        if #chunks > 0 and (row ~= last_row or col > last_col) then
            chunks[#chunks + 1] = { " " }
        end
        add_node(buf, node, chunks)
        last_row, last_col = node:end_()
    end
    local text = {}
    for i, chunk in ipairs(chunks) do
        text[i] = chunk[1]
    end
    return { text = table.concat(text), chunks = chunks, range = { item:range() } }
end

--- The symbols enclosing a position, outermost first.
---@param buf integer
---@param row integer 0-based
---@param col integer 0-based byte column
---@return breadcrumbs.Segment[]? nil when the language there has no outline query
function M.outline(buf, row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok or not parser then
        return nil
    end
    parser:parse({ row, row + 1 })
    local ltree = parser:language_for_range({ row, col, row, col })
    local query = vim.treesitter.query.get(ltree:lang(), "outline")
    if not query then
        return nil
    end

    local found, seen = {}, {}
    for _, tree in ipairs(ltree:trees()) do
        for _, match in query:iter_matches(tree:root(), buf, row, row + 1) do
            local item, parts, named = nil, {}, false
            for id, nodes in pairs(match) do
                local capture = query.captures[id]
                if capture == "item" then
                    item = nodes[1]
                elseif capture == "name" or capture == "context" then
                    named = named or capture == "name"
                    vim.list_extend(parts, nodes)
                end
            end
            if item and named and not seen[item:id()] then
                local srow, scol, erow, ecol = item:range()
                if le(srow, scol, row, col) and le(row, col, erow, ecol) then
                    seen[item:id()] = true
                    found[#found + 1] = segment_of(buf, item, parts)
                end
            end
        end
    end

    table.sort(found, function(a, b)
        local x, y = a.range, b.range
        if x[1] ~= y[1] or x[2] ~= y[2] then
            return le(x[1], x[2], y[1], y[2])
        end
        return not le(x[3], x[4], y[3], y[4])
    end)
    -- keep one chain of nested symbols: drop a neighbour that only touches the cursor
    local chain = {}
    for _, seg in ipairs(found) do
        local outer = chain[#chain]
        if not outer or le(seg.range[3], seg.range[4], outer.range[3], outer.range[4]) then
            chain[#chain + 1] = seg
        end
    end
    return chain
end

--- Zed keeps the first and last six segments of a long trail.
---@param segments breadcrumbs.Segment[]
---@return breadcrumbs.Segment[]
function M.clip(segments)
    local half = M.max_segments / 2
    if #segments <= M.max_segments then
        return segments
    end
    local out = vim.list_slice(segments, 1, half)
    out[#out + 1] = { text = "⋯", chunks = { { "⋯" } } }
    return vim.list_extend(out, segments, #segments - half + 1)
end

--- The file's path as Zed shows it: relative to the project (here the window's
--- cwd), or home-relative for a file outside it.
---@param buf integer
---@param win integer
---@return breadcrumbs.Segment
function M.path(buf, win)
    local name = vim.api.nvim_buf_get_name(buf)
    local ok, cwd = pcall(vim.fn.getcwd, win)
    local text = vim.fs.relpath(ok and cwd or vim.fn.getcwd(), name) or vim.fn.fnamemodify(name, ":~")
    return { text = text, chunks = { { text } } }
end

-- Replaces `dropbar_symbol_t:cat` (dropbar/bar.lua) on our symbols: upstream
-- paints a whole name with one `name_hl`, a breadcrumb needs one colour per
-- token. `name` stays the plain text, so upstream's `dropbar_t:truncate` still
-- shortens it; draw only as many characters as it left.
local function cat(self, plain)
    if plain then
        return self.icon .. self.name
    end
    local bar_utils = require("dropbar.utils").bar
    local extends = self.bar and self.bar.extends.icon or ""
    local cut = self.name ~= self.data.text
    local room = cut and vim.fn.strchars(self.name) - vim.fn.strchars(extends) or nil
    local out = { bar_utils.hl(self.icon, self.icon_hl) } -- pick mode puts its pivot letter in `icon`
    for _, chunk in ipairs(self.data.chunks) do
        local text = chunk[1]
        if room then
            text = vim.fn.strcharpart(text, 0, math.max(room, 0))
            room = room - vim.fn.strchars(text)
        end
        out[#out + 1] = bar_utils.hl(text:gsub("%%", "%%%%"), chunk[2])
    end
    if cut then
        out[#out + 1] = extends
    end
    local str = table.concat(out)
    if self.on_click and self.bar_idx then
        return bar_utils.make_clickable(
            str,
            ("v:lua.dropbar.callbacks.buf%s.win%s.fn%s"):format(self.bar.buf, self.bar.win, self.callback_idx)
        )
    end
    return str
end

local function jump(symbol)
    symbol:jump()
end

--- dropbar source (`dropbar_source_t`): the path, then the symbols around the cursor.
function M.get_symbols(buf, win, cursor)
    local segments = { M.path(buf, win) }
    local outline = M.outline(buf, cursor[1] - 1, cursor[2])
    local fallback = {}
    if outline then
        vim.list_extend(segments, outline)
    else
        -- No outline query for this language: upstream's symbols, names only,
        -- stripped to the same look.
        local sources = require("dropbar.sources")
        local source = vim.bo[buf].filetype == "markdown" and sources.markdown or sources.treesitter
        for _, symbol in ipairs(source.get_symbols(buf, win, cursor)) do
            symbol.icon = ""
            symbol.name_hl = nil
            symbol.on_click = jump
            fallback[#fallback + 1] = symbol
        end
    end

    local new = require("dropbar.bar").dropbar_symbol_t
    local symbols = {}
    for _, seg in ipairs(M.clip(segments)) do
        local r = seg.range
        symbols[#symbols + 1] = new:new({
            buf = buf,
            win = win,
            name = seg.text,
            data = { text = seg.text, chunks = seg.chunks },
            range = r and {
                start = { line = r[1], character = r[2] },
                ["end"] = { line = r[3], character = r[4] },
            },
            cat = cat,
            -- `false`, not nil: nil inherits upstream's menu-opening default
            -- (`configs.opts.symbol.on_click`), and these have no menu.
            on_click = r and jump or false,
        })
    end
    return vim.list_extend(symbols, fallback)
end

-- Zed's toolbar sits on the editor background with `Color::Muted` text and a
-- `Color::Placeholder` separator; the ratios are those two colours measured
-- against the text colour in Zed's default theme. Both groups are set the same
-- so an unfocused window's bar does not dim, as in Zed.
local function set_hl()
    local fg, bg = hl.get("Normal", "fg"), hl.get("Normal", "bg")
    local muted = { fg = hl.blend(fg, bg, 0.7), bg = bg }
    vim.api.nvim_set_hl(0, "WinBar", muted)
    vim.api.nvim_set_hl(0, "WinBarNC", muted)
    vim.api.nvim_set_hl(0, "DropBarIconUISeparator", { fg = hl.blend(fg, bg, 0.5), bg = bg })
end

function M.setup()
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("config.breadcrumbs", {}),
        callback = set_hl,
    })
end

return M
