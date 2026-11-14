-- Commands work on the Russian layout too.
-- Only letters are mapped (same keys in macOS "Russian" and "Russian – PC";
-- punctuation and ё differ between the two, so they are left out).
local en = [[QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>qwertyuiop[]asdfghjkl;'zxcvbnm,.]]
local ru = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю]]

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