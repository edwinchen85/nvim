vim.cmd([[
  try
    colorscheme tokyonight-storm
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])

-- vim.cmd([[
--   hi Folded guibg=NONE ctermbg=NONE
--   hi Normal guibg=NONE ctermbg=NONE
--   hi NormalFloat guibg=NONE ctermbg=NONE
--   hi NonText guibg=NONE ctermbg=NONE
--   hi SignColumn guibg=NONE ctermbg=NONE
--   hi LineNr guibg=NONE ctermbg=NONE
--   hi StatusLine guibg=NONE ctermbg=NONE
--   hi TelescopeNormal guibg=NONE ctermbg=NONE
--   hi TelescopeBorder guibg=NONE ctermbg=NONE
--   hi GitSignsAdd guibg=NONE ctermbg=NONE
--   hi GitSignsChange guibg=NONE ctermbg=NONE
--   hi GitSignsDelete guibg=NONE ctermbg=NONE
--   hi WhichKeyFloat guibg=NONE ctermbg=NONE
-- ]])
