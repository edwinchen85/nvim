local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local set = require("telescope.actions.set")

local u = require("utils")
local commands = require("commands")

local api = vim.api

telescope.setup({
    extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
    },
    defaults = {
        preview = {
            timeout = 500,
        },
        file_browser = {
            hidden = true,
        },
        find_command = { "rg", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--ignore",
            "--hidden",
            "-g",
            "!.git",
        },
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        multi_icon = " ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
            prompt_position = "top",
            horizontal = {
                width_padding = 0.04,
                height_padding = 0.1,
                preview_width = 0.4,
            },
            vertical = {
                width_padding = 0.05,
                height_padding = 1,
                preview_height = 0.5,
            },
        },
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        file_ignore_patterns = {
            "node_modules/**/*.d.ts",
            "node_modules/**.*",
            "package-lock.json",
            "yarn.lock",
            ".git/**",
        },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        dynamic_preview_title = true,
        path_display = {},
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
            i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,
                ["<C-c>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<CR>"] = actions.select_default + actions.center,
                ["<c-d>"] = require("telescope.actions").delete_buffer,
            },
            n = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<c-d>"] = require("telescope.actions").delete_buffer,
            },
        },
    },
})

telescope.load_extension("fzf")

_G.global.telescope = {
    -- grep string from prompt
    grep_prompt = function()
        builtin.grep_string({
            shorten_path = true,
            search = vim.fn.input("grep > "),
        })
    end,

    -- try git_files and fall back to find_files
    find_files = function()
        local current = api.nvim_get_current_buf()
        local opts = {
            attach_mappings = function(_, map)
                -- replace current buffer with selected
                map("i", "<C-r>", function(prompt_bufnr)
                    set.edit(prompt_bufnr, "edit")

                    commands.bdelete(current)
                end)

                -- edit file and matching test file in split
                map("i", "<C-f>", function(prompt_bufnr)
                    set.edit(prompt_bufnr, "edit")

                    commands.wwipeall()
                    commands.edit_test_file("vsplit $FILE | wincmd w")
                end)

                return true
            end,
        }

        local is_git_project = pcall(builtin.git_files, opts)
        if not is_git_project then
            builtin.find_files(opts)
        end
    end,
}

-- lsp
u.command("LspRef", "Telescope lsp_references")
u.command("LspDef", "Telescope lsp_definitions")
u.command("LspSym", "Telescope lsp_workspace_symbols")
u.command("LspAct", "Telescope lsp_code_actions")
u.command("LspRangeAct", "Telescope lsp_range_code_actions")
