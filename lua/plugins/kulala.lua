return {
    "mistweaverco/kulala.nvim",
    -- Pinned: v6.23.0 is the last release whose kulala-core backend (0.30.0)
    -- runs without a license token. Later releases need a newer core, and
    -- core.kulala.app only serves those with a token (401 otherwise). The
    -- repo moved to dont-be-evil-company; GitHub redirects the old name.
    -- Usage guide: kulala.md.
    tag = "v6.23.0",
    -- Off: not using the HTTP client much. `cond` (not `enabled`) keeps it
    -- installed and pinned in lazy-lock.json, so re-enabling is just deleting
    -- this line -- no re-download, no `:Lazy clean` prompt.
    cond = false,
    event = "VeryLazy",
    opts = {
        global_keymaps = false,
        -- Kulala's docs and env-file examples use "dev"; the built-in default
        -- is "default", which matches no env and leaves {{VARS}} empty.
        default_env = "dev",
    },
    config = function(_, opts)
        require("kulala").setup(opts)
        require("which-key").add({
            { "<leader>R", group = "HTTP" },
            {
                "<leader>Rs",
                function()
                    require("kulala").run()
                end,
                desc = "Send Request",
                mode = { "n", "v" },
            },
            {
                "<leader>Ra",
                function()
                    require("kulala").run_all()
                end,
                desc = "Send All Requests",
                mode = { "n", "v" },
            },
            {
                "<leader>Rr",
                function()
                    require("kulala").replay()
                end,
                desc = "Replay Last Request",
            },
            {
                -- Reopens the response window (closed with `q`) on the last
                -- response, without re-sending.
                "<leader>Ro",
                function()
                    require("kulala").open()
                end,
                desc = "Open Last Response",
            },
            {
                "<leader>Re",
                function()
                    require("kulala").set_selected_env()
                end,
                desc = "Select Environment",
            },
            {
                "<leader>Ri",
                function()
                    require("kulala").inspect()
                end,
                desc = "Inspect Request",
            },
            {
                "<leader>Rb",
                function()
                    require("kulala").scratchpad()
                end,
                desc = "Open Scratchpad",
            },
            {
                "<leader>Rc",
                function()
                    require("kulala").copy()
                end,
                desc = "Copy as cURL",
            },
            {
                "<leader>Rp",
                function()
                    require("kulala").from_curl()
                end,
                desc = "Paste from cURL",
            },
        })
    end,
}
