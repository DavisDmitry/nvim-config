return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true, -- "You, yesterday" like GitLens
    current_line_blame_opts = { delay = 500 },
    on_attach = function(buf)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
      end
      map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
      map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>hd", gs.diffthis, "Diff file")
      map("n", "<leader>gb", function() Snacks.picker.git_branches() end, "Branches")
      map("n", "<leader>gl", function() Snacks.picker.git_log() end, "Git log")
    end,
  },
}
