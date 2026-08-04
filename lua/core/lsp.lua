vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
        end

        map("n", "gr", vim.lsp.buf.references, "Show LSP references")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Show LSP definition")
        map("n", "gi", vim.lsp.buf.implementation, "Show LSP implementations")
        map("n", "gt", vim.lsp.buf.type_definition, "Show LSP type definitions")
        map({ "n", "v" }, "ga", vim.lsp.buf.code_action, "See available code actions")
        map("n", "gR", vim.lsp.buf.rename, "Smart rename")
        map("n", "gl", vim.diagnostic.open_float, "Show line diagnostics")
        map("n", "[d", function()
            vim.diagnostic.jump({ count = -1, on_jump = vim.diagnostic.open_float })
        end, "Go to previous diagnostic")
        map("n", "]d", function()
            vim.diagnostic.jump({ count = 1, on_jump = vim.diagnostic.open_float })
        end, "Go to next diagnostic")
        map("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
        end, "Show documentation for what is under cursor")
        map("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
    end,
})

-- Horizontal padding for LSP floats (hover, signature help).
--
-- There is no padding option: `open_floating_preview` only takes offset_x/y,
-- which move the window rather than pad it, and `nvim_open_win` rejects
-- multi-cell border strings ("Invalid 'border'"), so a side can be a line char
-- or a blank -- never both. render-markdown's `code.left_pad` is worse: the
-- window is sized from the raw text *before* it draws, so padding shifts
-- characters past the right edge and `wrap=false` silently eats them.
--
-- Padding the contents is what works, because open_floating_preview measures
-- them to size the window -- so the float grows instead of clipping (measured:
-- content 54 -> 56 with 1 space each side). Fence lines are left alone so
-- render-markdown still recognises the code block.
local FLOAT_PAD = (" "):rep(1)
local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    if type(contents) == "table" then
        local padded = {}
        for i, line in ipairs(contents) do
            padded[i] = line:match("^```") and line or (FLOAT_PAD .. line .. FLOAT_PAD)
        end
        contents = padded
    end
    return open_floating_preview(contents, syntax, opts, ...)
end

local border_opts = {
    border = "rounded",
    focusable = true,
    style = "minimal",
    source = true,
    scope = "line",
    header = "",
    prefix = "",
}
local severity = vim.diagnostic.severity

vim.diagnostic.config({
    float = border_opts,
    signs = {
        text = {
            [severity.ERROR] = " ",
            [severity.WARN] = " ",
            [severity.HINT] = "󰠠 ",
            [severity.INFO] = " ",
        },
    },
})

-- servers are chatty at the default WARN level; the log is otherwise unbounded
vim.lsp.log.set_level(vim.log.levels.ERROR)

-- suppress irrelevant lspconfig messages
local _notify = vim.notify
vim.notify = function(msg, ...)
    -- msg is not always a string (callers pass tables/numbers), so guard before matching
    if
        type(msg) == "string"
        and (msg:match("%[lspconfig%]") or msg:match("warning: multiple different client offset_encodings"))
    then
        return
    end
    return _notify(msg, ...)
end
