return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    -- <leader>ef / <leader>et (focus / show-hide) are in config/keymaps.lua
    { "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal file in explorer" },
    { "<leader>be", "<cmd>Neotree buffers<cr>", desc = "Open editors" },
    { "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Git changes" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    -- Tabs on top of the sidebar: Files | Open Editors | Git
    source_selector = {
      winbar = true,
      sources = {
        { source = "filesystem", display_name = " 󰉓 Files " },
        { source = "buffers", display_name = " 󰈚 Open " },
        { source = "git_status", display_name = " 󰊢 Git " },
      },
    },
    window = {
      position = "left",
      width = 34,
      mappings = {
        ["<space>"] = "none", -- keep <leader> working inside the tree
        ["l"] = "open",
        ["h"] = "close_node",
        ["P"] = { "toggle_preview", config = { use_float = true } },
      },
    },
    filesystem = {
      hijack_netrw_behavior = "disabled", -- handled in autocmds.lua
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true, -- refresh when files change on disk
      group_empty_dirs = true, -- show "src/aiogram_screens" as one node
      filtered_items = {
        visible = true, -- show hidden files dimmed
        hide_dotfiles = false,
        hide_gitignored = false,
        never_show = { ".DS_Store", ".git" },
      },
    },
    default_component_configs = {
      indent = { with_expanders = true },
      git_status = {
        symbols = {
          added = "A", modified = "M", deleted = "D", renamed = "R",
          untracked = "U", ignored = "", unstaged = "", staged = "S", conflict = "!",
        },
      },
    },
  },
}
