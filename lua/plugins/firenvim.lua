local blacklistedSites = { ".*twitch\\.tv.*", ".*twitter\\.com.*" }

local globalSettings = {
    ["alt"] = "all",
}

local localSettings = {
    [".*"] = {
        cmdline = "neovim",
        content = "text",
        priority = 0,
        selector = "textarea",
        takeover = "never",
    },
}

for _, site in pairs(blacklistedSites) do
    localSettings[site] = { takeover = "never" }
end

vim.g.firenvim_config = {
    globalSettings = globalSettings,
    localSettings = localSettings,
}

vim.cmd([[
  function! OnUIEnter(event) abort
    if 'Firenvim' ==# get(get(nvim_get_chan_info(a:event.chan), 'client', {}), 'name', '')
      set laststatus=0
      set showmode
      set signcolumn=no
    endif
  endfunction

  autocmd UIEnter * call OnUIEnter(deepcopy(v:event))
]])
