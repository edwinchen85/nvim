vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.autoread = true -- Read again when file has changed outside of vim
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard:append("unnamedplus")
vim.opt.colorcolumn = "9999" -- Hide color column
vim.opt.encoding = "utf-8" -- Set default encoding to UTF-8
vim.opt.expandtab = true -- Uses spaces instead of tabs
vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99
vim.opt.guifont = "JetBrainsMono Nerd Font" -- the font used in graphical neovim applications
vim.opt.hidden = true -- Enable background buffers
vim.opt.hlsearch = true -- Highlight found searches
vim.opt.ignorecase = true -- Ignore case
vim.opt.incsearch = true -- Shows the match while typing
vim.opt.inccommand = "nosplit" -- Shows the match while typing
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.linebreak = true -- Stop words being broken on wrap
vim.opt.list = true -- Show some invisible characters
vim.opt.listchars = { tab = "▸ ", trail = "·" }
vim.opt.mouse = "a"
vim.opt.pumheight = 10
vim.opt.shiftwidth = 4 -- Size of indent
vim.opt.shiftround = true -- Round indent
vim.opt.showcmd = false
vim.opt.showmode = true -- Don't display mode
vim.opt.showtabline = 0
vim.opt.laststatus = 3 -- Global status line
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.spelllang = "en"
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.diffopt = "algorithm:histogram,closeoff,hiddenoff,filler,indent-heuristic,internal,vertical"
vim.opt.tabstop = 4
vim.opt.termguicolors = true -- You will have bad experience for diagnostic messages when it's default 4000.
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.redrawtime = 10000 -- Allow more time to for loading syntax on large files
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.directory = "/tmp"
vim.opt.scrolloff = 8 -- Lines of context
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.shell = "/bin/zsh"
vim.opt.shortmess:append("cAS")
vim.opt.fillchars:append("eob: ")

vim.opt.cursorline = false
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes" -- Always show signcolumn
vim.opt.backupcopy = "yes"
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignorecase = true
vim.opt.wildignore:append(".git/**")
vim.opt.path:append("**")
vim.opt.title = true
vim.opt.confirm = true -- Ask for confirmation instead of erroring

-- Disable various builtin plugins in Vim that bog down speed
vim.g.loaded_matchparen = 1
vim.g.loaded_matchit = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_remote_plugins = 1

-- Initialize global object for config
global = {}

-- source remaining lua config
require("config")
require("plugins")
require("lsp")
