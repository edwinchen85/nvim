local u = require("utils")

-- Explorer
u.map('n', '<C-n>', ':NvimTreeToggle<CR>')
u.map('n', 'go', ':NvimTreeFindFile<CR>')

-- Buffer
u.map('n', 'X', ':Bdelete<CR>')

-- Maximizer
u.map('n', '<C-w>m', ':MaximizerToggle!<cr>')

-- Find file
u.map('n', '<C-p>', ':Telescope find_files<CR>')

-- Telescope buffers
u.map('n', '<Leader><CR>', ':Telescope buffers<CR>')

-- Jump to previous buffer
u.map('n', '<Leader><Leader>', '<C-^>')

-- Jump forward
u.map('n', '<Leader>i', '<C-i>')

-- Better indenting
u.map('n', '<', '<<')
u.map('n', '>', '>>')
u.map('v', '<', '<gv')
u.map('v', '>', '>gv')

-- Better nav for omnicomplete
vim.cmd('inoremap <expr> <c-j> (\"\\<C-n>\")')
vim.cmd('inoremap <expr> <c-k> (\"\\<C-p>\")')

-- Fugitive
u.map('n', '<Leader>gg', ':G<CR><C-w>o')

-- Toggle Caps
u.map('i', '<C-u>', '<Esc>m`viw~``a')

-- Centering
u.map('n', 'G', 'Gzz')
u.map('n', 'n', 'nzz')
u.map('n', 'N', 'Nzz')
u.map('n', '}', '}zz')
u.map('n', '{', '{zz')

-- Retrace previous movement in files
u.map('n', '``', '``zz')
-- Jump to last modification line
u.map('n', '\'.', '\'.zz')
-- Jump to exact spot in last modification line
u.map('n', '`.', '`.zz')

-- Traversal
u.map('n', '<Down>', 'gj')
u.map('n', '<Up>', 'gk')

-- Sent to black hole register
vim.api.nvim_set_keymap('n', 'cc', '"_cc', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'cl', '"_cl', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'c', '"_c', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 'c', '"_c', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'C', '"_C', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 's', '"_s', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'S', '"_S', {noremap = true, silent = true})

-- Use . in visual mode to execute the dot command on each selected line
vim.api.nvim_set_keymap('x', '.', ':normal .<CR>', {noremap = true})

-- Delete last argument in comma separated list
vim.api.nvim_set_keymap('n', 'dge', 'EdgE', {noremap = true, silent = true})

-- Avoid unintentional switches to Ex mode
vim.api.nvim_set_keymap('n', 'Q', '<NOP>', {noremap = true, silent = true})

-- Can use <space> or <cr> to terminate wildmenu
vim.cmd('cnoremap <expr> <space> wildmenumode() ? \"\\<C-y>\" : \"\\<space>\"')
vim.cmd('cnoremap <expr> <cr> wildmenumode() ? \"\\<C-y>\" : \"\\<cr>\"')
