local cmp = require("cmp")
local lspkind = require ("lspkind")

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,

        get_trigger_characters = function(trigger_characters)
            return vim.tbl_filter(function(char)
                return char ~= " " and char ~= "\t"
            end, trigger_characters)
        end,
    },
    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
    },
    completion = {
        completeopt = "menu, menuone, noinsert, noselect",
        keyword_length = 1,
    },
    mapping = {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
    },
    experimental = {
        ghost_text = true,
        native_menu = false,
    },
    documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "vsnip" },
        { name = "path" },
        {
            name = "buffer",
            opts = {
            get_bufnrs = function()
                return vim.api.nvim_list_bufs()
            end,
            },
        },
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)

            return vim_item
        end,
    },
})
