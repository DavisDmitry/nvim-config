local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
-- Gutter: signs | absolute number | relative number (both on every line)
function _G.user_statuscol()
  local win = vim.g.statusline_winid
  if not vim.wo[win].number then
    return "%s"
  end
  if vim.v.virtnum ~= 0 then
    return "%s" -- wrapped / virtual line: no numbers
  end
  local width = #tostring(vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win)))
  local rel = vim.v.relnum == 0 and "" or tostring(vim.v.relnum)
  local hl = vim.v.relnum == 0 and "%#CursorLineNr#" or "%#LineNr#"
  return ("%%s%s%" .. width .. "d %%#LineNr#%3s "):format(hl, vim.v.lnum, rel)
end
opt.statuscolumn = "%!v:lua.user_statuscol()"
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.laststatus = 3 -- one global statusline at the bottom
opt.showmode = false -- mode is shown in lualine
opt.showtabline = 2 -- always show the tab bar
opt.mouse = "a"
opt.mousemoveevent = true -- hover effects in bufferline
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.fillchars = { eob = " ", vert = "│" }
opt.pumheight = 12
opt.winborder = "rounded"

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true
opt.autoread = true -- reload files changed on disk (e.g. by Claude)
