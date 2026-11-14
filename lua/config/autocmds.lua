local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user", { clear = true })

-- `nvim` or `nvim .` → open the explorer sidebar
au("VimEnter", {
  group = group,
  callback = function()
    local arg = vim.fn.argv(0)
    local is_dir = arg ~= "" and vim.fn.isdirectory(arg) == 1
    if arg ~= "" and not is_dir then
      return
    end
    if is_dir then
      local dir_buf = vim.api.nvim_get_current_buf()
      vim.cmd.cd(arg)
      vim.cmd.enew()
      pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
    end
    vim.cmd("Neotree show")
  end,
})

-- Ruler at 88 for Python (ruff/black line length)
au("FileType", {
  group = group,
  pattern = "python",
  callback = function() vim.opt_local.colorcolumn = "88" end,
})

-- Highlight on yank
au("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Reload files changed outside (Claude edits, git checkout, ...)
au({ "FocusGained", "BufEnter", "TermLeave" }, {
  group = group,
  command = "silent! checktime",
})

-- Autosave: 1s after edits stop (outside insert mode), and right away when
-- leaving the buffer or Neovim. Skips formatting (see conform in lsp.lua);
-- an explicit :w / <C-s> still formats.
local autosave_timers = {}

local function autosave(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local bo = vim.bo[buf]
  if bo.buftype ~= "" or not bo.modifiable or bo.readonly or not bo.modified then return end
  if vim.api.nvim_buf_get_name(buf) == "" then return end
  if buf == vim.api.nvim_get_current_buf() and vim.fn.mode():match("^[iR]") then return end
  vim.b[buf].autosaving = true
  vim.api.nvim_buf_call(buf, function() vim.cmd("silent! lockmarks update") end)
  vim.b[buf].autosaving = false
end

local function schedule_autosave(buf)
  local timer = autosave_timers[buf]
  if not timer then
    timer = assert(vim.uv.new_timer())
    autosave_timers[buf] = timer
  end
  timer:stop()
  timer:start(1000, 0, vim.schedule_wrap(function() autosave(buf) end))
end

au({ "InsertLeave", "TextChanged" }, {
  group = group,
  callback = function(ev) schedule_autosave(ev.buf) end,
})
au({ "BufLeave", "FocusLost", "VimLeavePre" }, {
  group = group,
  callback = function(ev) autosave(ev.buf) end,
})
au("BufWipeout", {
  group = group,
  callback = function(ev)
    local timer = autosave_timers[ev.buf]
    if timer then
      timer:stop()
      timer:close()
      autosave_timers[ev.buf] = nil
    end
  end,
})

-- Restore cursor position
au("BufReadPost", {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
