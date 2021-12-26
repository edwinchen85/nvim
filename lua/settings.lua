-- hide vertical split
vim.cmd([[augroup VimEnter * highlight VertSplit guibg=bg guifg=bg]])

vim.cmd([[filetype plugin indent on]])

-- the only way I've found to make this persistent
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro indentkeys-=:")

-- vimdows to close with 'q'
vim.cmd([[autocmd FileType help,qf,fugitiveblame,netrw nnoremap <buffer><silent> q :close<CR>]])
vim.cmd([[autocmd FileType fugitive nmap <buffer><silent> q gq]])
