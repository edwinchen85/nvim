-- Load custom snippets
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/typescript" } })
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/python" } })

require("luasnip").filetype_extend("all", { "_" })
