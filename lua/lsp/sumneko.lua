local lspconfig = require("lspconfig")

local root = vim.fn.getenv("HOME") .. "/git/lua-language-server/"
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
        on_attach = function(client)
            on_attach(client)
            vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
        end,
        cmd = { binary, "-E", root .. "main.lua" },
        settings = settings,
    })
end

return M
