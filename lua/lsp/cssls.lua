local M = {}

M.setup = function(on_attach, capabilities)
    require("lspconfig").cssls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            css = {
                lint = {
                    unknownAtRules = "ignore",
                },
            },
        },
    })
end

return M
