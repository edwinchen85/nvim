-- Colours read from standard highlight groups (`Normal`, `DiagnosticWarn`, ...)
-- instead of hex codes or one theme's palette, so custom colours follow whichever
-- colorscheme and `background` is active. Callers re-read on `ColorScheme`.
local M = {}

---@param name string highlight group, links resolved
---@param attr "fg"|"bg"|"sp"
---@return string? hex `#rrggbb`, nil when the group leaves it unset
function M.get(name, attr)
    -- Not `link = false`: that path resolves through the current window's
    -- 'winhighlight', so inside e.g. the sidekick terminal `Normal` reads as its
    -- remap target (SidekickChat, fg only) and the bg comes back nil. Follow links by hand.
    local v = vim.api.nvim_get_hl(0, { name = name })
    for _ = 1, 10 do
        if not v.link then
            break
        end
        v = vim.api.nvim_get_hl(0, { name = v.link })
    end
    v = v[attr]
    return v and ("#%06x"):format(v)
end

--- Mix `a` into `b`: alpha 1 is all `a`, 0 all `b`. A nil side (e.g. `Normal.bg`
--- under a transparent theme) returns the other unchanged.
---@param a string? hex
---@param b string? hex
---@param alpha number 0..1
---@return string? hex
function M.blend(a, b, alpha)
    if not a or not b then
        return a or b
    end
    local function ch(hex, i)
        return tonumber(hex:sub(i, i + 1), 16)
    end
    local out = "#"
    for i = 2, 6, 2 do
        out = out .. ("%02x"):format(math.floor(alpha * ch(a, i) + (1 - alpha) * ch(b, i) + 0.5))
    end
    return out
end

return M
