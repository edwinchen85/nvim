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