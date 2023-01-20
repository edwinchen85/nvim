local u = require("config.utils")

local lsp = vim.lsp

local border_opts = {
    border = "single",
    focusable = true,
    style = "minimal",
    source = "always",
    scope = "line",
    header = "",
    prefix = "",
}

local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config({
    virtual_text = false,
    float = border_opts,
    signs = {
        active = signs,
    },
})

local eslint_disabled_buffers = {}

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local formatting = function(bufnr)
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    lsp.buf.format({
        bufnr = bufnr,
        filter = function(client)
            if client.name == "jsonls" then
                return true
            end

            if client.name == "eslint" then
                return not eslint_disabled_buffers[bufnr]
            end

            if client.name == "null-ls" then
                return not u.table.some(clients, function(_, other_client)
                    return other_client.name == "eslint" and not eslint_disabled_buffers[bufnr]
                end)
            end
        end,
    })
end

global.lsp = {
    border_opts = border_opts,
    formatting = formatting,
}

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspFormatting", "vim.lsp.buf.format()")
    u.lua_command("LspHover", "vim.lsp.buf.hover()")
    u.lua_command("LspRename", "vim.lsp.buf.rename()")
    u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
    u.lua_command("LspDefinition", "vim.lsp.buf.definition()")
    u.lua_command("LspReferences", "vim.lsp.buf.references()")
    u.lua_command("LspCodeAction", "vim.lsp.buf.code_action()")
    u.lua_command("LspImplementation", "vim.lsp.buf.implementation()")
    u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev({ border = 'single' })")
    u.lua_command("LspDiagNext", "vim.diagnostic.goto_next({ border = 'single' })")
    u.lua_command("LspDiagLine", "vim.diagnostic.open_float(nil, global.lsp.border_opts)")
    u.lua_command("LspDiagLocList", "lua vim.diagnostic.setloclist()")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

    -- bindings
    u.buf_map(bufnr, "n", "K", ":LspHover<CR>", nil)
    u.buf_map(bufnr, "n", "gR", ":LspRename<CR>", nil)
    u.buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>", nil)
    u.buf_map(bufnr, "n", "[d", ":LspDiagPrev<CR>", nil)
    u.buf_map(bufnr, "n", "]d", ":LspDiagNext<CR>", nil)
    u.buf_map(bufnr, "n", "gd", ":LspDefinition<CR>", nil)
    u.buf_map(bufnr, "n", "gs", ":LspSignatureHelp<CR>", nil)
    u.buf_map(bufnr, "n", "gh", ":LspImplementation<CR>", nil)
    u.buf_map(bufnr, "n", "gl", ":LspDiagLine<CR>", nil)
    u.buf_map(bufnr, "n", "<leader>q", ":LspDiagLocList<CR>", nil)
    u.buf_map(bufnr, "i", "<C-s>", "<cmd> LspSignatureHelp<CR>", nil)

    -- telescope
    u.buf_map(bufnr, "n", "gr", ":TroubleToggle lsp_references<CR>", nil)
    u.buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>", nil)
    u.buf_map(bufnr, "x", "ga", function()
        vim.lsp.buf.code_action() -- range
    end)

    if client.supports_method("textDocument/formatting") then
        local formatting_cb = function()
            formatting(bufnr)
        end
        u.buf_command(bufnr, "LspFormatting", formatting_cb)
        u.buf_map(bufnr, "x", "<CR>", formatting_cb)

        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            command = "LspFormatting",
        })
    end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs({
    "bashls",
    "cssls",
    "eslint",
    "jsonls",
    "null-ls",
    "pyright",
    "sumneko_lua",
    "tailwindcss",
    "tsserver",
}) do
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    require("lsp." .. server).setup(on_attach, capabilities)
end

-- suppress irrelevant messages
local notify = vim.notify
vim.notify = function(msg, ...)
    if msg:match("%[lspconfig%]") then
        return
    end

    if msg:match("warning: multiple different client offset_encodings") then
        return
    end

    notify(msg, ...)
end
