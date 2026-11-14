-- Bottom terminal panel: it opens *under the editor only*,
-- not under the explorer or the Claude panel (toggleterm/snacks always span
-- the full width, which is why this is hand-rolled).
local M = { buf = nil, win = nil, height = 15 }

local function is_editor_win(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == ""
end

local function editor_win()
  local cur = vim.api.nvim_get_current_win()
  if is_editor_win(cur) then
    return cur
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_editor_win(win) then
      return win
    end
  end
  return cur
end

-- Jump to code: the previous window if it holds code, else the first code window
function M.focus_editor()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  local target = (prev ~= 0 and is_editor_win(prev)) and prev or editor_win()
  if is_editor_win(target) then
    vim.api.nvim_set_current_win(target)
    vim.cmd.stopinsert()
  end
end

function M.is_open()
  return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

function M.close()
  if M.is_open() then
    M.height = vim.api.nvim_win_get_height(M.win)
    vim.api.nvim_win_hide(M.win)
  end
  M.win = nil
end

function M.open()
  if M.is_open() then
    vim.api.nvim_set_current_win(M.win)
    vim.cmd.startinsert()
    return
  end

  vim.api.nvim_set_current_win(editor_win())
  vim.cmd("belowright " .. M.height .. "split")
  M.win = vim.api.nvim_get_current_win()

  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_win_set_buf(M.win, M.buf)
  else
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(M.win, M.buf)
    vim.fn.jobstart(vim.o.shell, { term = true })
    vim.bo[M.buf].buflisted = false
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = M.buf,
      once = true,
      callback = function(ev)
        M.close()
        vim.schedule(function()
          pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
        end)
        M.buf = nil
      end,
    })
  end

  local wo = vim.wo[M.win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.cursorline = false
  wo.winfixheight = true
  vim.cmd.startinsert()
end

-- Closed → open and focus; open but elsewhere → focus; focused → hide
function M.toggle()
  if M.is_open() and vim.api.nvim_get_current_win() == M.win then
    M.close()
  else
    M.open()
  end
end

return M
