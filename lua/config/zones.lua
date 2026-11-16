-- Workspace zones: files (explorer), code, Claude, terminal.
-- Same keys for every zone (see keymaps.lua):
--   <leader>{zone}f  focus: move the cursor there, opening the zone if hidden
--   <leader>{zone}t  toggle: show/hide the zone, the cursor stays where it is
local term = require("config.terminal")

local M = {}

-- Run `fn` and come back to the current window
local function keep_focus(fn)
  local win = vim.api.nvim_get_current_win()
  local mode = vim.fn.mode()
  fn()
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
  if mode ~= "t" then vim.cmd.stopinsert() end
end

-- Files ---------------------------------------------------------------------

function M.files_focus()
  vim.cmd("Neotree focus")
end

function M.files_toggle()
  vim.cmd("Neotree show toggle")
end

-- Code ----------------------------------------------------------------------

M.code_focus = term.focus_editor

-- Claude --------------------------------------------------------------------

local function claude_win()
  local ok, cc = pcall(require, "claudecode.terminal")
  local buf = ok and cc.get_active_terminal_bufnr()
  if not buf then return nil end
  local win = vim.fn.bufwinid(buf)
  return win ~= -1 and win or nil
end

function M.claude_focus()
  local win = claude_win()
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd.startinsert()
  else
    vim.cmd("ClaudeCodeOpen")
  end
end

function M.claude_toggle()
  if claude_win() then
    vim.cmd("ClaudeCode") -- visible: hide it (the session keeps running)
  else
    keep_focus(function() vim.cmd("ClaudeCodeOpen") end)
  end
end

-- Terminal ------------------------------------------------------------------

M.terminal_focus = term.open

function M.terminal_toggle()
  if term.is_open() then
    term.close()
  else
    keep_focus(term.open)
  end
end

return M