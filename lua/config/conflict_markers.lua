-- Classify git conflict marker lines. Shared by the diff-hunk injections,
-- the fugitive no-EOL marks and the render-markdown patch, so every consumer
-- agrees on what counts as a marker (including the diff3 `|||||||` base).
local M = {}

-- `<<<<<<<`, `|||||||` and `>>>>>>>` carry a label after a space; `=======`
-- is bare and must be exact so a markdown `========` underline is not one.
local KINDS = { ["<<<<<<<"] = "start", ["|||||||"] = "base", [">>>>>>>"] = "end" }

-- "start" | "base" | "sep" | "end" | nil
function M.marker(line)
    if line == "=======" then
        return "sep"
    end
    local head, rest = line:sub(1, 7), line:sub(8, 8)
    if (rest == "" or rest == " ") and KINDS[head] then
        return KINDS[head]
    end
    return nil
end

return M
