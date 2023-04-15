vim.cmd([[
  try
    colorscheme tokyonight-moon
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])

vim.cmd([[
    hi LineNr guifg=#565f89
    hi TelescopeNormal guifg=#a9b1d6 guibg=#1f2335
    hi TelescopeBorder guifg=#1f2335 guibg=#1f2335
    hi TelescopePromptNormal guibg=#2d3149
    hi TelescopePromptBorder guifg=#2d3149 guibg=#2d3149
    hi TelescopePromptTitle guifg=#2d3149 guibg=#2d3149
    hi TelescopePreviewTitle guifg=#1f2335 guibg=#1f2335
    hi TelescopeResultsTitle guifg=#1f2335 guibg=#1f2335
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
