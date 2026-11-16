local map = vim.keymap.set
local term = require("config.terminal")

-- General
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
-- Quit everything in one go: stop terminal jobs (fish, Claude) so they don't
-- block :qa, then quit, asking only about unsaved files.
local function quit_all()
  -- Stopping the job of the terminal the cursor is in (e.g. the Claude panel)
  -- aborts the quit, so step into a regular window first.
  if vim.bo.buftype == "terminal" then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype ~= "terminal" and vim.api.nvim_win_get_config(win).relative == "" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end
  local jobs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local job = vim.b[buf].terminal_job_id
      if job and pcall(vim.fn.jobstop, job) then table.insert(jobs, job) end
    end
  end
  if #jobs > 0 then vim.fn.jobwait(jobs, 2000) end
  vim.cmd("confirm qa")
end
vim.api.nvim_create_user_command("Q", quit_all, { desc = "Quit everything" })
map("n", "<leader>q", quit_all, { desc = "Quit all" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Wider window" })

-- Tabs (buffers)
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Close tab" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Close other tabs" })
map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Pick tab" })

-- Move lines (Alt+j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal panel (Ctrl+`; Ctrl+\ as a fallback that always works)
-- <C-\> is not mapped in terminal mode: it would break the built-in <C-\><C-n>
map({ "n", "t" }, "<C-`>", term.toggle, { desc = "Toggle terminal" })
map("n", "<C-\\>", term.toggle, { desc = "Toggle terminal" })
-- Back to code from anywhere (terminal, Claude, explorer), panels stay open
map({ "n", "t" }, "<C-1>", term.focus_editor, { desc = "Focus code" })

-- Zones: <leader>{zone}f = focus, <leader>{zone}t = show/hide (see zones.lua)
-- e = files, c = code, a = Claude, t = terminal
local zones = require("config.zones")
map("n", "<leader>ef", zones.files_focus, { desc = "Focus files" })
map("n", "<leader>et", zones.files_toggle, { desc = "Show/hide files" })
map("n", "<leader>cf", zones.code_focus, { desc = "Focus code" })
map("n", "<leader>af", zones.claude_focus, { desc = "Focus Claude" })
map("n", "<leader>at", zones.claude_toggle, { desc = "Show/hide Claude" })
map("n", "<leader>tf", zones.terminal_focus, { desc = "Focus terminal" })
map("n", "<leader>tt", zones.terminal_toggle, { desc = "Show/hide terminal" })
-- Double Esc leaves terminal mode (single Esc is kept for the program inside)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Full IDE layout: explorer + terminal + Claude
vim.api.nvim_create_user_command("IDE", function()
  vim.cmd("Neotree show")
  if not term.is_open() then
    term.open()
    vim.cmd.stopinsert()
  end
  vim.cmd("ClaudeCode")
end, { desc = "Open explorer, terminal and Claude Code" })
map("n", "<leader>L", "<cmd>IDE<cr>", { desc = "IDE layout" })
