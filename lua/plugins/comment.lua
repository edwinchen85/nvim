local M = {
    "numToStr/Comment.nvim",
    lazy = false,
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            event = "VeryLazy",
        },
    },
}

function M.config()
    local wk = require "which-key"
    wk.add {
        { "<leader>/", "<Plug>(comment_toggle_linewise_current)", desc = "Comment", mode = "n" },
        { "<leader>/", "<Plug>(comment_toggle_linewise_visual)", desc = "Comment", mode = "v" },
    }

    vim.g.skip_ts_context_commentstring_module = true
    ---@diagnostic disable: missing-fields
    require("ts_context_commentstring").setup {
        enable_autocmd = false,
    }

    local ts_pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
    require("Comment").setup {
        pre_hook = function(ctx)
            return ts_pre_hook(ctx) or vim.bo.commentstring
        end,
    }
end

return M
