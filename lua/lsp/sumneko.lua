local lspconfig = require("lspconfig")

local u = require("utils")

local root = vim.fn.getenv("HOME") .. "/.local/share/nvim/lspinstall/lua/sumneko-lua-language-server/"
local binary = root .. "bin/macOS/lua-language-server"
local settings = {
    Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
            enable = true,
            globals = {
                "vim",
                "use",
                "describe",
                "it",
                "assert",
                "before_each",
                "after_each",
            },
        },
    },
}

local M = {}
M.setup = function(on_attach)
    lspconfig.sumneko_lua.setup({
        on_attach = function(client, bufnr)
            on_attach(client)
            vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
            u.buf_map("i", ".", ".<C-x><C-o>", nil, bufnr)
        end,
        cmd = { binary, "-E", root .. "main.lua" },
        settings = settings,
    })
end

return M
