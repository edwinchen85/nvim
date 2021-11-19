local u = require("utils")
local bufdel = require("bufdel")

local api = vim.api

bufdel.setup({ quit = false })

global.bonly = function()
    local current = api.nvim_get_current_buf()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if bufnr ~= current then
            bufdel.delete_buffer(bufnr)
        end
    end
end

global.bwipeout = function()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        bufdel.delete_buffer(bufnr)
    end
end

u.lua_command("Bonly", "global.bonly()")
u.lua_command("Bwipeout", "global.bwipeout()")
