vim.g.tokyonight_style = "night" -- 'storm, night, day'
vim.g.tokyonight_transparent = true
vim.g.tokyonight_transparent_sidebar = true
vim.g.tokyonight_hide_inactive_statusline = true
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_italic_variables = true
vim.g.tokyonight_terminal_colors = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }

vim.cmd([[
  try
    colorscheme solarized
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])

vim.cmd([[
  hi Folded guibg=NONE ctermbg=NONE
  hi Normal guibg=NONE ctermbg=NONE
  hi NormalFloat guibg=NONE ctermbg=NONE
  hi NonText guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi StatusLine guibg=NONE ctermbg=NONE
  hi TelescopeNormal guibg=NONE ctermbg=NONE
  hi TelescopeBorder guibg=NONE ctermbg=NONE
  hi GitSignsAdd guibg=NONE ctermbg=NONE
  hi GitSignsChange guibg=NONE ctermbg=NONE
  hi GitSignsDelete guibg=NONE ctermbg=NONE
  hi WhichKeyFloat guibg=NONE ctermbg=NONE
]])
