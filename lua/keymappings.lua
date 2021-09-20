local u = require("utils")

-- Traverse start and end of line
u.map("n", "H", "^")
u.map("o", "H", "^")
u.map("x", "H", "^")
u.map("n", "L", "$")
u.map("o", "L", "$")
u.map("x", "L", "$")

-- Vertical Traversal
u.map('n', '<Down>', 'gj')
u.map('n', '<Up>', 'gk')

-- Automatically add jumps > 1 to jump list
u.map("n", "k", [[(v:count > 1 ? "m'" . v:count : '') . 'k'"]], { expr = true })
u.map("n", "j", [[(v:count > 1 ? "m'" . v:count : '') . 'j'"]], { expr = true })

-- Tab to jump to match
u.map("n", "<Tab>", "%", { noremap = false })
u.map("x", "<Tab>", "%", { noremap = false })
u.map("o", "<Tab>", "%", { noremap = false })

-- Terminal
u.map("n", "<Leader>T", ":term<CR>")
u.map("t", "<C-o>", "<C-\\><C-n>")

-- Useful remaps
u.map("n", "<BS>", "<C-^>")
u.map("n", "D", "d$")
u.map("n", "Y", "y$")
u.map("n", "<Leader>h", ":noh<CR>")

-- Dashboard
u.map('n', '<Leader>;', ':Dashboard<CR>')

-- Explorer
u.map('n', '<Leader>e', ':NvimTreeToggle<CR>')
u.map('n', '<Leader>n', ':NvimTreeFindFile<CR>')

-- Remove file
u.map('n', '<Leader>R', ':Remove<CR>')

-- Buffer
u.map('n', '<Leader>c', ':Bdelete<CR>')
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

-- Better join
u.map('n', 'J', 'mzJ`z')

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

-- Resize window
u.map('n', '<C-Up>', ':resize +2<CR>')
u.map('n', '<C-Down>', ':resize -2<CR>')
u.map('n', '<C-Left>', ':vertical resize +2<CR>')
u.map('n', '<C-Right>', ':vertical resize -2<CR>')

-- Better nav for omnicomplete
u.map('i', '<C-j>', '(\"\\<C-n>\")', { expr = true })
u.map('i', '<C-k>', '(\"\\<C-p>\")', { expr = true })

-- Fugitive
u.map('n', '<Leader>gg', ':G<CR><C-w>o:e<CR>')

-- Toggle Caps
u.map('i', '<C-u>', '<Esc>m`viw~``a')

-- Centering and open folds
u.map('n', 'n', 'nzzzv')
u.map('n', 'N', 'Nzzzv')

-- Centering only
u.map('n', 'G', 'Gzz')
u.map('n', '}', '}zz')
u.map('n', '{', '{zz')

-- Retrace previous movement in files
u.map('n', '``', '``zzzv')
-- Jump to last modification line
u.map('n', '\'.', '\'.zzzv')
-- Jump to exact spot in last modification line
u.map('n', '`.', '`.zzzv')

-- Sent to black hole register
u.map('n', 'cc', '"_cc')
u.map('n', 'cl', '"_cl')
u.map('n', 'c', '"_c')
u.map('v', 'c', '"_c')
u.map('n', 'C', '"_C')
u.map('n', 's', '"_s')
u.map('n', 'S', '"_S')

-- Search for visually selected text
u.map('v', '/', 'y/\\V<C-r>=escape(@",\'/\\\')<CR><CR>N', { noremap = false })

-- Place cursor at the end of yank in visual mode
u.map('v', 'y', 'ygv<ESC>')

-- Use . in visual mode to execute the dot command on each selected line
u.map('x', '.', ':normal .<CR>')

-- Delete last argument in comma separated list
u.map('n', 'dge', 'edgE')
u.map('n', 'dgE', 'EdgE')

-- Avoid unintentional switches to Ex mode
u.map('n', 'Q', ':Wwipeall<CR>')

-- Can use <space> or <cr> to terminate wildmenu
u.map('c', '<Space>', [[wildmenumode() ? '<C-y>' : '<Space>']], { expr = true, silent = false })
u.map('c', '<CR>', [[wildmenumode() ? '<C-y>' : '<CR>']], { expr = true, silent = false })

-- Can use <Esc> to cancel wildmenu selection
u.map('c', '<Esc>', [[wildmenumode() ? '<C-e>' : '<C-c>']], { expr = true, silent = false })

-- Can use <C-j> and <C-k> to move up and down in wild menu
u.map('c', '<C-j>', [[wildmenumode() ? '<Right>' : '<Down>']], { expr = true, silent = false })
u.map('c', '<C-k>', [[wildmenumode() ? '<Left>' : '<Up>']], { expr = true, silent = false })

-- EOL semicolon
u.map('n', '<C-s>', 'm`A;<Esc>``')
u.map('i', '<C-s>', '<Esc>A;<Esc>')

-- Select pasted text in visual mode
-- u.map('n', 'gp', '\'`[\' . strpart(getregtype(), 0, 1) . \'`]\'', { expr = true })

-- Paste without overwriting current registry
-- u.map('v', 'p', 'pgvy<Esc>')

-- Paste and indent
-- u.map('n', 'p', 'pm`V`]=<Esc>``')
-- u.map('n', 'P', 'Pm`V`]=<Esc>``')

-- Paste and indent and without overriding current register
-- u.map('x', 'p', 'pgvygp=<Esc>', { noremap = false })
-- u.map('x', 'P', 'Pgvygp=<Esc>', { noremap = false })

-- Toggle comment
u.map('n', '<Leader>/', 'gcc', { noremap = false })
u.map('x', '<Leader>/', 'gc', { noremap = false })

-- is.vim + Asterisk
u.map('n', 'n', '<Plug>(is-n)zzzv', { noremap = false })
u.map('n', 'N', '<Plug>(is-N)zzzv', { noremap = false })
u.map('n', '*', '<Plug>(asterisk-z*)<Plug>(is-nohl-1)', { noremap = false })
u.map('n', 'g*', '<Plug>(asterisk-gz*)<Plug>(is-nohl-1)', { noremap = false })
u.map('n', '#', '<Plug>(asterisk-z#)<Plug>(is-nohl-1)', { noremap = false })
u.map('n', 'g#', '<Plug>(asterisk-gz#)<Plug>(is-nohl-1)', { noremap = false })

-- Fold
u.map('n', 'zn', ':set foldenable!<CR>')
u.map('n', 'zi', ':set foldmethod=indent<CR>')
u.map('n', 'zs', ':set foldmethod=syntax<CR>')

-- Save
u.map('n', '<Leader>w', ':w<CR>')

-- Quit
u.map('n', '<Leader>q', ':q<CR>')

-- Undo break points
u.map('i', ',', ',<C-g>u')
u.map('i', '.', '.<C-g>u')
u.map('i', '!', '!<C-g>u')
u.map('i', '?', '?<C-g>u')
u.map("i", ";", ";<c-g>u")
u.map("i", ":", ":<c-g>u")
