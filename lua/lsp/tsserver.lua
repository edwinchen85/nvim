local ts_utils_settings = {
    enable_import_on_completion = true,
    import_all_scan_buffers = 100,
    update_imports_on_move = true,
    auto_inlay_hints = false,
    -- filter out dumb module warning
    filter_out_diagnostics_by_code = { 80001, 80006 },
}

local M = {}

M.setup = function(on_attach, capabilities)
    local lspconfig = require("lspconfig")
    local ts_utils = require("nvim-lsp-ts-utils")

    lspconfig["tsserver"].setup({
        root_dir = lspconfig.util.root_pattern("package.json"),
        init_options = ts_utils.init_options,
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false

            on_attach(client, bufnr)

            ts_utils.setup(ts_utils_settings)
            ts_utils.setup_client(client)
        end,
        flags = {
            debounce_text_changes = 150,
        },
        capabilities = capabilities,
    })
end

return M
