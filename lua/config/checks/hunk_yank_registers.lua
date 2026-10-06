-- run with: nvim --headless -c 'luafile lua/config/checks/hunk_yank_registers.lua'
-- Needs the full config: drives the real `y`/`yy` keys (keymaps.lua remaps visual `y`)
-- over hunk lines and asserts every register the yank lands in comes out marker-free,
-- the clipboard ones included. A fake clipboard provider keeps the system one untouched.
local failures = {}
local function check(cond, msg)
    if not cond then
        table.insert(failures, msg)
    end
end

local store = {}
local function copy(reg)
    return function(lines, regtype)
        store[reg] = { lines, regtype }
    end
end
local function paste(reg)
    return function()
        return store[reg] or { {}, "v" }
    end
end
vim.g.clipboard = {
    name = "fake",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
}
vim.g.loaded_clipboard_provider = nil
vim.cmd("runtime autoload/provider/clipboard.vim")

-- Keys go through the main loop as typed input, one step at a time. Fed with "x" inside
-- this script, they would run in the script's command, where nvim holds clipboard writes
-- until it ends and then copies from `"`, so a yank that rewrites only `"` would pass.
local function finish()
    if #failures > 0 then
        io.stdout:write("hunk_yank_registers FAILED\n  " .. table.concat(failures, "\n  ") .. "\n")
        vim.cmd("cquit 1")
    end
    io.stdout:write("hunk_yank_registers ok\n")
    vim.cmd("qall!")
end

local function regs(label, expect)
    for _, reg in ipairs({ '"', "+", "*" }) do
        local got = vim.fn.getreg(reg)
        check(got == expect, ("%s: register %s = %q, want %q"):format(label, reg, got, expect))
    end
end

check(vim.o.clipboard:find("unnamedplus") ~= nil, "'clipboard' lacks unnamedplus; this check assumes it")
local buf = vim.api.nvim_create_buf(true, true)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "git"
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "@@ -1,2 +1,2 @@",
    "-    old()",
    "+    new()",
})

-- { cursor row, keys (remapped, so keymaps.lua's visual `y` applies), label, expected }
local steps = {
    { 2, "Vjy", "Vjy", "    old()\n    new()\n" },
    { 3, "yy", "yy", "    new()\n" },
    { 1, "Vjy", "header kept", "@@ -1,2 +1,2 @@\n-    old()\n" },
}
local function run(i)
    local step = steps[i]
    if not step then
        return finish()
    end
    local ok, err = pcall(vim.api.nvim_win_set_cursor, 0, { step[1], 0 })
    check(ok, tostring(err))
    vim.api.nvim_feedkeys(step[2], "t", false)
    vim.defer_fn(function()
        regs(step[3], step[4])
        run(i + 1)
    end, 50)
end
vim.schedule(function()
    run(1)
end)
