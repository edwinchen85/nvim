local u = require("utils")

local lsp = vim.lsp
local api = vim.api

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

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

-- use lsp formatting if it's available (and if it's good)
-- otherwise, fall back to null-ls
local preferred_formatting_clients = { "eslint" }
local fallback_formatting_client = "null-ls"

local formatting = function(bufnr)
    bufnr = tonumber(bufnr) or api.nvim_get_current_buf()

    local selected_client
    for _, client in ipairs(lsp.buf_get_clients(bufnr)) do
        if vim.tbl_contains(preferred_formatting_clients, client.name) then
            selected_client = client
            break
        end

        if client.name == fallback_formatting_client then
            selected_client = client
        end
    end

    if not selected_client then
        return
    end

    local params = lsp.util.make_formatting_params()
    selected_client.request("textDocument/formatting", params, function(err, res)
        if err then
            local err_msg = type(err) == "string" and err or err.message
            vim.notify("global.lsp.formatting: " .. err_msg, vim.log.levels.WARN)
            return
        end

        if not api.nvim_buf_is_loaded(bufnr) or api.nvim_buf_get_option(bufnr, "modified") then
            return
        end

        if res then
            lsp.util.apply_text_edits(res, bufnr, selected_client.offset_encoding or "utf-16")
            api.nvim_buf_call(bufnr, function()
                vim.cmd("silent noautocmd update")
            end)
        end
    end, bufnr)
end

global.lsp = {
    border_opts = border_opts,
    formatting = formatting,
}

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
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
    u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
    u.buf_map("n", "gR", ":LspRename<CR>", nil, bufnr)
    u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
    u.buf_map("n", "[d", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]d", ":LspDiagNext<CR>", nil, bufnr)
    u.buf_map("n", "gd", ":LspDefinition<CR>", nil, bufnr)
    u.buf_map("n", "gs", ":LspSignatureHelp<CR>", nil, bufnr)
    u.buf_map("n", "gh", ":LspImplementation<CR>", nil, bufnr)
    u.buf_map("n", "gl", ":LspDiagLine<CR>", nil, bufnr)
    u.buf_map("n", "<leader>q", ":LspDiagLocList<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    -- telescope
    u.buf_map("n", "gr", ":TroubleToggle lsp_references<CR>", nil, bufnr)
    u.buf_map("n", "ga", ":LspCodeAction<CR>", nil, bufnr)
    u.buf_map("v", "ga", "<Esc><cmd> LspRangeAct<CR>", nil, bufnr)

    if client.supports_method("textDocument/formatting") then
        vim.cmd([[
        augroup LspFormatting
            autocmd! * <buffer>
            autocmd BufWritePost <buffer> lua global.lsp.formatting(vim.fn.expand("<abuf>"))
        augroup END
        ]])
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

for _, server in ipairs({
    "bashls",
    "eslint",
    "jsonls",
    "null-ls",
    "sumneko_lua",
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
