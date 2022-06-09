local api = vim.api
-- Use spelling for markdown files ]s to find next, [s for previous, z= for suggestions when on one.
-- Source: http:--thejakeharding.com/tutorial/2012/06/13/using-spell-check-in-vim.html
vim.api.nvim_exec(
    [[
augroup markdownSpell
autocmd!
autocmd FileType markdown,md,txt setlocal spell
autocmd BufRead,BufNewFile *.md,*.txt,*.markdown setlocal spell
augroup END
]],
    false
)

api.nvim_create_autocmd("BufEnter", { command = "setlocal formatoptions-=cro indentkeys-=:" })

-- vimdows to close with 'q'
vim.cmd([[autocmd FileType help,qf,fugitiveblame,netrw nnoremap <buffer><silent> q :close<CR>]])
vim.cmd([[autocmd FileType git nnoremap <buffer><silent> q <C-w>c]])
vim.cmd([[autocmd FileType fugitive,GV nmap <buffer><silent> q gq]])

-- treesitter powered fold
local parsers = require("nvim-treesitter.parsers")
local configs = parsers.get_parser_configs()
local ft_str = table.concat(
    vim.tbl_map(function(ft)
        return configs[ft].filetype or ft
    end, parsers.available_parsers()),
    ","
)
vim.cmd("autocmd Filetype " .. ft_str .. " setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()")

-- define custom Browse command to use GBrowse with range
vim.cmd([[ command! -bar -nargs=1 Browse silent! exe '!open' shellescape(<q-args>, 1) ]])
