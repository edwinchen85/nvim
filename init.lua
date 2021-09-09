vim.g.mapleader = " "

vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = 'utf-8' -- Set default encoding to UTF-8
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.expandtab = true -- Uses spaces instead of tabs
vim.opt.foldenable = false
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99
vim.opt.hidden = true -- Enable background buffers
vim.opt.hlsearch = true -- Highlight found searches
vim.opt.ignorecase = true -- Ignore case
vim.opt.incsearch = true -- Shows the match while typing
vim.opt.inccommand = "split" -- Shows the match while typing
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.linebreak = true -- Stop words being broken on wrap
vim.opt.list = false -- Show some invisible characters
vim.opt.cc = "120"
vim.opt.mouse = "a"
vim.opt.pumheight = 10
vim.opt.shiftwidth = 4 -- Size of indent
vim.opt.shiftround = true -- Round indent
vim.opt.showcmd = false
vim.opt.showmode = false -- Don't display mode
vim.opt.showtabline = 2
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.spelllang = "en"
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.diffopt = "vertical,filler"
vim.opt.statusline = [[%f %y %m %= %p%% %l:%c]]
vim.opt.tabstop = 4
vim.opt.termguicolors = true -- You will have bad experience for diagnostic messages when it's default 4000.
vim.opt.wrap = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.directory = "/tmp"
vim.opt.scrolloff = 8 -- Lines of context
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.shell = "/bin/sh"
vim.opt.shortmess:append("cA")

vim.opt.cursorline = true
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1" -- Always show signcolumn
vim.opt.backupcopy = "yes"

-- the only way I've found to make this persistent
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

_G.global = {}

-- source remaining lua config
require("keymappings")
require("commands")
require("plugins")
require("theme")
require("lsp")
