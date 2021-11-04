require("Comment").setup({
    -- integrate with nvim-ts-context-commentstring
    pre_hook = function(ctx)
        if not vim.tbl_contains({ "typescript", "typescriptreact" }, vim.bo.ft) then
            return
        end

        local type = ctx.ctype == require("Comment.utils").ctype.line and "__default" or "__multiline"
        return require("ts_context_commentstring.internal").calculate_commentstring({
            key = type,
        })
    end,
})
