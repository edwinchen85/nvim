-- Breadcrumbs in the winbar, styled after Zed; what is drawn lives in
-- `config/breadcrumbs.lua`, dropbar only hosts it.
return {
    "Bekaboo/dropbar.nvim",
    -- upstream defers its own work (README: "Lazy-loading is unneeded")
    lazy = false,
    config = function()
        local breadcrumbs = require("config.breadcrumbs")
        breadcrumbs.setup()
        require("dropbar").setup({
            bar = {
                -- Zed shows the bar on every file, parser or not; upstream's
                -- default (`dropbar/configs.lua` `bar.enable`) also takes
                -- terminals and skips files without a parser or LSP.
                enable = function(buf, win)
                    if
                        not vim.api.nvim_buf_is_valid(buf)
                        or not vim.api.nvim_win_is_valid(win)
                        or vim.fn.win_gettype(win) ~= ""
                        or vim.wo[win].winbar ~= ""
                        or vim.bo[buf].buftype ~= ""
                        or vim.api.nvim_buf_get_name(buf) == ""
                    then
                        return false
                    end
                    local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
                    return not (stat and stat.size > 1024 * 1024)
                end,
                sources = { breadcrumbs },
                -- hover repaints a symbol through `name_hl`, which our
                -- per-token colours bypass
                hover = false,
            },
            icons = {
                ui = { bar = { separator = " › ", extends = "…" } },
            },
        })
    end,
}
