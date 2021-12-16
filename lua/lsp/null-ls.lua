local null_ls = require("null-ls")
local b = null_ls.builtins

local eslint_opts = {
    condition = function(utils)
        return utils.root_has_file(".eslintrc", ".eslintrc.js")
    end,
    diagnostics_format = "#{m} [#{c}]",
}

local sources = {
    b.formatting.prettierd,
    b.diagnostics.eslint_d.with(eslint_opts),
    b.formatting.eslint_d.with(eslint_opts),
    b.code_actions.eslint_d.with(eslint_opts),
    b.formatting.stylua.with({
        args = { "--indent-width", "4", "--indent-type", "Spaces", "-" },
    }),
    b.formatting.trim_whitespace.with({ filetypes = { "tmux", "zsh" } }),
    b.formatting.shfmt,
    b.diagnostics.shellcheck.with({ diagnostic_format = "#{m} [#{c}]" }),
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({
        sources = sources,
        on_attach = on_attach,
    })
end

return M
