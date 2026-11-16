-- Russian ↔ English keyboard layout, by key position.
-- Only letters: they are on the same keys in macOS "Russian" and
-- "Russian – PC"; punctuation and ё differ between the two.
local M = {}

M.en = [[QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>qwertyuiop[]asdfghjkl;'zxcvbnm,.]]
M.ru = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю]]

local ru_chars = vim.fn.split(M.ru, [[\zs]])
local en_chars = vim.fn.split(M.en, [[\zs]])
local to_en = {}
for i, ch in ipairs(ru_chars) do
  to_en[ch] = en_chars[i]
end

---English key for a Russian one (other keys are returned unchanged)
---@param key string
---@return string
function M.to_en(key)
  return to_en[key] or key
end

return M