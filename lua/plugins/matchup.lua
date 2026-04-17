local M = {
    "andymass/vim-matchup",
    event = { "BufReadPre", "BufNewFile" },
}

function M.init()
    vim.g.matchup_matchparen_offscreen = { method = "status_offscreen" }
end

return M