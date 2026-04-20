vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
        end

        map("n", "gr", vim.lsp.buf.references, "Show LSP references")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Show LSP definition")
        map("n", "gi", vim.lsp.buf.implementation, "Show LSP implementations")
        map("n", "gt", vim.lsp.buf.type_definition, "Show LSP type definitions")
        map({ "n", "v" }, "ga", vim.lsp.buf.code_action, "See available code actions")
        map("n", "gR", vim.lsp.buf.rename, "Smart rename")
        map("n", "gl", vim.diagnostic.open_float, "Show line diagnostics")
        map("n", "[d", function()
            vim.diagnostic.jump({ count = -1, on_jump = vim.diagnostic.open_float })
        end, "Go to previous diagnostic")
        map("n", "]d", function()
            vim.diagnostic.jump({ count = 1, on_jump = vim.diagnostic.open_float })
        end, "Go to next diagnostic")
        map("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
        end, "Show documentation for what is under cursor")
        map("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
    end,
})

local border_opts = {
    border = "rounded",
    focusable = true,
    style = "minimal",
    source = "always",
    scope = "line",
    header = "",
    prefix = "",
}
local severity = vim.diagnostic.severity

vim.diagnostic.config({
    float = border_opts,
    signs = {
        text = {
            [severity.ERROR] = " ",
            [severity.WARN] = " ",
            [severity.HINT] = "󰠠 ",
            [severity.INFO] = " ",
        },
    },
})

-- suppress irrelevant lspconfig messages
local _notify = vim.notify
vim.notify = function(msg, ...)
    if msg:match("%[lspconfig%]") or msg:match("warning: multiple different client offset_encodings") then
        return
    end
    _notify(msg, ...)
end
