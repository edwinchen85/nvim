return {
    "Cannon07/code-preview.nvim",
    config = function()
        require("code-preview").setup({
            diff = {
                layout = "inline", -- "tab" (new tab) | "vsplit" (current tab) | "inline" (GitHub-style)
                labels = { current = "CURRENT", proposed = "PROPOSED" },
                equalize = true, -- 50/50 split widths (tab/vsplit only)
                full_file = true, -- show full file, not just diff hunks (tab/vsplit only)
                visible_only = false, -- skip diffs for files not open in any Neovim buffer
                defer_claude_permissions = false, -- for Claude Code: let its own settings decide, don't prompt
            },
            highlights = {
                current = { -- CURRENT (original) side — tab/vsplit layouts
                    DiffAdd = { bg = "#4c2e2e" },
                    DiffDelete = { bg = "#4c2e2e" },
                    DiffChange = { bg = "#4c3a2e" },
                    DiffText = { bg = "#5c3030" },
                },
                proposed = { -- PROPOSED side — tab/vsplit layouts
                    DiffAdd = { bg = "#2e4c2e" },
                    DiffDelete = { bg = "#4c2e2e" },
                    DiffChange = { bg = "#2e3c4c" },
                    DiffText = { bg = "#3e5c3e" },
                    inline = { -- active layout: +/- lines interleaved in single buffer (GitHub PR style)
                        added = { bg = "#1a2e37" }, -- full added line bg
                        removed = { bg = "#361a21" }, -- full removed line bg
                        added_text = { bg = "#243e4a" }, -- word-diff: exact chars added
                        removed_text = { bg = "#4a272f" }, -- word-diff: exact chars removed
                    },
                },
            },
        })
    end,
}
