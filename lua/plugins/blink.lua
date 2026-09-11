-- Completion. Replaces nvim-cmp (lua/plugins/cmp.lua, kept but disabled).
-- Borders are left unset: blink falls back to `vim.o.winborder` (rounded,
-- set in config/options.lua) when a window border is nil -- window/utils.lua:6.
-- blink registers its own LSP client capabilities via `vim.lsp.config("*")`,
-- so lua/plugins/lsp/lsp.lua needs no cmp-nvim-lsp style wiring.
return {
    "Saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    -- tagged release = prebuilt fuzzy matcher binary, no local cargo build
    version = "1.*",
    dependencies = {
        "Saghen/blink.lib",
        "L3MON4D3/LuaSnip",
        "mikavilpas/blink-ripgrep.nvim",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
        snippets = { preset = "luasnip" },
        keymap = {
            preset = "none",
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
        },
        cmdline = {
            keymap = {
                preset = "none",
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-c>"] = { "show", "fallback" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<CR>"] = { "accept_and_enter", "fallback" },
            },
            completion = {
                menu = { auto_show = true },
                list = { selection = { preselect = false, auto_insert = false } },
            },
        },
        appearance = {
            kind_icons = {
                Class = " ",
                Color = " ",
                Constant = " ",
                Constructor = " ",
                Enum = " ",
                EnumMember = " ",
                Event = " ",
                Field = " ",
                File = " ",
                Folder = " ",
                Function = " ",
                Interface = " ",
                Keyword = " ",
                Method = " ",
                Module = " ",
                Operator = " ",
                Property = " ",
                Reference = " ",
                Snippet = " ",
                Struct = " ",
                Text = " ",
                TypeParameter = " ",
                Unit = " ",
                Value = " ",
                Variable = " ",
            },
        },
        completion = {
            list = { selection = { preselect = false, auto_insert = false } },
            menu = {
                auto_show = true,
                draw = {
                    treesitter = { "lsp" },
                    -- icon, label, source tag -- the cmp `fields` order
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        { "source_name" },
                    },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
        },
        signature = { enabled = true },
        fuzzy = { implementation = "lua" },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
            per_filetype = { sql = { "lsp", "snippets", "buffer" } },
            providers = {
                lsp = { score_offset = 90 },
                ripgrep = {
                    module = "blink-ripgrep",
                    name = "Ripgrep",
                    score_offset = -10,
                    opts = {
                        prefix_min_len = 3,
                        backend = { use = "gitgrep-or-ripgrep" },
                    },
                },
            },
        },
    },
}
