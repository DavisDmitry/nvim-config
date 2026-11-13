local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user", { clear = true })

-- `nvim` or `nvim .` → open the explorer sidebar, like opening a folder in VS Code
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
