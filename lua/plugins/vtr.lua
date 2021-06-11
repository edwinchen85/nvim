local u = require("utils")

local format = string.format
local api = vim.api

local send_command = function(cmd)
    vim.cmd("silent! VtrSendCtrlC")
    vim.cmd(format("VtrSendCommandToRunner! %s", cmd))
end

local get_params = function()
    return vim.bo.filetype, vim.fn.bufname(api.nvim_get_current_buf())
end

local commands = {
    file = {
        lua = "FILE=%s make test-file",
        typescript = "npm run test -- %s",
        typescriptreact = "npm run test -- %s",
    },
    suite = {
        lua = "make test",
        typescript = "npm run test:cov",
        typescriptreact = "npm run test:cov",
    },
}

_G.global.vtr = {
    test = function()
        local ft, fname = get_params()
        send_command(format(commands.file[ft], fname))
    end,
    test_suite = function()
        local ft = get_params()
        send_command(commands.suite[ft])
    end,
}
u.command("VtrTest", "lua global.vtr.test()")
u.command("VtrTestSuite", "lua global.vtr.test_suite()")

u.augroup("VtrExit", "VimLeave", "silent! VtrKillRunner")

u.map("n", "<Leader>to", ":VtrOpenRunner<CR>")
u.map("n", "<Leader>tl", ":VtrFlushCommand<CR>")
u.map("n", "<Leader>tt", ":VtrSendCommandToRunner!<CR>")
u.map("n", "<Leader>tf", ":VtrTest<CR>")
u.map("n", "<Leader>ts", ":VtrTestSuite<CR>")
u.map("n", "<Leader>tk", ":VtrKillRunner<CR>")
u.map("n", "<Leader>ta", ":VtrSendFile<CR>")
