local M = {
    "nvim-telescope/telescope.nvim",
    dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true } },
}

function M.config()
    local wk = require "which-key"
    wk.add {
        { "<leader>f", group = "Find" },
        { "<leader>fa", "<cmd>Telescope grep_string<cr>", desc = "Cursor" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fB", "<cmd>Telescope git_branches<cr>", desc = "Checkout Branch" },
        { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>fp", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Projects" },
        { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
        { "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last Search" },
        { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent File" },
    }

    local actions = require "telescope.actions"

    require("telescope").setup {
        defaults = {
            border = true,
            -- dynamic_preview_title = true,
            dynamic_preview_title = false,
            prompt_prefix = "  ",
            selection_caret = "  ",
            entry_prefix = "   ",
            initial_mode = "insert",
            selection_strategy = "reset",
            scroll_strategy = "cycle",
            path_display = { "truncate" },
            -- path_display = { "filename_first" },
            -- prompt_title = "Prompt",
            -- results_title = "Results",
            color_devicons = true,
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
            },
            -- layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    width = { padding = 0 },
                    height = { padding = 0 },
                    preview_width = 0.5,
                },
                -- vertical = { width = 0.5 },
                -- other layout configuration here
            },
            sorting_strategy = "ascending",

            mappings = {
                i = {
                    ["<C-n>"] = actions.cycle_history_next,
                    ["<C-p>"] = actions.cycle_history_prev,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                },
                n = {
                    ["<esc>"] = actions.close,
                    ["j"] = actions.move_selection_next,
                    ["k"] = actions.move_selection_previous,
                    ["q"] = actions.close,
                },
            },
        },
        pickers = {
            old_files = {
                theme = "dropdown",
            },

            live_grep = {
                theme = "dropdown",
            },

            grep_string = {
                theme = "dropdown",
            },

            find_files = {
                -- theme = "dropdown",
                -- layout_strategy = "center",
                -- layout_strategy = "bottom_pane",
                -- previewer = false,
                hidden = true,
                find_command = {
                    "rg",
                    "--files",
                    "--glob",
                    "!{.git/*,.next/*,node_modules/*}",
                    "--path-separator",
                    "/",
                },
            },

            buffers = {
                theme = "dropdown",
                previewer = false,
                initial_mode = "insert",
                mappings = {
                    i = {
                        ["<C-d>"] = actions.delete_buffer,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    },
                    n = {
                        ["dd"] = actions.delete_buffer,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                    },
                },
            },

            planets = {
                show_pluto = true,
                show_moon = true,
            },

            colorscheme = {
                enable_preview = true,
            },

            lsp_references = {
                theme = "dropdown",
                initial_mode = "normal",
            },

            lsp_definitions = {
                theme = "dropdown",
                initial_mode = "normal",
            },

            lsp_declarations = {
                theme = "dropdown",
                initial_mode = "normal",
            },

            lsp_implementations = {
                theme = "dropdown",
                initial_mode = "normal",
            },
        },
        extensions = {
            fzf = {
                fuzzy = true, -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true, -- override the file sorter
                case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            },
        },
    }
end

return {}
-- return M
