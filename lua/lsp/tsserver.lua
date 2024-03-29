local u = require("config.utils")

local M = {}
M.setup = function(on_attach, capabilities)
    require("typescript").setup({
        server = {
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)

                u.buf_map(bufnr, "n", "go", ":TypescriptAddMissingImports<CR>")
                u.buf_map(bufnr, "n", "gd", ":TypescriptGoToSourceDefinition<CR>")

                require("nvim-lsp-ts-utils").setup({
                    -- Refer to https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                    filter_out_diagnostics_by_code = { 80001, 80005, 80006, 80007 },
                })
                require("nvim-lsp-ts-utils").setup_client(client)
            end,
            capabilities = capabilities,
        },
    })
end

return M
