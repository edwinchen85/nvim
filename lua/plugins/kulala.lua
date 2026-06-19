return {
    "mistweaverco/kulala.nvim",
    event = "VeryLazy",
    opts = {
        global_keymaps = false,
    },
    config = function(_, opts)
        require("kulala").setup(opts)
        require("which-key").add({
            { "<leader>R",  group = "HTTP" },
            { "<leader>Rs", function() require("kulala").run() end,              desc = "Send Request",      mode = { "n", "v" } },
            { "<leader>Ra", function() require("kulala").run_all() end,          desc = "Send All Requests", mode = { "n", "v" } },
            { "<leader>Rr", function() require("kulala").replay() end,           desc = "Replay Last Request" },
            { "<leader>Re", function() require("kulala").set_selected_env() end, desc = "Select Environment" },
            { "<leader>Ri", function() require("kulala").inspect() end,          desc = "Inspect Request" },
            { "<leader>Rb", function() require("kulala").scratchpad() end,       desc = "Open Scratchpad" },
            { "<leader>Rc", function() require("kulala").copy() end,             desc = "Copy as cURL" },
            { "<leader>Rp", function() require("kulala").from_curl() end,        desc = "Paste from cURL" },
        })
    end,
}
