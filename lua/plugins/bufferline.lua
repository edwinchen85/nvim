vim.g.bufferline = {
    icons = true,
    animation = false,
    auto_hide = false,
    maximum_padding = 2,
    maximum_length = 30,
    exclude_ft = {'dashboard', 'nvimtree'},
    no_name_title = 'No Name',
    icon_separator_active = '',
    icon_separator_inactive = '',
}

-- disable tabline in dashboard buffer
vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
