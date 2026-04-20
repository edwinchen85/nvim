local M = {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
}

function M.config()
    require("illuminate").configure({
        providers = {
            "lsp",
            "regex",
        },
        filetypes_denylist = {
            "mason",
            "harpoon",
            "DressingInput",
            "NeogitCommitMessage",
            "qf",
            "dirvish",
            "oil",
            "minifiles",
            "fugitive",
            "alpha",
            "NvimTree",
            "lazy",
            "NeogitStatus",
            "Trouble",
            "netrw",
            "lir",
            "DiffviewFiles",
            "Outline",
            "Jaq",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "TelescopePrompt",
        },
    })
end

return M
