local u = require("utils")

local lsp = vim.lsp
local api = vim.api

local border_opts = {
    border = "rounded",
    focusable = false,
    style = "minimal",
    source = "always",
    scope = "line",
    header = "",
    prefix = "",
}

vim.diagnostic.config({ virtual_text = false, float = border_opts })

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

-- use lsp formatting if it's available (and if it's good)
-- otherwise, fall back to null-ls
local preferred_formatting_clients = { "denols", "eslint" }
local fallback_formatting_client = "null-ls"

local formatting = function()
    local bufnr = api.nvim_get_current_buf()

    local selected_client
    for _, client in ipairs(lsp.get_active_clients()) do
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
    local result, err = selected_client.request_sync("textDocument/formatting", params, 5000, bufnr)
    if err then
        local err_msg = type(err) == "string" and err or err.message
        vim.notify("global.lsp.formatting: " .. err_msg, vim.log.levels.WARN)
        return
    end

    if result and result.result then
        lsp.util.apply_text_edits(result.result, bufnr)
    end
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
    u.lua_command("LspImplementation", "vim.lsp.buf.implementation()")
    u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev({ border = 'rounded' })")
    u.lua_command("LspDiagNext", "vim.diagnostic.goto_next({ border = 'rounded' })")
    u.lua_command("LspDiagLine", "vim.diagnostic.open_float(nil, global.lsp.border_opts)")
    u.lua_command("LspDiagLocList", "lua vim.diagnostic.setloclist()")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

    -- bindings
    u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
    u.buf_map("n", "gR", ":LspRename<CR>", nil, bufnr)
    u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
    u.buf_map("n", "[d", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]d", ":LspDiagNext<CR>", nil, bufnr)
    u.buf_map("n", "gs", ":LspSignatureHelp<CR>", nil, bufnr)
    u.buf_map("n", "gh", ":LspImplementation<CR>", nil, bufnr)
    u.buf_map("n", "gl", ":LspDiagLine<CR>", nil, bufnr)
    u.buf_map("n", "<leader>q", ":LspDiagLocList<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    -- telescope
    u.buf_map("n", "gr", ":LspRef<CR>", nil, bufnr)
    u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
    u.buf_map("n", "ga", ":LspAct<CR>", nil, bufnr)
    u.buf_map("v", "ga", "<Esc><cmd> LspRangeAct<CR>", nil, bufnr)

    if client.supports_method("textDocument/formatting") then
        vim.cmd("autocmd BufWritePre <buffer> lua global.lsp.formatting()")
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

for _, server in ipairs({
    "bashls",
    "denols",
    "eslint",
    "jsonls",
    "null-ls",
    "sumneko_lua",
    "tsserver",
}) do
    require("lsp." .. server).setup(on_attach, capabilities)
end

-- suppress lspconfig messages
local notify = vim.notify
vim.notify = function(msg, ...)
    if msg:match("%[lspconfig%]") then
        return
    end

    notify(msg, ...)
end
