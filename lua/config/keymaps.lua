local u = require("config.utils")

-- Prevent tab map to override control i
u.nmap("<C-i>", "<C-i>", { noremap = true, silent = true })

-- Vertical Traversal
u.nmap("<Down>", "gj")
u.nmap("<Up>", "gk")

-- Traverse start and end of line
u.map({ "n", "o", "x" }, "H", "^")
u.map({ "n", "o", "x" }, "L", "g_")

-- Automatically add jumps > 1 to jump list
u.nmap("k", [[(v:count > 1 ? "m'" . v:count : '') . 'gk'"]], { expr = true })
u.nmap("j", [[(v:count > 1 ? "m'" . v:count : '') . 'gj'"]], { expr = true })

-- Tab to jump to match
u.map({ "n", "x", "o" }, "<Tab>", "%", { remap = true })

-- Terminal
u.tmap("<C-o>", "<C-\\><C-n>")

-- Maximizer
u.nmap("<C-w>m", ":MaximizerToggle!<cr>")

-- Better join
u.nmap("J", "mzJ`z")

-- Better indenting
u.xmap("<", "<gv")
u.xmap(">", ">gv")

-- Window navigation: <C-hjkl> bound by smart-splits plugin (nvim + tmux fallthrough)

-- Page up down and center
for _, d in ipairs({ "f", "b", "u", "d" }) do
    u.nmap("<C-" .. d .. ">", "<C-" .. d .. ">zz")
end

-- Close window
u.nmap("<C-c>", "<C-w>c")

-- Move selected line / block of text
u.xmap("<m-j>", ":m '>+1<CR>gv=gv")
u.xmap("<m-k>", ":m '<-2<CR>gv=gv")
u.nmap("<m-j>", ":m .+1<CR>==")
u.nmap("<m-k>", ":m .-2<CR>==")

-- Resize window
u.nmap("<C-Down>", ":resize +2<CR>")
u.nmap("<C-Up>", ":resize -2<CR>")
u.nmap("<C-Left>", ":vertical resize +2<CR>")
u.nmap("<C-Right>", ":vertical resize -2<CR>")

-- Insert clipboard content without messing up indentation
u.imap("<C-v>", "<C-r><C-p>*")

-- Forward delete line
u.imap("<C-k>", "<C-o>D")

-- Centering only
u.nmap("G", "Gzz")

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

-- Search for visually selected text
u.xmap("/", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>N", { remap = true })

-- Place cursor at the end of yank in visual mode
u.xmap("y", "ygv<ESC>")

-- Use . in visual mode to execute the dot command on each selected line
u.xmap(".", ":normal .<CR>")

-- Delete, yank last argument in comma separated list
u.nmap("dge", "EdgE")
u.nmap("yge", "EygE")

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
u.nmap("<C-;>", "m`A;<Esc>``")
u.imap("<C-;>", "<Esc>A;<Esc>")

-- Select pasted text in visual mode
u.nmap("gp", "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Paste and indent
u.nmap("p", "pm`V`]=<Esc>``")
u.nmap("P", "Pm`V`]=<Esc>``")

-- Paste and indent without overriding current register
u.xmap("p", "pgvygp=<Esc>", { remap = true })
u.xmap("P", "Pgvygp=<Esc>", { remap = true })

-- is.vim + Asterisk
u.nmap("n", "<Plug>(is-nohl)nzz<Cmd>lua require('hlslens').start()<CR>", { remap = false })
u.nmap("N", "<Plug>(is-nohl)Nzz<Cmd>lua require('hlslens').start()<CR>", { remap = false })
u.nmap("*", "<Plug>(asterisk-z*)<Plug>(is-nohl-1)<Cmd>lua require('hlslens').start()<CR>", { remap = true })
u.nmap("g*", "<Plug>(asterisk-gz*)<Plug>(is-nohl-1)<Cmd>lua require('hlslens').start()<CR>", { remap = true })
u.nmap("#", "<Plug>(asterisk-z#)<Plug>(is-nohl-1)<Cmd>lua require('hlslens').start()<CR>", { remap = true })
u.nmap("g#", "<Plug>(asterisk-gz#)<Plug>(is-nohl-1)<Cmd>lua require('hlslens').start()<CR>", { remap = true })

-- Undo break points
for _, char in ipairs({ ",", ".", "!", "?", ";", ":" }) do
    u.imap(char, char .. "<C-g>u")
end

-- Shortcut to command mode
u.nmap(";", ":", { silent = false })
u.xmap(";", ":", { silent = false })

-- Shortcut to bang
u.nmap("!", ":!", { silent = false })

-- Exclude {, }, ( and ) in jump list
for _, m in ipairs({ "}", "{", ")", "(" }) do
    u.nmap(m, ":<C-u>execute 'keepjumps normal!' v:count1 . '" .. m .. "zz'<CR>")
end

-- Column increment / decrement
u.xmap("g+", "g<C-a>", { remap = true })
u.xmap("g-", "g<C-x>", { remap = true })

-- Notification history (Snacks notifier)
u.nmap("<leader>nh", "<cmd>lua Snacks.notifier.show_history()<cr>")

-- Open current file in Finder
local function open_in_file_manager()
    local file_path = vim.fn.expand("%:p")
    if file_path ~= "" then
        vim.fn.system("open -R " .. vim.fn.shellescape(file_path))
    else
        vim.notify("No file is currently open", vim.log.levels.WARN)
    end
end

vim.keymap.set("n", "<M-o>", open_in_file_manager, { desc = "Open file" })

-- Permanent "very magic" mode via nmap (fires before CmdlineEnter, cmp keyword_pattern handles \v prefix)
vim.keymap.set("n", "/", "/\\v", { noremap = true })
vim.keymap.set("n", "?", "?\\v", { noremap = true })
vim.keymap.set("c", "%s/", "%smagic/", { silent = true })
vim.keymap.set("c", "\\>s/", "\\>smagic/", { silent = true })
-- conflict with snack commands and command history
-- u.nmap(":g/", ":g/\\v")
-- u.nmap(":g//", ":g//")

-- Restore vim-unimpaired conflict marker navigation in visual mode
-- nvim 0.12 defaults.lua overwrites [n/]n in xmode with treesitter node select
u.xmap("[n", "<Plug>(unimpaired-context-previous)", { remap = true })
u.xmap("]n", "<Plug>(unimpaired-context-next)", { remap = true })

-- Merge conflict resolution keybindings
require("which-key").add({ { "<leader>x", group = "Conflict" } })

vim.keymap.set("n", "<leader>xo", function()
    vim.cmd("%s/^<<<<<<<.*\\n\\(\\_.\\{-}\\)=======.*\\n\\_.\\{-}>>>>>>>.*\\n/\\1/e")
end, { desc = "Accept ours (current branch)" })

vim.keymap.set("n", "<leader>xt", function()
    vim.cmd("%s/^<<<<<<<.*\\n\\_.\\{-}=======.*\\n\\(\\_.\\{-}\\)>>>>>>>.*\\n/\\1/e")
end, { desc = "Accept theirs (incoming branch)" })

vim.keymap.set("n", "<leader>xb", function()
    vim.cmd("%s/^<<<<<<<.*\\n\\(\\_.\\{-}\\)=======.*\\n\\(\\_.\\{-}\\)>>>>>>>.*\\n/\\1\\2/e")
end, { desc = "Accept both" })
