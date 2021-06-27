local telescope = require("telescope")
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
        find_command = {'rg', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'},
        prompt_position = "bottom",
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_defaults = {horizontal = {mirror = false}, vertical = {mirror = false}},
        file_sorter = require'telescope.sorters'.get_fzy_sorter,
        file_ignore_patterns = {},
        generic_sorter = require'telescope.sorters'.get_generic_fuzzy_sorter,
        shorten_path = true,
        winblend = 0,
        width = 0.75,
        preview_cutoff = 120,
        results_height = 1,
        results_width = 0.8,
        border = {},
        borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
        color_devicons = true,
        use_less = true,
        set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
        file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
        mappings = {
            i = {
                ["<C-c>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<CR>"] = actions.select_default + actions.center
            },
            n = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
            }
        }
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
                    commands.edit_test_file("vsplit", function()
                        vim.cmd("wincmd w")
                    end)
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

u.lua_command("Rg", "global.telescope.grep_prompt()")
