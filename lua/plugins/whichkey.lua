require("which-key").setup({
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = false, -- adds help for operators like d, y, ...
            motions = false, -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = false, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = false, -- bindings for prefixed with g
        },
    },
    key_labels = { ["<space>"] = "_", ["<CR>"] = "↵", ["<tab>"] = "⇆" },
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    icons = {
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
    },
    ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
})

local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
}

local mappings = {
    ["/"] = "Comment",
    ["h"] = "No Highlight",
    [";"] = "Dashboard",
    ["b"] = "Buffers",
    ["c"] = "Close Buffer",
    ["C"] = "Close All Buffers",
    ["e"] = "Explorer",
    ["i"] = "Jump Forward",
    ["n"] = "Follow File",
    ["p"] = "Find File",
    ["q"] = "Quit",
    ["v"] = "Vsplit Last",
    ["w"] = "Save",
    ["z"] = "Zen Mode",
    ["T"] = "Terminal",

    f = {
        name = "+Find",
        a = { "<cmd>Telescope grep_string<cr>", "Cursor" },
        b = { "<cmd>Telescope buffers<cr>", "Buffers" },
        f = { "<cmd>Telescope live_grep<cr>", "Grep" },
        h = { "<cmd>Telescope oldfiles<cr>", "History" },
        H = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
        l = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "BLines" },
        m = { "<cmd>Telescope marks<cr>", "Marks" },
        M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        p = { "<cmd>Telescope find_files<cr>", "Files" },
        r = { "<cmd>Telescope registers<cr>", "Registers" },
        t = { "<cmd>TodoTelescope<cr>", "Todo" },
    },

    g = {
        name = "+Git",
        j = { "<cmd>NextHunk<cr>", "Next Hunk" },
        k = { "<cmd>PrevHunk<cr>", "Prev Hunk" },
        p = { "<cmd>PreviewHunk<cr>", "Preview Hunk" },
        r = { "<cmd>ResetHunk<cr>", "Reset Hunk" },
        R = { "<cmd>ResetBuffer<cr>", "Reset Buffer" },
        s = { "<cmd>StageHunk<cr>", "Stage Hunk" },
        u = { "<cmd>UndoStageHunk<cr>", "Undo Last Stage Hunk" },
        o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        C = { "<cmd>Telescope git_bcommits<cr>", "Checkout commit(for current file)" },
        d = { "<cmd>:Gdiff!<cr>", "Git diff" },
        D = { "<cmd>Gtabedit @:% | Gdiff :<cr>", "Git diff staged" },
        h = { "<cmd>diffget //2<cr>", "Diffget target branch" },
        l = { "<cmd>diffget //3<cr>", "Diffget merge branch" },
        v = { ":GV<cr>", "Git commit browser" },
    },

    l = {
        name = "+LSP",
        d = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Document Diagnostics" },
        w = { "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics" },
        l = { "<cmd>Telescope loclist<cr>", "Loclist" },
        q = { "<cmd>Telescope quickfix<cr>", "Quickfix" },
        f = { "<cmd>LspFormatting<cr>", "Format" },
        i = { "<cmd>LspInfo<cr>", "Info" },
        t = { "<cmd>LspTypeDefinition<cr>", "Type Definition" },
        x = { "<cmd>cclose<cr>", "Close Quickfix" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols" },
    },

    S = {
        name = "+Session",
        s = { "<cmd>SessionSave<cr>", "Save Session" },
        l = { "<cmd>SessionLoad<cr>", "Load Session" },
    },
}

local wk = require("which-key")
wk.register(mappings, opts)
