-- hide vertical split
vim.cmd([[augroup VimEnter * highlight VertSplit guibg=bg guifg=bg]])

vim.cmd([[filetype plugin indent on]])

-- the only way I've found to make this persistent
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro indentkeys-=:")

-- vimdows to close with 'q'
vim.cmd([[autocmd FileType help,qf,fugitiveblame,netrw nnoremap <buffer><silent> q :close<CR>]])
vim.cmd([[autocmd FileType git nnoremap <buffer><silent> q <C-w>c]])
vim.cmd([[autocmd FileType fugitive nmap <buffer><silent> q gq]])

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
