-- Initialize global object for config
global = {}

-- macOS: a parent (login env, figterm/Amazon Q, Xcode/Instruments) may export
-- MallocStackLogging via `launchctl setenv`. nvim inherits it, and when nvim
-- forks a git job, the child tries to disable logging that was never enabled and
-- prints "MallocStackLogging: can't turn off malloc stack logging..." to stderr,
-- which fugitive captures into its status buffer. Strip it from our env so any
-- forked subprocess never inherits it.
vim.env.MallocStackLogging = nil

-- resolve <c-i> mapping and it is still not working in tmux, not sure without tmux
if vim.env.TERM == "xterm-kitty" or vim.env.TERM == "screen-256color" then
    vim.cmd([[autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif]])
    vim.cmd([[autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif]])
end

-- source remaining lua config
require("config.options")
require("core.lazy")
require("core.lsp")
-- require "lsp"
require("config.commands")
require("config.keymaps")
require("config.settings")

-- kept in a separate repository to avoid noisy changes
pcall(require, "config.theme")
