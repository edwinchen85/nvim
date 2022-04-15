vim.g.solarized_italics = 1
vim.g.solarized_visibility = "normal"
vim.g.solarized_diffmode = "normal"
vim.g.solarized_statusline = "low"

if vim.fn.has("gui_running") == 0 then
    vim.g.solarized_termtrans = 0
else
    vim.g.solarized_termtrans = 1
end
