-- Debugging: nvim-dap + dap-ui + virtual text, adapted from
-- adibhanna/nvim (lua/plugins/dap.lua @ 4befa951).
-- Keys live under <leader>d (group registered in
-- plugins/whichkey.lua). Adapters come from mason
-- (plugins/lsp/mason.lua installs js-debug-adapter and delve).
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio", -- required by nvim-dap-ui
        -- shows variable values next to the code
        "theHamsta/nvim-dap-virtual-text",
        "leoluz/nvim-dap-go", -- Go (delve)
    },
    keys = {
        {
            "<leader>dc",
            function()
                require("dap").continue()
            end,
            desc = "Start / Continue",
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Toggle Breakpoint",
        },
        {
            "<leader>dB",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Conditional Breakpoint",
        },
        {
            "<leader>di",
            function()
                require("dap").step_into()
            end,
            desc = "Step Into",
        },
        {
            "<leader>do",
            function()
                require("dap").step_over()
            end,
            desc = "Step Over",
        },
        {
            "<leader>dO",
            function()
                require("dap").step_out()
            end,
            desc = "Step Out",
        },
        {
            "<leader>dr",
            function()
                require("dap").run_last()
            end,
            desc = "Run Last",
        },
        {
            "<leader>dx",
            function()
                require("dap").terminate()
            end,
            desc = "Stop",
        },
        {
            "<leader>du",
            function()
                require("dapui").toggle()
            end,
            desc = "Toggle UI",
        },
        {
            "<leader>de",
            function()
                require("dapui").eval()
            end,
            mode = { "n", "v" },
            desc = "Eval Under Cursor",
        },
        {
            "<leader>dt",
            function()
                require("dap-go").debug_test()
            end,
            ft = "go",
            desc = "Debug Go Test",
        },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup({
            icons = {
                expanded = "▾",
                collapsed = "▸",
                current_frame = "*",
            },
            controls = {
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "b",
                    run_last = "▶▶",
                    terminate = "⏹",
                    disconnect = "⏏",
                },
            },
        })
        -- open the UI when a session starts, close it when it ends
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
        require("nvim-dap-virtual-text").setup()
        -- Go: dap-go registers the "go" adapter and its launch configs
        -- (Debug, Debug test, ...).
        -- It runs plain `dlv` from PATH (dap-go/init.lua `default_config.delve.path`).
        require("dap-go").setup()
        -- JS / TS / Vue / React: js-debug-adapter (VS Code's debugger).
        -- nvim-dap fills in ${port}.
        local js_debug = vim.fn.stdpath("data")
            .. "/mason/packages/js-debug-adapter"
            .. "/js-debug/src/dapDebugServer.js"
        for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
            dap.adapters[adapter] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { js_debug, "${port}" },
                },
            }
        end
        local js_configs = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Node: current file",
                program = "${file}",
                cwd = "${workspaceFolder}",
            },
            {
                -- same as the Vitest docs' VS Code launch.json entry
                type = "pwa-node",
                request = "launch",
                name = "Vitest: current file",
                program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
                args = { "run", "${relativeFile}" },
                autoAttachChildProcesses = true,
                smartStep = true,
                console = "integratedTerminal",
                cwd = "${workspaceFolder}",
                skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
                -- start the dev server first (e.g. `pnpm dev`);
                -- Vite serves on 5173
                type = "pwa-chrome",
                request = "launch",
                name = "Chrome: open a URL",
                url = function()
                    return vim.fn.input("URL: ", "http://localhost:5173")
                end,
                webRoot = "${workspaceFolder}",
            },
            {
                type = "pwa-node",
                request = "attach",
                name = "Node: attach to process",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
            },
        }
        for _, ft in ipairs({
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "vue",
        }) do
            dap.configurations[ft] = js_configs
        end
    end,
}
