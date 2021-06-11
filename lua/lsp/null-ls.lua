local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
    b.formatting.prettierd.with({
        filetypes = { "html", "json", "yaml", "markdown" },
    }),
    b.formatting.stylua.with({ args = { "--config-path", vim.fn.stdpath("config") .. "/lua/stylua.toml", "-" } }),
    b.formatting.trim_whitespace.with({ filetypes = { "tmux", "fish", "teal" } }),
    b.diagnostics.write_good,
    b.diagnostics.markdownlint,
    b.diagnostics.teal,
    b.code_actions.gitsigns,
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({
        -- debug = true,
        on_attach = on_attach,
        sources = sources,
    })
end

return M
