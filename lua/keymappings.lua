local u = require("utils")

-- explorer
u.map('n', '<C-n>', ':NvimTreeToggle<CR>')
u.map('n', 'go', ':NvimTreeFindFile<CR>')

-- buffer
u.map('n', 'X', ':Bdelete<CR>')
