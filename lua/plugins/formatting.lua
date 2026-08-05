return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "tpope/vim-sleuth" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters = {
                prettier = {
                    prepend_args = function(_, ctx)
                        local sw = vim.bo[ctx.buf].shiftwidth
                        local et = vim.bo[ctx.buf].expandtab
                        local args = { "--tab-width=" .. sw }
                        if not et then
                            table.insert(args, "--use-tabs")
                        end
                        if vim.bo[ctx.buf].filetype == "markdown" then
                            table.insert(args, "--prose-wrap=always")
                        end
                        return args
                    end,
                },
            },
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                svelte = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                liquid = { "prettier" },
                lua = { "stylua" },
                vue = { "prettier" },
                python = { "isort", "black" },
            },
            format_on_save = {
                lsp_format = "fallback",
                async = false,
                timeout_ms = 1000,
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_format = "fallback",
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
