-- Claude Code in the right panel, connected to Neovim over the same IDE
-- protocol the IDE extensions use (sees selection, opens diffs, etc.)

-- `:ClaudeCode --resume` only works when Claude isn't running yet: on a live
-- session it just toggles the panel and ignores the args. So: if a session is
-- running, show the panel and send the slash command into it instead.
local function claude(args, slash)
  return function()
    local term = require("claudecode.terminal")
    if term.get_active_terminal_bufnr() then
      term.open()
      if slash then
        vim.cmd("ClaudeCodeSendText " .. slash)
      end
    else
      term.open({}, args)
    end
  end
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = { "ClaudeCode", "ClaudeCodeOpen", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
  opts = {
    terminal = {
      split_side = "right",
      split_width_percentage = 0.30,
    },
    diff_opts = {
      -- Each proposed change opens in its own tab page, leaving the editor
      -- layout untouched; the tab closes on accept/reject
      open_in_new_tab = true,
    },
  },
  keys = {
    -- <leader>af / <leader>at (focus / show-hide) are in config/keymaps.lua
    { "<C-,>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "t" }, desc = "Focus/toggle Claude" },
    { "<leader>ar", claude("--resume", "/resume"), desc = "Resume session (pick chat)" },
    { "<leader>aC", claude("--continue"), desc = "Continue last session" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current file" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file from tree", ft = { "neo-tree" } },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject diff" },
  },
}
