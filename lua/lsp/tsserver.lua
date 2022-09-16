local u = require("config.utils")

local M = {}
M.setup = function(on_attach, capabilities)
    require("typescript").setup({
        server = {
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)

                u.buf_map(bufnr, "n", "go", ":TypescriptAddMissingImports<CR>")
            end,
            capabilities = capabilities,
        },
    })
end

return M
