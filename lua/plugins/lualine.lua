M = {}

local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

local lualine_scheme = "tokyonight"

local status_theme_ok, theme = pcall(require, "lualine.themes." .. lualine_scheme)
if not status_theme_ok then
    return
end

-- check if value in table
local function contains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local gray = "#32363e"
local dark_gray = "#282C34"
local red = "#D16969"
local blue = "#569CD6"
local green = "#6A9955"
local cyan = "#4EC9B0"
local orange = "#CE9178"
local indent = "#CE9178"
local purple = "#C586C0"

if lualine_scheme == "tokyonight" then
    gray = "#303030"
    dark_gray = "#303030"
    red = "#bf616a"
    blue = "#5e81ac"
    indent = "#A3BE8C"
    green = "#A3BE8C"
    cyan = "#88c0d0"
    orange = "#C68A75"
    purple = "#B48EAD"
end

vim.api.nvim_set_hl(0, "SLGitIcon", { fg = "#E8AB53", bg = dark_gray })
vim.api.nvim_set_hl(0, "SLTermIcon", { fg = purple, bg = gray })
vim.api.nvim_set_hl(0, "SLBranchName", { fg = "#abb2bf", bg = dark_gray, bold = false })
vim.api.nvim_set_hl(0, "SLProgress", { fg = purple, bg = gray })
vim.api.nvim_set_hl(0, "SLLocation", { fg = blue, bg = gray })
vim.api.nvim_set_hl(0, "SLFT", { fg = cyan, bg = gray })
vim.api.nvim_set_hl(0, "SLIndent", { fg = indent, bg = gray })
vim.api.nvim_set_hl(0, "SLLSP", { fg = "#6b727f", bg = "NONE" })
vim.api.nvim_set_hl(0, "SLSep", { fg = gray, bg = "NONE" })
vim.api.nvim_set_hl(0, "SLFG", { fg = "#abb2bf", bg = "NONE" })
vim.api.nvim_set_hl(0, "SLSeparator", { fg = "#6b727f", bg = "NONE", italic = true })
vim.api.nvim_set_hl(0, "SLError", { fg = "#bf616a", bg = "NONE" })
vim.api.nvim_set_hl(0, "SLWarning", { fg = "#D7BA7D", bg = "NONE" })
vim.api.nvim_set_hl(0, "SLCopilot", { fg = "#6CC644", bg = "NONE" })

local hl_str = function(str, hl)
    return "%#" .. hl .. "#" .. str .. "%*"
end

local mode_color = {
    n = blue,
    i = orange,
    v = "#b668cd",
    [""] = "#b668cd",
    V = "#b668cd",
    c = "#46a6b2",
    no = "#D16D9E",
    s = green,
    S = orange,
    [""] = orange,
    ic = red,
    R = "#D16D9E",
    Rv = red,
    cv = blue,
    ce = blue,
    r = red,
    rm = "#46a6b2",
    ["r?"] = "#46a6b2",
    ["!"] = "#46a6b2",
    t = red,
}

local left_pad = {
    function()
        return ""
    end,
    padding = 0,
    color = function()
        return { fg = gray, bg = "NONE" }
    end,
}

local right_pad = {
    function()
        return ""
    end,
    padding = 0,
    color = function()
        return { fg = dark_gray, bg = "NONE" }
    end,
}

local left_pad_alt = {
    function()
        return " "
    end,
    padding = 0,
    color = function()
        return { fg = gray, bg = "#1e2130" }
    end,
}

local right_pad_alt = {
    function()
        return " "
    end,
    padding = 0,
    color = function()
        return { fg = gray, bg = "#1e2130" }
    end,
}

local filename = {
    "filename",
    path = 1,
    symbols = { modified = "[+]", readonly = "[RO]" },
    padding = 0,
}

local mode = {
    -- mode component
    function()
        return " "
    end,
    color = function()
        -- auto change color according to neovims mode
        return { fg = mode_color[vim.fn.mode()], bg = gray }
    end,
    padding = 0,
}

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn", "hint" },
    symbols = {
        error = "%#SLError#" .. "" .. "%*" .. " ",
        warn = "%#SLWarning#" .. "" .. "%*" .. " ",
        hint = "%#SLHint#" .. "" .. "%*" .. " ",
    },
    colored = true,
    update_in_insert = false,
    always_visible = true,
    padding = 0,
}

local filetype = {
    "filetype",
    fmt = function(str)
        local ui_filetypes = {
            "help",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "",
            "nil",
        }

        local return_val = function(string)
            return hl_str(" ", "SLSep") .. hl_str(string, "SLFT") .. hl_str("", "SLSep")
        end

        if str == "TelescopePrompt" then
            return return_val(" ")
        end

        local function get_term_num()
            local t_status_ok, toggle_num = pcall(vim.api.nvim_buf_get_var, 0, "toggle_number")
            if not t_status_ok then
                return ""
            end
            return toggle_num
        end

        if str == "toggleterm" then
            -- 
            local term = "%#SLTermIcon#" .. " " .. "%*" .. "%#SLFT#" .. get_term_num() .. "%*"

            return return_val(term)
        end

        if contains(ui_filetypes, str) then
            return ""
        else
            return return_val(str)
        end
    end,
    icons_enabled = false,
    padding = 0,
}

local branch = {
    "branch",
    icons_enabled = true,
    icon = "%#SLGitIcon#" .. " " .. "%*" .. "%#SLBranchName#",
    colored = false,
    padding = 0,
    fmt = function(str)
        if str == "" or str == nil then
            return "!=vcs"
        end

        return str
    end,
}

local progress = {
    "progress",
    fmt = function()
        return hl_str("", "SLSep") .. hl_str("%P/%L", "SLProgress") .. hl_str(" ", "SLSep")
    end,
    padding = 0,
}

local spaces = {
    function()
        local buf_ft = vim.bo.filetype

        local ui_filetypes = {
            "help",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "DressingSelect",
            "",
        }
        local space = ""

        if contains(ui_filetypes, buf_ft) then
            space = " "
        end

        local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")

        if shiftwidth == nil then
            return ""
        end

        return hl_str(" ", "SLSep") .. hl_str(" " .. shiftwidth .. space, "SLIndent") .. hl_str("", "SLSep")
    end,
    padding = 0,
}

local location = {
    "location",
    fmt = function(str)
        return hl_str(" ", "SLSep") .. hl_str(str, "SLLocation") .. hl_str(" ", "SLSep")
    end,
    padding = 0,
}

lualine.setup({
    options = {
        globalstatus = true,
        icons_enabled = true,
        theme = theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { left_pad, mode, branch, right_pad },
        lualine_b = { left_pad_alt, diagnostics, right_pad_alt },
        lualine_c = { "%=", filename },
        lualine_x = { spaces, filetype },
        lualine_y = {},
        lualine_z = { location, progress },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = {},
})
