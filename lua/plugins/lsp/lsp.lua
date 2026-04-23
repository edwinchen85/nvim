return {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
        { "antosha417/nvim-lsp-file-operations", config = true },
        {
            "folke/lazydev.nvim",
            opts = {
                library = {
                    { path = "snacks.nvim", words = { "Snacks" } },
                },
            },
        },
        { "b0o/schemastore.nvim" },
    },
    config = function()
        -- suppress false-positive diagnostics from ts-plugin source on .vue files
        -- root cause: @vue/typescript-plugin loads from mason but can't resolve project's vue package
        -- vue_ls provides correct diagnostics for .vue; vtsls still attaches for the tsserver bridge
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and (client.name == "vtsls" or client.name == "ts_ls") then
                    local bufname = vim.api.nvim_buf_get_name(args.buf)
                    if bufname:match("%.vue$") then
                        local ns = vim.lsp.diagnostic.get_namespace(args.data.client_id)
                        vim.diagnostic.enable(false, { bufnr = args.buf, ns_id = ns })
                    end
                end
            end,
        })

        -- capabilities for all servers
        vim.lsp.config("*", {
            capabilities = vim.lsp.protocol.make_client_capabilities(),
        })

        -- copilot LSP required for sidekick.nvim NES (next edit suggestions)
        vim.lsp.enable("copilot")

        -- ts_ls: JS/TS only — vue files handled by vtsls
        vim.lsp.config("ts_ls", {
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        })

        -- vtsls: handles .vue files with @vue/typescript-plugin 3.x (designed for vtsls, not ts_ls)
        -- vue_ls communicates with vtsls via tsserver/request bridge
        local vue_plugin_path = vim.fn.stdpath("data")
            .. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"
        vim.lsp.config("vtsls", {
            filetypes = { "vue" },
            settings = {
                vtsls = {
                    tsserver = {
                        globalPlugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_plugin_path,
                                languages = { "vue" },
                                configNamespace = "typescript",
                                enableForWorkspaceTypeScriptVersions = true,
                            },
                        },
                    },
                },
            },
        })

        -- jsonls: JSON schema validation via schemastore
        vim.lsp.config("jsonls", {
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        -- emmet: add vue + svelte filetypes beyond defaults
        vim.lsp.config("emmet_language_server", {
            filetypes = {
                "css",
                "html",
                "javascript",
                "javascriptreact",
                "less",
                "sass",
                "scss",
                "typescriptreact",
                "vue",
                "svelte",
            },
        })

        -- eslint: disable formatting (conform/prettier owns it), support flat + legacy configs
        vim.lsp.config("eslint", {
            root_dir = require("lspconfig.util").root_pattern(
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.json",
                ".eslintrc"
            ),
            settings = {
                format = { enable = false },
            },
            handlers = {
                ["window/showMessageRequest"] = function(_, result)
                    if result.message:find("ENOENT") then
                        return vim.NIL
                    end
                    return vim.lsp.handlers["window/showMessageRequest"](nil, result)
                end,
            },
        })

        -- cssls: suppress unknown at-rule warnings (e.g. @tailwind, @apply, @layer)
        vim.lsp.config("cssls", {
            settings = {
                css = { lint = { unknownAtRules = "ignore" } },
                scss = { lint = { unknownAtRules = "ignore" } },
                less = { lint = { unknownAtRules = "ignore" } },
            },
        })

        -- lua_ls: disable built-in formatter (stylua via conform), suppress missing-fields, configure runtime
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    format = { enable = false },
                    diagnostics = {
                        disable = { "missing-fields" },
                        globals = { "vim", "spec", "Snacks" },
                    },
                    runtime = {
                        version = "LuaJIT",
                        special = { spec = "require" },
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                    hint = { enable = false },
                    telemetry = { enable = false },
                },
            },
        })

        -- tailwindcss: color provider + folding capabilities, extended filetypes
        local tw_capabilities = vim.lsp.protocol.make_client_capabilities()
        tw_capabilities.textDocument.colorProvider = { dynamicRegistration = false }
        tw_capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
        vim.lsp.config("tailwindcss", {
            capabilities = tw_capabilities,
            filetypes = {
                "css",
                "html",
                "mdx",
                "javascript",
                "typescript",
                "javascriptreact",
                "typescriptreact",
                "vue",
                "svelte",
            },
            settings = {
                tailwindCSS = {
                    experimental = {
                        configFile = nil,
                    },
                    lint = {
                        cssConflict = "warning",
                        invalidApply = "error",
                        invalidConfigPath = "error",
                        invalidScreen = "error",
                        invalidTailwindDirective = "error",
                        invalidVariant = "error",
                        recommendedVariantOrder = "warning",
                    },
                    validate = true,
                },
            },
        })

        -- vue_ls: hybrid mode (vtsls handles TS in .vue, vue_ls handles template/style)
        vim.lsp.config("vue_ls", {
            init_options = {
                vue = {
                    hybridMode = true,
                },
            },
        })
    end,
}
