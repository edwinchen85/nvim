local format = string.format
local uv = vim.loop
local api = vim.api

local get_map_options = function(custom_options)
    local options = { noremap = true, silent = true }
    if custom_options then
        options = vim.tbl_extend("force", options, custom_options)
    end
    return options
end

local M = {}

M.map = function(mode, target, source, opts)
    api.nvim_set_keymap(mode, target, source, get_map_options(opts))
end

M.buf_map = function(mode, target, source, opts, bufnr)
    api.nvim_buf_set_keymap(bufnr, mode, target, source, get_map_options(opts))
end

M.for_each = function(tbl, cb)
    for _, v in ipairs(tbl) do
        cb(v)
    end
end

M.start_case = function(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

M.replace = function(str, original, replacement)
    local found, found_end = string.find(str, original, nil, true)
    if not found then
        return
    end

    if str == original then
        return replacement
    end

    local first_half = string.sub(str, 0, found - 1)
    local second_half = string.sub(str, found_end + 1)

    return first_half .. replacement .. second_half
end

_G.inspect = function(...)
    print(vim.inspect(...))
end

M.timer = {
    start_time = nil,
    start = function()
        M.timer.start_time = uv.now()
    end,
    stop = function()
        print(uv.now() - M.timer.start_time .. " ms")
        M.timer.start_time = nil
    end,

    start_nano = function()
        M.timer.start_time = uv.hrtime()
    end,
    stop_nano = function()
        print(uv.hrtime() - M.timer.start_time .. " ns")
        M.timer.start_time = nil
    end,
}

M.command = function(name, fn)
    vim.cmd(format("command! %s %s", name, fn))
end

M.lua_command = function(name, fn)
    M.command(name, "lua " .. fn)
end

M.augroup = function(name, event, fn, ft)
    api.nvim_exec(
        format(
            [[
    augroup %s
        autocmd!
        autocmd %s %s %s
    augroup END
    ]],
            name,
            event,
            ft or "*",
            fn
        ),
        false
    )
end

M.t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

M.input = function(keys, mode)
    vim.api.nvim_feedkeys(M.t(keys), mode or "i", true)
end

M.buf_augroup = function(name, event, fn)
    api.nvim_exec(
        format(
            [[
    augroup %s
        autocmd! * <buffer>
        autocmd %s <buffer> %s
    augroup END
    ]],
            name,
            event,
            fn
        ),
        false
    )
end

M.timer = function(timeout, interval, should_start, callback)
    local close_handle = function(handle)
        if handle and not handle:is_closing() then
            handle:close()
        end
    end

    interval = interval or 0

    local timer = uv.new_timer()
    local wrapped = vim.schedule_wrap(callback)

    local start = function()
        timer:start(timeout, interval, wrapped)
    end
    local close = function()
        close_handle(timer)
    end
    local stop = function(should_close)
        timer:stop()
        if should_close then
            close()
        end
    end
    local restart = function(new_timeout, new_interval)
        timer:stop()
        timer:start(new_timeout or timeout, new_interval or interval, wrapped)
    end

    if should_start then
        timer:start(timeout, interval, wrapped)
    end
    return {
        _timer = timer,
        start = start,
        stop = stop,
        restart = restart,
        close = close,
    }
end

return M
