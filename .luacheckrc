-- Luacheck configuration for Neovim
globals = {
    "vim", -- Neovim global
}

read_globals = {
    "Snacks", -- set by snacks.nvim's setup
}

-- Ignore line length warnings
max_line_length = false

-- Ignore unused arguments warnings for common patterns
ignore = {
    "631", -- Line too long
    "212", -- Unused argument
    "213", -- Unused loop variable
}

-- Specific rules for test files
files["*_spec.lua"] = {
    std = "+busted",
}

-- Don't report unused self arguments of methods
self = false
