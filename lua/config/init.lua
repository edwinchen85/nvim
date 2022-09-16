require("config.commands")
require("config.keymappings")
require("config.settings")

-- kept in a separate repository to avoid noisy changes
pcall(require, "config.theme")
