-- Commands work on the Russian layout too (letters only, see config/layout.lua).
local layout = require("config.layout")
local en, ru = layout.en, layout.ru

-- 'langmap' covers built-in commands (hjkl, dd, ciw, ...)
local function escape(str)
  return vim.fn.escape(str, [[;,."|\]])
end
vim.opt.langmap = escape(ru) .. ";" .. escape(en)

-- langmapper.nvim covers mappings (<leader>aa, gd, <S-l>, ...), which
-- 'langmap' does not translate: it adds a Russian twin for each of them
return {
  "Wansmer/langmapper.nvim",
  lazy = false,
  priority = 1, -- load after everything else
  opts = {
    default_layout = en,
    layouts = {
      ru = { id = "com.apple.keylayout.Russian", layout = ru },
    },
  },
}