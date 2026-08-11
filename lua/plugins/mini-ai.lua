-- mini.ai: a/i textobjects (brackets, quotes, tags, calls, arguments),
-- replaces targets.vim. Adds a `,` separator textobject to match
-- targets.vim's `da,`/`di,`.
return {
    "echasnovski/mini.ai",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local ai = require("mini.ai")
        ai.setup({
            custom_textobjects = {
                [","] = ai.gen_spec.pair(",", ",", { type = "non-balanced" }),
            },
        })
    end,
}
