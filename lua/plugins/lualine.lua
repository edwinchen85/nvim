local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
        }
    end
end

local function lsp_progress(_, is_active)
    if not is_active then
        return ""
    end
    local messages = vim.lsp.util.get_progress_messages()
    if #messages == 0 then
        return ""
    end
    local status = {}
    for _, msg in pairs(messages) do
        table.insert(status, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
    end
    local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local ms = vim.loop.hrtime() / 1000000
    local frame = math.floor(ms / 120) % #spinners
    return table.concat(status, " | ") .. " " .. spinners[frame + 1]
end

vim.cmd([[autocmd User LspProgressUpdate let &ro = &ro]])

local config = {
    options = {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        always_divide_middle = false,
        icons_enabled = true,
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            { "b:gitsigns_head", icon = "" },
        },
        lualine_c = {
            { "diff", source = diff_source },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
            },
            { "filename", path = 1, symbols = { modified = " [+]", readonly = " [RO]" } },
        },
        lualine_x = { "filetype", lsp_progress },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    extensions = { "nvim-tree" },
}

local M = {}

function M.load()
    local name = vim.g.colors_name or ""
    local ok, _ = pcall(require, "lualine.themes." .. name)
    if ok then
        config.options.theme = name
    end
    require("lualine").setup(config)
end

M.load()

return M
