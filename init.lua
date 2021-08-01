vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.expandtab = true
vim.opt.foldlevelstart = 99
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"
vim.opt.pumheight = 10
vim.opt.shiftwidth = 4
vim.opt.showcmd = false
vim.opt.showtabline = 2
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.statusline = [[%f %y %m %= %p%% %l:%c]]
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.directory = "/tmp"
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 2
vim.opt.shell = "/bin/sh"
vim.opt.shortmess:append("cA")

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
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
