local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
    b.formatting.prettierd.with({
        filetypes = { "html", "json", "yaml", "markdown" },
    }),
    b.formatting.stylua.with({
        condition = function(utils)
            return utils.root_has_file("stylua.toml")
        end,
    }),
    b.formatting.trim_whitespace.with({ filetypes = { "tmux" } }),
    b.formatting.shfmt,
    b.diagnostics.shellcheck.with({ diagnostic_format = "#{m} [#{c}]" }),
    b.code_actions.gitsigns,
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({
        sources = sources,
    })
    require("lspconfig")["null-ls"].setup({ on_attach = on_attach })
end

return M
