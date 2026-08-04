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

        -- Horizontal padding for cmp's documentation window. Only the completion
        -- menu has `side_padding`; the docs window has no padding option, and it
        -- builds its own float instead of going through
        -- `vim.lsp.util.open_floating_preview`, so the padding wired up in
        -- `core/lsp.lua` never reaches it.
        --
        -- Padding the doc source works because cmp stylizes these lines into the
        -- buffer and only *then* measures it to size the window
        -- (view/docs_view.lua:65 then :72) -- so the window grows instead of
        -- clipping. Hooking `vim.lsp.util.stylize_markdown` would be the other
        -- option, but it is deprecated for removal in 0.14.
        --
        -- Fence and blank lines are left alone: padding a fence would break code
        -- block detection, and padding a blank line is just trailing whitespace.
        local entry = require("cmp.entry")
        local get_documentation = entry.get_documentation
        ---@diagnostic disable-next-line: duplicate-set-field
        entry.get_documentation = function(self)
            -- Returns a flat string[]; it ends in
            -- `vim.lsp.util.convert_input_to_markdown_lines(documents)`, not the
            -- {kind, value} tables it builds internally.
            local lines = get_documentation(self)
            for i, line in ipairs(lines) do
                if line ~= "" and not line:match("^```") then
                    lines[i] = " " .. line .. " "
                end
            end
            return lines
        end

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
                    -- One space of right-edge padding. `menu` is the last entry in
                    -- `fields`, and its column width IS folded into the window
                    -- width (view/custom_entries_view.lua:176), so trailing spaces
                    -- genuinely widen the window -- unlike `side_padding`, which is
                    -- rendered but not measured. Add spaces here to widen further.
                    -- Guarded because sources absent from the map above (nvim_lua,
                    -- calc) leave `menu` nil.
                    if vim_item.menu then
                        vim_item.menu = vim_item.menu .. " "
                    end
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
                    -- Empty, not "FloatBorder:NormalFloat": that remap is why the
                    -- cmp borders were NormalFloat's #c0caf5 instead of
                    -- FloatBorder's #565f89. With no remap, FloatBorder resolves
                    -- to itself and Normal still falls back to NormalFloat in a
                    -- float, so the transparent background is unchanged. Note
                    -- omitting the key entirely would NOT work -- cmp would then
                    -- apply its own default, which remaps to Pmenu.
                    winhighlight = "",
                    -- Left at cmp's default. Raising this does not add padding: it
                    -- is rendered on both sides (view/custom_entries_view.lua:299,
                    -- 304) but never measured -- the width math hardcodes 1 cell
                    -- per side (:173, :177). So the window does not grow and the
                    -- content just shifts right, trading right gutter for left
                    -- (measured at 2: leading 3->4, trailing 7->6, total
                    -- unchanged). Nothing but whitespace is clipped, so it is safe
                    -- to raise -- just pointless. Pad `menu` for real right-hand
                    -- padding; see `formatting`.
                    side_padding = 1,
                },
                documentation = {
                    border = "rounded",
                    -- cmp's default here is also "FloatBorder:NormalFloat".
                    winhighlight = "",
                    -- 0 leaves the docs where cmp puts them: flush against the menu
                    -- (`right_col = view.col + view.width`, view/docs_view.lua:81),
                    -- so the two borders touch. A positive value opens a gap
                    -- (:111), but only while the docs sit to the right -- when
                    -- there is more room to the left cmp flips them over and the
                    -- same offset pushes them *toward* the menu instead. Hence
                    -- staying at 0 rather than papering over the touching borders.
                    col_offset = 0,
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
