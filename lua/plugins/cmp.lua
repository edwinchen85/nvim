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
            Array = " ",
            Boolean = " ",
            Class = " ",
            Color = " ",
            Constant = " ",
            Constructor = " ",
            Enum = " ",
            EnumMember = " ",
            Event = " ",
            Field = " ",
            File = " ",
            Folder = "󰉋 ",
            Function = " ",
            Interface = " ",
            Key = " ",
            Keyword = " ",
            Method = " ",
            Module = " ",
            Namespace = " ",
            Null = "󰟢 ",
            Number = " ",
            Object = " ",
            Operator = " ",
            Package = " ",
            Property = " ",
            Reference = " ",
            Snippet = " ",
            String = " ",
            Struct = " ",
            Text = " ",
            TypeParameter = " ",
            Unit = " ",
            Value = " ",
            Variable = " ",
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
                    local nes_ok, nes = pcall(require, "sidekick.nes")
                    if nes_ok and nes.have() then
                        require("sidekick").nes_jump_or_apply()
                    elseif cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.get_selected_entry() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
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

        local cmdline_mapping = cmp.mapping.preset.cmdline({
            ["<CR>"] = {
                c = function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = true })
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
                    else
                        fallback()
                    end
                end,
            },
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmdline_mapping,
            sources = {
                { name = "buffer" },
            },
            completion = { completeopt = "menu,menuone,noinsert" },
        })

        cmp.setup.cmdline(":", {
            mapping = cmdline_mapping,
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
            completion = { completeopt = "menu,menuone,noinsert" },
        })
    end,
}
