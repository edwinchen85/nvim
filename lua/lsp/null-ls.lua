local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

local b = null_ls.builtins

local sources = {
    -- formatting
    b.formatting.prettierd,
    b.formatting.stylua.with({
        args = { "--indent-width", "4", "--indent-type", "Spaces", "-" },
    }),
    b.formatting.trim_whitespace.with({ filetypes = { "tmux", "zsh" } }),
    b.formatting.shfmt,
    -- diagnostics
    b.diagnostics.write_good,
    b.diagnostics.markdownlint,
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({
        sources = sources,
        on_attach = on_attach,
    })
end

return M
