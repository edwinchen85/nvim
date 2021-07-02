local u = require("utils")

vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menuone", "noinsert" }
vim.opt.expandtab = true
vim.opt.foldlevelstart = 99
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"
vim.opt.pumheight = 10
vim.opt.shiftwidth = 4
vim.opt.shortmess:append("cA")
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

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

vim.g.backupcopy = "yes"
_G.global = {}

-- terminal
_G.global.terminal = {
    on_open = function()
        vim.cmd("startinsert")
        vim.cmd("setlocal nonumber norelativenumber")
    end,

    -- suppress exit code message
    on_close = function()
        if not string.match(vim.fn.expand("<afile>"), "nnn") then
            vim.api.nvim_input("<CR>")
        end
    end,
}

u.augroup("OnTermOpen", "TermOpen", "lua global.terminal.on_open()")
u.augroup("OnTermClose", "TermClose", "lua global.terminal.on_close()")

-- maps
u.map("i", "<S-Tab>", "<Esc>A")

u.map("n", "H", "^")
u.map("o", "H", "^")
u.map("x", "H", "^")
u.map("n", "L", "$")
u.map("o", "L", "$")
u.map("x", "L", "$")

u.map("n", "<Leader>T", ":term<CR>")
u.map("t", "<C-o>", "<C-\\><C-n>")

u.map("n", "<Tab>", "%", { noremap = false })
u.map("x", "<Tab>", "%", { noremap = false })
u.map("o", "<Tab>", "%", { noremap = false })

u.map("n", "<BS>", "<C-^>")
u.map("n", "D", "d$")
u.map("n", "Y", "y$")
u.map("n", "<Leader>/", ":noh<CR>")

-- automatically add jumps > 1 to jump list
u.map("n", "k", [[(v:count > 1 ? "m'" . v:count : '') . 'k'"]], { expr = true })
u.map("n", "j", [[(v:count > 1 ? "m'" . v:count : '') . 'j'"]], { expr = true })

-- source remaining lua config
require("keymappings")
require("commands")
require("plugins")
require("theme")
require("lsp")
