return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    config = function()
        -- Load custom snippets
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/typescript" } })
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/python" } })

        require("luasnip").filetype_extend("all", { "_" })
    end,
}
