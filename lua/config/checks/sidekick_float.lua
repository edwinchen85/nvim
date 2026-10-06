-- run with: nvim --headless -c 'luafile lua/config/checks/sidekick_float.lua'
-- Needs the full config (sidekick, smart-splits, lualine), so not `nvim -l`. Opens the CLI
-- float on a fake `sh` tool and drives the keys, asserting window geometry and state.
vim.o.columns, vim.o.lines = 200, 50

local failures = {}
local function check(cond, msg)
    if not cond then
        table.insert(failures, msg)
    end
end
local function keys(lhs)
    vim.api.nvim_feedkeys(vim.keycode(lhs), "xt", false)
end
local function backdrops()
    local n = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" and vim.w[win].sidekick_cli == nil then
            n = n + 1
        end
    end
    return n
end

local ok, err = pcall(function()
    require("lazy").load({ plugins = { "sidekick.nvim" } })
    local Config = require("sidekick.config")
    Config.cli.tools.shtest = { cmd = { "sh" } }
    Config.cli.win.float.width = 0.5

    local start = vim.api.nvim_get_current_win()
    require("sidekick.cli").toggle({ name = "shtest", focus = true })
    vim.wait(3000, function()
        return vim.w.sidekick_cli ~= nil
    end)
    local win = vim.api.nvim_get_current_win()
    check(vim.w[win].sidekick_cli ~= nil, "toggle did not focus the CLI float")
    local function geo()
        local c = vim.api.nvim_win_get_config(win)
        return c.col, c.width + 2, vim.api.nvim_win_get_height(win)
    end

    local col, width, height = geo()
    check(col == 100 and width == 100, ("side float at col %d width %d, want 100/100"):format(col, width))
    check(vim.api.nvim_win_get_config(win).title == nil, "float has a title")
    check(vim.o.laststatus == 0 and not vim.o.ruler, "statusline/ruler not hidden in the float")

    keys("<C-z>")
    col, width = geo()
    check(col == 0 and width >= 200, "<C-z> did not zoom to full screen")
    keys("<C-z>")
    col = geo()
    check(col == 100, "second <C-z> did not return to the side")

    keys("<M-,>")
    check(Config.cli.win.float.width == 0.55, "<M-,> did not widen by 5%")
    keys("<M-.>")
    keys("<M-.>")
    check(Config.cli.win.float.width == 0.45, "<M-.> did not narrow by 5%")
    keys("<M-=>")
    check(Config.cli.win.float.width == 0.5, "<M-=> did not reset to 50%")
    for _ = 1, 12 do
        keys("<M-,>")
    end
    check(Config.cli.win.float.width == 1, "width did not clamp at 1")
    keys("<M-=>")

    keys("<M-m>")
    col = geo()
    check(col == 50 and backdrops() == 1, "<M-m> did not center with a backdrop")

    keys("<C-h>")
    check(vim.api.nvim_get_current_win() == start, "<C-h> did not leave the float")
    check(backdrops() == 0, "backdrop still shown after leaving the float")
    check(vim.o.laststatus == 3 and vim.o.ruler, "statusline/ruler not restored after leaving")
    local _, _, h_out = geo()
    check(h_out == height, "float height changed on leave (pty resize)")

    keys("<C-l>")
    check(vim.api.nvim_get_current_win() == win, "<C-l> did not reach the float")
    check(backdrops() == 1, "backdrop not back after <C-l>")
    keys("<M-m>")

    -- <C-h> with no previous window falls back to the first split.
    vim.api.nvim_set_current_win(start)
    vim.cmd("vsplit")
    local tmp = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_close(tmp, true)
    keys("<C-h>")
    check(vim.api.nvim_get_current_win() == start, "<C-h> stuck with no previous window")

    keys("<C-l>")
    vim.api.nvim_win_close(win, true)
    check(backdrops() == 0, "backdrop left after closing the float")
    check(vim.o.laststatus == 3, "statusline not restored after closing the float")

    check(vim.v.errmsg == "", "v:errmsg: " .. vim.v.errmsg)
end)
if not ok then
    table.insert(failures, "error: " .. tostring(err))
end

if #failures > 0 then
    io.stdout:write("sidekick_float FAILED\n  " .. table.concat(failures, "\n  ") .. "\n")
    vim.cmd("cquit 1")
end
io.stdout:write("sidekick_float ok\n")
vim.cmd("qall!")
