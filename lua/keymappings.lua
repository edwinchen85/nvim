local u = require("utils")

-- Vertical Traversal
u.nmap("<Down>", "gj")
u.nmap("<Up>", "gk")

-- Automatically add jumps > 1 to jump list
u.nmap("k", [[(v:count > 1 ? "m'" . v:count : '') . 'gk'"]], { expr = true })
u.nmap("j", [[(v:count > 1 ? "m'" . v:count : '') . 'gj'"]], { expr = true })

-- Tab to jump to match
u.nmap("<Tab>", "%", { noremap = false })
u.xmap("<Tab>", "%", { noremap = false })
u.omap("<Tab>", "%", { noremap = false })

-- Terminal
u.nmap("<Leader>T", ":term<CR>")
u.tmap("<C-o>", "<C-\\><C-n>")

-- Useful remaps
u.nmap("D", "d$")
u.nmap("Y", "y$")
u.nmap("<Leader>h", ":noh<CR>")

-- Dashboard
u.nmap("<Leader>a", ":Alpha<CR>")

-- Explorer
u.nmap("<Leader>e", ":NvimTreeToggle<CR>")

-- Buffer
u.nmap("<Leader>c", ":Bdelete!<CR>")
u.nmap("<Leader>C", ":bufdo Bdelete!<CR>")

-- Maximizer
u.nmap("<C-w>m", ":MaximizerToggle!<cr>")

-- Find file
u.nmap("<C-p>", ":Telescope find_files<CR>")

-- Telescope buffers
u.nmap(
    "<Leader>b",
    [[<Cmd>lua require("telescope.builtin").buffers({results_title='﬘', winblend = 0, layout_strategy = 'vertical', previewer = false, layout_config = { width = 0.5, height = 0.4 }})<CR>]]
)

-- Jump to previous buffer
u.nmap("<Leader><Leader>", "<C-^>")

-- Jump forward
u.nmap("<Leader>i", "<C-i>")

-- Better join
u.nmap("J", "mzJ`z")

-- Better indenting
u.xmap("<", "<gv")
u.xmap(">", ">gv")

-- Better window navigation
u.nmap("<C-h>", "<C-w>h")
u.nmap("<C-j>", "<C-w>j")
u.nmap("<C-k>", "<C-w>k")
u.nmap("<C-l>", "<C-w>l")

-- Close window
u.nmap("<C-c>", "<C-w>c")

-- Move selected line / block of text
u.xmap("<C-j>", ":m '>+1<CR>gv=gv")
u.xmap("<C-k>", ":m '<-2<CR>gv=gv")

-- Resize window
u.nmap("<C-Up>", ":resize +2<CR>")
u.nmap("<C-Down>", ":resize -2<CR>")
u.nmap("<C-Left>", ":vertical resize +2<CR>")
u.nmap("<C-Right>", ":vertical resize -2<CR>")

-- Better nav for omnicomplete
u.imap("<C-j>", '("\\<C-n>")', { expr = true })
u.imap("<C-k>", '("\\<C-p>")', { expr = true })

-- Paste in insert mode
u.imap("<C-v>", "<C-r>+")

-- Fugitive
u.nmap("<Leader>gg", ":aboveleft G<CR>")

-- Toggle Caps
u.imap("<C-u>", "<Esc>m`viw~``a")

-- Centering only
u.nmap("G", "Gzz")
u.nmap("}", "}zz")
u.nmap("{", "{zz")

-- Retrace previous movement in files
u.nmap("``", "``zzzv")
-- Jump to last modification line
u.nmap("'.", "'.zzzv")
-- Jump to exact spot in last modification line
u.nmap("`.", "`.zzzv")

-- Sent to black hole register
u.nmap("cc", '"_cc')
u.nmap("cl", '"_cl')
u.nmap("c", '"_c')
u.xmap("c", '"_c')
u.nmap("C", '"_C')
u.nmap("s", '"_s')
u.nmap("S", '"_S')

-- Search for visually selected text
u.xmap("/", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>N", { noremap = false })

-- Place cursor at the end of yank in visual mode
u.xmap("y", "ygv<ESC>")

-- Use . in visual mode to execute the dot command on each selected line
u.xmap(".", ":normal .<CR>")

-- Repeat previous command
u.nmap("<Leader>;", ":@:<CR>")

-- Delete last argument in comma separated list
u.nmap("dge", "edgE")
u.nmap("dgE", "EdgE")

-- Avoid unintentional switches to Ex mode
u.nmap("Q", ":Wwipeall<CR>")

-- Can use <space> or <cr> to terminate wildmenu
u.cmap("<Space>", [[wildmenumode() ? '<C-y>' : '<Space>']], { expr = true, silent = false })
u.cmap("<CR>", [[wildmenumode() ? '<C-y>' : '<CR>']], { expr = true, silent = false })

-- Can use <Esc> to cancel wildmenu selection
u.cmap("<Esc>", [[wildmenumode() ? '<C-e>' : '<C-c>']], { expr = true, silent = false })

-- Can use <C-j> and <C-k> to move up and down in wild menu
u.cmap("<C-j>", [[wildmenumode() ? '<Right>' : '<Down>']], { expr = true, silent = false })
u.cmap("<C-k>", [[wildmenumode() ? '<Left>' : '<Up>']], { expr = true, silent = false })

-- EOL semicolon
u.nmap("<C-s>", "m`A;<Esc>``")
u.imap("<C-s>", "<Esc>A;<Esc>")

-- Select pasted text in visual mode
u.nmap("gp", "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Paste without overwriting current registry
u.xmap("p", "pgvy<Esc>")

-- Paste and indent
u.nmap("p", "pm`V`]=<Esc>``")
u.nmap("P", "Pm`V`]=<Esc>``")

-- Paste and indent and without overriding current register
u.xmap("p", "pgvygp=<Esc>", { noremap = false })
u.xmap("P", "Pgvygp=<Esc>", { noremap = false })

-- Toggle comment
u.nmap("<Leader>/", "gcc", { noremap = false })
u.xmap("<Leader>/", "gc", { noremap = false })

-- is.vim + Asterisk
u.nmap("n", "<Plug>(is-nohl)zzzv<Plug>(anzu-n-with-echo)", { noremap = false })
u.nmap("N", "<Plug>(is-nohl)zzzv<Plug>(anzu-N-with-echo)", { noremap = false })
u.nmap("*", "<Plug>(asterisk-z*)<Plug>(is-nohl-1)", { noremap = false })
u.nmap("g*", "<Plug>(asterisk-gz*)<Plug>(is-nohl-1)", { noremap = false })
u.nmap("#", "<Plug>(asterisk-z#)<Plug>(is-nohl-1)", { noremap = false })
u.nmap("g#", "<Plug>(asterisk-gz#)<Plug>(is-nohl-1)", { noremap = false })

-- Fold
u.nmap("zn", ":set foldenable!<CR>")
u.nmap("ze", ":set foldmethod=expr<CR>")
u.nmap("zi", ":set foldmethod=indent<CR>")
u.nmap("zs", ":set foldmethod=syntax<CR>")

-- Save
u.nmap("<Leader>w", ":w<CR>")

-- Zen Mode
u.nmap("<Leader>z", ":ZenMode<CR>")

-- Undo break points
u.imap(",", ",<C-g>u")
u.imap(".", ".<C-g>u")
u.imap("!", "!<C-g>u")
u.imap("?", "?<C-g>u")
u.imap(";", ";<c-g>u")
u.imap(":", ":<c-g>u")

-- Shortcut to command mode
u.nmap(";", ":", { silent = false })
u.xmap(";", ":", { silent = false })

-- Swap interactive
u.nmap("gS", "<Plug>(swap-interactive)", { noremap = false })

-- Source luafile
u.nmap("<Leader>sv", ":luafile %<CR>")

-- Exclude {, }, ( and ) in jump list
u.nmap("}", ":<C-u>execute 'keepjumps normal!' v:count1 . '}zz'<CR>")
u.nmap("{", ":<C-u>execute 'keepjumps normal!' v:count1 . '{zz'<CR>")
u.nmap(")", ":<C-u>execute 'keepjumps normal!' v:count1 . ')zz'<CR>")
u.nmap("(", ":<C-u>execute 'keepjumps normal!' v:count1 . '(zz'<CR>")

-- Increment / Decrement
u.nmap("+", "<C-a>")
u.nmap("-", "<C-x>")

-- Rest.nvim
u.nmap("<Leader>R", "<Plug>RestNvim", { noremap = false })
