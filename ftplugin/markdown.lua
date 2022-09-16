vim.opt_local.textwidth = 80

vim.g.markdown_fenced_languages = { "lua", "typescript", "typescriptreact" }

vim.cmd([[
    nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
    nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
]])
