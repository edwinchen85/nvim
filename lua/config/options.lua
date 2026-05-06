vim.keymap.set("n", "<space>", "", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable builtin plugins that bog down speed (including netrw)
for _, p in ipairs({
    "matchparen",
    "matchit",
    "logiPat",
    "rrhelper",
    "tarPlugin",
    "gzip",
    "zipPlugin",
    "2html_plugin",
    "shada_plugin",
    "spellfile_plugin",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "tutor_mode_plugin",
    "vimballPlugin",
    "getscriptPlugin",
    "remote_plugins",
}) do
    vim.g["loaded_" .. p] = 1
end

vim.opt.cmdheight = 1 -- more space in the neovim command line for displaying messages
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
vim.opt.autoread = true -- Read again when file has changed outside of vim
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard = "unnamed,unnamedplus" -- Enable access to system clipboard
vim.opt.colorcolumn = "" -- Disable color column
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99
vim.opt.guifont = "monospace:h17" -- the font used in graphical neovim applications
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
vim.opt.ruler = true -- Show cursor position in status line
vim.opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
vim.opt.shiftround = true -- Round indent
vim.opt.showcmd = false -- Don't show the command in the last line
vim.opt.showmode = false -- Don't display mode
vim.opt.showtabline = 0
vim.opt.laststatus = 3 -- Global status line
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.breakindent = true -- wrap lines with indent
vim.opt.spelllang = "en"
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.diffopt = "algorithm:histogram,closeoff,hiddenoff,filler,indent-heuristic,internal,vertical"
vim.opt.tabstop = 4
vim.opt.termguicolors = true -- You will have bad experience for diagnostic messages when it's default 4000.
vim.opt.wrap = false -- display lines as one long line
vim.opt.undofile = true
vim.opt.redrawtime = 10000 -- Allow more time to for loading syntax on large files
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.scrolloff = 8 -- Lines of context
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.shell = "/bin/zsh"
vim.opt.shortmess:append("cAS")
vim.opt.fillchars:append("eob: ")

vim.opt.cursorline = true -- required for CursorLineNr highlight to apply
vim.opt.cursorlineopt = "number" -- highlight number column only, no full-line underline
vim.opt.number = true -- Show line numbers
vim.opt.numberwidth = 4 -- set number column width to 2 {default 4}
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes:1" --  show the sign column, otherwise it would shift the text each time
vim.opt.backupcopy = "yes"
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignorecase = true
vim.opt.wildignore:append(".git/**")
vim.opt.path:append("**")
vim.opt.title = true
vim.opt.confirm = true -- Ask for confirmation instead of erroring
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Set completeopt to have a better completion experience

vim.filetype.add({
    extension = {
        env = "dotenv",
    },
    filename = {
        [".env"] = "dotenv",
        ["env"] = "dotenv",
    },
    pattern = {
        ["[jt]sconfig.*.json"] = "jsonc",
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})
