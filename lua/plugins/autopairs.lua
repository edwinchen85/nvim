local npairs = require("nvim-autopairs")
local Rule = require('nvim-autopairs.rule')
local u = require("utils")

npairs.setup({
    check_ts = true,
    ignored_next_char = "[%w%.]",
    check_line_pair = false,
    ts_config = {
        lua = {'string'},-- it will not add pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})

_G.global.on_enter = function()
    if vim.fn.pumvisible() ~= 0  then
      if vim.fn.complete_info()["selected"] ~= -1 then
        return vim.fn["compe#confirm"](npairs.esc("<cr>"))
      else
        return npairs.esc("<cr>")
      end
    else
      return npairs.autopairs_cr()
    end
end

u.map("i", "<CR>", "v:lua.global.on_enter()", { expr = true })

require('nvim-treesitter.configs').setup {
    autopairs = {enable = true}
}

local ts_conds = require('nvim-autopairs.ts-conds')

-- press % => %% is only inside comment or string
npairs.add_rules({
  Rule("%", "%", "lua")
    :with_pair(ts_conds.is_ts_node({'string','comment'})),
  Rule("$", "$", "lua")
    :with_pair(ts_conds.is_not_ts_node({'function'}))
})

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
