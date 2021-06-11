local npairs = require("nvim-autopairs")
local Rule = require('nvim-autopairs.rule')
local u = require("utils")

npairs.setup({
    check_ts = true,
    ignored_next_char = "[%w%.]",
    check_line_pair = false,
})

_G.global.on_enter = function()
    return npairs.autopairs_cr()
end
u.map("i", "<CR>", "v:lua.global.on_enter()", { expr = true })

-- Add spaces between parentheses
npairs.add_rules {
  Rule(' ', ' ')
    :with_pair(function (opts)
      local pair = opts.line:sub(opts.col, opts.col + 1)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
  Rule('( ',' )')
        :with_pair(function() return false end)
        :with_move(function() return true end)
        :use_key(")")
}
