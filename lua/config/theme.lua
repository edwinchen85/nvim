if not pcall(vim.cmd.colorscheme, "tokyonight") then
    vim.cmd.colorscheme("default")
    vim.o.background = "dark"
end
