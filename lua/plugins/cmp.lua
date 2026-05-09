return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
        { "hrsh7th/cmp-buffer", event = "InsertEnter" },
        { "hrsh7th/cmp-path", event = "InsertEnter" },
        { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-cmdline" },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        local kind_icons = {
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
        }

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = {
                ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
                ["<C-c>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                ["<C-e>"] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                }),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local suggestion = require("supermaven-nvim.completion_preview")
                    if suggestion.has_suggestion() then
                        suggestion.on_accept_suggestion()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            },
            formatting = {
                expandable_indicator = true,
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snippet]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                    })[entry.source.name]
                    return vim_item
                end,
            },
            sources = {
                { name = "luasnip", keyword_length = 2, max_item_count = 1 },
                { name = "nvim_lsp" },
                { name = "nvim_lua" },
                {
                    name = "buffer",
                    keyword_length = 2,
                    option = {
                        get_bufnrs = function()
                            local bufs = {}
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                bufs[vim.api.nvim_win_get_buf(win)] = true
                            end
                            return vim.tbl_keys(bufs)
                        end,
                    },
                },
                { name = "path" },
                { name = "calc" },
            },
            confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },
            window = {
                completion = {
                    border = "rounded",
                    scrollbar = false,
                    winhighlight = "FloatBorder:NormalFloat",
                },
                documentation = {
                    border = "rounded",
                },
            },
            experimental = {
                ghost_text = false,
                native_menu = false,
            },
        })

        local cmdline_mapping = cmp.mapping.preset.cmdline()

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmdline_mapping,
            sources = {
                {
                    name = "buffer",
                    keyword_length = 1,
                    -- strip leading vim regex flags (\v \V \m \M \c \C) from keyword
                    option = { keyword_pattern = [[\(\\[vVmMcC]\)*\zs\k\+]] },
                },
            },
            completion = { completeopt = "menu,menuone,noinsert,noselect" },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline({
                ["<CR>"] = {
                    c = function(fallback)
                        if cmp.visible() and cmp.get_selected_entry() then
                            cmp.confirm({ select = false })
                        else
                            fallback()
                        end
                    end,
                },
            }),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
            completion = { completeopt = "menu,menuone,noinsert,noselect" },
        })
    end,
}
