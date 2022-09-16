local tokyonight_colors = {
    darkgray = "#16161d",
    gray = "#727169",
    innerbg = nil,
    outerbg = "#16161D",
    gutter = "#3b4261",
    normal = "#7aa2f7",
    insert = "#9ece6a",
    visual = "#bb9af7",
    replace = "#f7768e",
    command = "#e0af68",
}

-- local solarized_colors = {
--     darkgray = "#002b36",
--     gray = "#657b83",
--     innerbg = nil,
--     outerbg = "#002b36",
--     gutter = "#073642",
--     normal = "#268bd2",
--     insert = "#859900",
--     visual = "#6c71c4",
--     replace = "#cb4b16",
--     command = "#b58900",
-- }

local function theme()
    local colors = tokyonight_colors

    return {
        inactive = {
            a = { fg = colors.gray, bg = colors.innerbg },
            b = { fg = colors.gray, bg = colors.innerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
        visual = {
            a = { fg = colors.darkgray, bg = colors.visual },
            b = { fg = colors.visual, bg = colors.gutter },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
        replace = {
            a = { fg = colors.darkgray, bg = colors.replace },
            b = { fg = colors.replace, bg = colors.gutter },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
        normal = {
            a = { fg = colors.darkgray, bg = colors.normal },
            b = { fg = colors.normal, bg = colors.gutter },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
        insert = {
            a = { fg = colors.darkgray, bg = colors.insert },
            b = { fg = colors.insert, bg = colors.gutter },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
        command = {
            a = { fg = colors.darkgray, bg = colors.command },
            b = { fg = colors.command, bg = colors.gutter },
            c = { fg = colors.gray, bg = colors.innerbg },
        },
    }
end

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

local function blank()
    return " "
end

vim.cmd([[autocmd User LspProgressUpdate let &ro = &ro]])

local config = {
    options = {
        theme = theme(),
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
        always_divide_middle = false,
        icons_enabled = true,
    },
    sections = {
        lualine_a = { { "filename", path = 1, symbols = { modified = " [+]", readonly = " [RO]" } } },
        lualine_b = {
            { "b:gitsigns_head", icon = "" },
        },
        lualine_c = {
            { "diff", source = diff_source },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
        },
        lualine_x = { "filetype", lsp_progress },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = { blank },
        lualine_b = { blank },
        lualine_c = { blank },
        lualine_x = { blank },
        lualine_y = { blank },
        lualine_z = { blank },
    },
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
