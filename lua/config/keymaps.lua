local map = vim.keymap.set
local term = require("config.terminal")

-- General
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
-- Quit everything in one go: stop terminal jobs (fish, Claude) so they don't
-- block :qa, then quit, asking only about unsaved files.
local function quit_all()
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

-- Move lines (Alt+j/k, like Alt+Up/Down in VS Code)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal panel (Ctrl+` like VS Code; Ctrl+\ as a fallback that always works)
for _, key in ipairs({ "<C-`>", "<C-\\>" }) do
  map({ "n", "t" }, key, term.toggle, { desc = "Toggle terminal" })
end
map("n", "<leader>tt", term.toggle, { desc = "Toggle terminal" })
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
