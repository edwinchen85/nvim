local u = require("utils")

-- Explorer
u.map('n', '<C-n>', ':NvimTreeToggle<CR>')
u.map('n', 'go', ':NvimTreeFindFile<CR>')

-- Buffer
u.map('n', 'X', ':Bdelete<CR>')

-- Maximizer
u.map('n', '<C-w>m', ':MaximizerToggle!<cr>')
