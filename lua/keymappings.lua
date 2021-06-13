local u = require("utils")

-- Dashboard
u.map('n', '<Leader>;', ':Dashboard<CR>')

-- Explorer
u.map('n', '<C-n>', ':NvimTreeToggle<CR>')
u.map('n', 'go', ':NvimTreeFindFile<CR>')

-- Buffer
u.map('n', 'X', ':Bdelete<CR>')
u.map('n', '<C-h>', ':BufPrev<CR>')
u.map('n', '<C-l>', ':BufNext<CR>')

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

-- Move selected line / block of text
u.map('n', '<C-j>', ':m .+1<CR>==')
u.map('n', '<C-k>', ':m .-2<CR>==')
u.map('v', '<C-j>', ":m '>+1<CR>gv=gv")
u.map('v', '<C-k>', ":m '<-2<CR>gv=gv")

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
u.map('n', 'cc', '"_cc')
u.map('n', 'cl', '"_cl')
u.map('n', 'c', '"_c')
u.map('v', 'c', '"_c')
u.map('n', 'C', '"_C')
u.map('n', 's', '"_s')
u.map('n', 'S', '"_S')

-- Place cursor at the end of yank in visual mode
u.map('v', 'y', 'ygv<ESC>')

-- Use . in visual mode to execute the dot command on each selected line
u.map('x', '.', ':normal .<CR>')

-- Delete last argument in comma separated list
u.map('n', 'dge', 'EdgE')

-- Avoid unintentional switches to Ex mode
u.map('n', 'Q', '<NOP>')

-- Can use <space> or <cr> to terminate wildmenu
u.map('c', '<Space>', [[wildmenumode() ? '<C-y>' : '<Space>']], { expr = true, silent = false })
u.map('c', '<CR>', [[wildmenumode() ? '<C-y>' : '<CR>']], { expr = true, silent = false })
