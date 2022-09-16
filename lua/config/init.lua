require("config.commands")
require("config.keymaps")
require("config.settings")

-- kept in a separate repository to avoid noisy changes
pcall(require, "config.theme")
