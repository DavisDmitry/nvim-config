-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw: neo-tree replaces it
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")

-- Russian twins for every mapping defined so far (later ones are handled
-- automatically); see lua/plugins/langmapper.lua
require("langmapper").automapping({ global = true, buffer = true })
