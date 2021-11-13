local M = {}

M.setup = function(_, capabilities)
    require("lspconfig").jsonls.setup({
        settings = {
            json = {
                schemas = require("schemastore").json.schemas(),
            },
        },
        capabilities = capabilities,
        on_attach = function(client)
            client.resolved_capabilities.document_formatting = false
        end,
    })
end

return M
