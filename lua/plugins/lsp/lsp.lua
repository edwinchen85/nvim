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
        -- suppress vtsls diagnostics on .vue files
        -- root cause: @vue/typescript-plugin loads from mason, can't resolve project's vue package
        -- vue_ls provides correct diagnostics; vtsls only needed for tsserver bridge

        -- capabilities for all servers
        vim.lsp.config("*", {
            capabilities = vim.lsp.protocol.make_client_capabilities(),
        })

        -- ts_ls: JS/TS only — vue files handled by vtsls
        -- force ts_ls to use its bundled TS (6.0.2) instead of workspace TS (5.7.2)
        -- TS 5.7.2 tsserver has a bug where vue re-exports fail despite tsc working fine
        local ts_ls_tsserver = vim.fn.stdpath("data")
            .. "/mason/packages/typescript-language-server/node_modules/typescript/lib/tsserver.js"
        vim.lsp.config("ts_ls", {
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
            cmd = { "typescript-language-server", "--stdio" },
            init_options = {
                tsserver = { path = ts_ls_tsserver },
            },
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
            handlers = {
                -- vtsls uses workspace TS which has a tsserver bug with vue re-exports;
                -- drop only the false-positive TS2305 errors for module '"vue"'
                ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                    if result and result.uri and result.uri:match("%.vue$") and result.diagnostics then
                        result.diagnostics = vim.tbl_filter(function(d)
                            if d.code == 2305 and d.message and d.message:match('"vue"') then
                                return false
                            end
                            -- 7016: "Could not find a declaration file for module ..."
                            if d.code == 7016 then
                                return false
                            end
                            return true
                        end, result.diagnostics)
                    end
                    vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
                end,
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
            settings = {
                css = { lint = { unknownAtRules = "ignore" } },
                scss = { lint = { unknownAtRules = "ignore" } },
                less = { lint = { unknownAtRules = "ignore" } },
            },
            init_options = {
                vue = {
                    hybridMode = true,
                },
            },
        })
    end,
}
