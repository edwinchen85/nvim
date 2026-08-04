local M = {
    "RRethy/vim-illuminate",
    -- Temporarily off. `cond` rather than `enabled` for the same reason as
    -- kulala: it keeps the plugin installed and pinned in lazy-lock.json, so
    -- re-enabling is just deleting this line. Re-enable by removing it.
    cond = false,
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
