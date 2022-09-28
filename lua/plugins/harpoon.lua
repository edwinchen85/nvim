local h_status_ok, harpoon = pcall(require, "harpoon")
if not h_status_ok then
    return
end

harpoon.setup({
    menu = {
        width = math.ceil(vim.api.nvim_win_get_width(0) / 3),
    },
})
