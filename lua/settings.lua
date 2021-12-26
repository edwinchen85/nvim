-- hide vertical split
vim.cmd([[augroup VimEnter * highlight VertSplit guibg=bg guifg=bg]])

vim.cmd([[filetype plugin indent on]])

-- the only way I've found to make this persistent
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro indentkeys-=:")
