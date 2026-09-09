local M = {}

-- vim.keymap.set with `silent = true` by default.
M.map = function(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
end

for _, mode in ipairs({ "c", "i", "n", "o", "t", "u", "v", "x" }) do
    M[mode .. "map"] = function(...)
        M.map(mode, ...)
    end
end

-- :lua inspect(vim.lsp.get_clients())
_G.inspect = function(...)
    print(vim.inspect(...))
end

return M
