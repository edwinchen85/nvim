-- Kept only as cmp's snippet engine: cmp.lua calls `luasnip.lsp_expand` to
-- expand LSP completion snippets, and cmp_luasnip is a source. No snippet
-- collections are loaded.
return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
}
