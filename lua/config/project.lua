-- Python linting/formatting follows the open project: a tool (ruff, black,
-- isort) runs only if it is installed in the project's own virtualenv
-- (.venv or venv), and always that local binary — never a global one.
-- Its settings come from the project's config (pyproject.toml, ruff.toml...).
local M = {}

local ROOT_MARKERS = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.cfg", "tox.ini", ".git" }
local VENV_DIRS = { ".venv", "venv" }

---Project root for a buffer (or nil outside any project)
---@param buf integer
---@return string?
function M.root(buf)
  return vim.fs.root(buf, ROOT_MARKERS)
end

---Path to `tool` in the project's virtualenv, or nil if it isn't installed there
---@param root string?
---@param tool string
---@return string?
function M.bin(root, tool)
  if not root then return nil end
  for _, dir in ipairs(VENV_DIRS) do
    local path = ("%s/%s/bin/%s"):format(root, dir, tool)
    if vim.fn.executable(path) == 1 then return path end
  end
  return nil
end

---Whether the project at `root` has `tool` installed locally
---@param root string?
---@param tool string
function M.uses(root, tool)
  return M.bin(root, tool) ~= nil
end

---Whether the buffer's project has a StyLua config
---@param buf integer
function M.has_stylua(buf)
  return vim.fs.root(buf, { "stylua.toml", ".stylua.toml" }) ~= nil
end

return M