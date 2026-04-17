local keymap = vim.keymap -- for conciseness
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gr", vim.lsp.buf.references, opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definition"
        keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", vim.lsp.buf.type_definition, opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "gR", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show line diagnostics"
        keymap.set("n", "gl", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, on_jump = vim.diagnostic.open_float })
        end, opts) -- jump to previous diagnostic in buffer
        --
        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, on_jump = vim.diagnostic.open_float })
        end, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end,
})

-- vim.lsp.inlay_hint.enable(true)

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
    border_opts = border_opts,
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
