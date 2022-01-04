local status_ok, comment = pcall(require, "Comment")
if not status_ok then
    return
end

comment.setup({
    active = true,
    on_config_done = nil,

    ---Add a space b/w comment and the line
    ---@type boolean
    padding = true,

    ---Lines to be ignored while comment/uncomment.
    ---Could be a regex string or a function that returns a regex string.
    ---Example: Use '^$' to ignore empty lines
    ---@type string|function
    ignore = "^$",

    ---Whether to create basic (operator-pending) and extra mappings for NORMAL/VISUAL mode
    ---@type table
    mappings = {
        ---operator-pending mapping
        ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
        basic = true,
        ---extended mapping
        ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
        extra = false,
    },

    ---LHS of line and block comment toggle mapping in NORMAL/VISUAL mode
    ---@type table
    toggler = {
        ---line-comment toggle
        line = "gcc",
        ---block-comment toggle
        block = "gbc",
    },

    ---LHS of line and block comment operator-mode mapping in NORMAL/VISUAL mode
    ---@type table
    opleader = {
        ---line-comment opfunc mapping
        line = "gc",
        ---block-comment opfunc mapping
        block = "gb",
    },

    ---Pre-hook, called before commenting the line
    ---@type function|nil
    pre_hook = function(ctx)
        if not vim.tbl_contains({ "typescript", "typescriptreact" }, vim.bo.ft) then
            return
        end

        local comment_utils = require("Comment.utils")
        local type = ctx.ctype == comment_utils.ctype.line and "__default" or "__multiline"

        local location
        if ctx.ctype == comment_utils.ctype.block then
            location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == comment_utils.cmotion.v or ctx.cmotion == comment_utils.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return require("ts_context_commentstring.internal").calculate_commentstring({
            key = type,
            location = location,
        })
    end,

    ---Post-hook, called after commenting is done
    ---@type function|nil
    post_hook = nil,
})
