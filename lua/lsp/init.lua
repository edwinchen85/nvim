local u = require("utils")
local sumneko = require("lsp.sumneko")
local null_ls = require("lsp.null-ls")
local tsserver = require("lsp.tsserver")

local api = vim.api
local lsp = vim.lsp

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    signs = true,
    virtual_text = false,
})

lsp.util.close_preview_autocmd = function(events, winnr)
    events = vim.tbl_filter(function(v)
        return v ~= "CursorMovedI" and v ~= "BufLeave"
    end, events)

    api.nvim_command(
        "autocmd "
            .. table.concat(events, ",")
            .. " <buffer> ++once lua pcall(vim.api.nvim_win_close, "
            .. winnr
            .. ", true)"
    )
end

local popup_opts = { border = "single", focusable = false }

local peek_definition = function()
    vim.lsp.buf_request(0, "textDocument/definition", lsp.util.make_position_params(), function(_, _, result)
        if result == nil or vim.tbl_isempty(result) then
            return nil
        end
        lsp.util.preview_location(result[1], popup_opts)
    end)
end

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)

local go_to_diagnostic = function(pos)
    return pos and api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

local next_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_next_pos() or lsp.diagnostic.get_prev_pos())
end

local prev_diagnostic = function()
    go_to_diagnostic(lsp.diagnostic.get_prev_pos() or lsp.diagnostic.get_next_pos())
end

_G.global.lsp = {
    popup_opts = popup_opts,
    peek_definition = peek_definition,
    next_diagnostic = next_diagnostic,
    prev_diagnostic = prev_diagnostic,
}

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspPeekDef", "global.lsp.peek_definition()")
    u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
    u.lua_command("LspHover", "vim.lsp.buf.hover()")
    u.lua_command("LspRename", "vim.lsp.buf.rename()")
    u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
    u.lua_command("LspImplementation", "vim.lsp.buf.implementation()")
    u.lua_command("LspDiagPrev", "global.lsp.prev_diagnostic()")
    u.lua_command("LspDiagNext", "global.lsp.next_diagnostic()")
    u.lua_command("LspDiagLine", "vim.lsp.diagnostic.show_line_diagnostics(global.lsp.popup_opts)")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

    -- bindings
    u.buf_map("n", "gh", ":LspPeekDef<CR>", nil, bufnr)
    u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
    u.buf_map("n", "gR", ":LspRename<CR>", nil, bufnr)
    u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
    u.buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
    u.buf_map("n", "gs", ":LspSignatureHelp<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    u.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

    if client.resolved_capabilities.document_formatting then
        u.buf_augroup("LspFormatOnSave", "BufWritePost", "lua vim.lsp.buf.formatting()")
    end

    -- telescope
    u.buf_map("n", "ga", ":Telescope lsp_code_actions<CR>", nil, bufnr)
    u.buf_map("n", "gr", ":Telescope lsp_references<CR>", nil, bufnr)
    u.buf_map("n", "gd", ":Telescope lsp_definitions<CR>", nil, bufnr)
end

tsserver.setup(on_attach)
sumneko.setup(on_attach)
null_ls.setup(on_attach)
