return {
  -- Theme (variants: github_dark, github_dark_dimmed, github_dark_default,
  -- github_dark_high_contrast, github_light, github_light_default, ...)
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = { styles = { comments = "italic" } },
      })
      vim.cmd.colorscheme("github_dark_dimmed")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Utilities: picker (Ctrl+P), notifications, indent guides, bufdelete
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      bigfile = { enabled = true },
      words = { enabled = true }, -- highlight references under cursor
    },
    keys = {
      { "<C-p>", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Search in files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Open tabs" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Problems" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fc", function() Snacks.picker.commands() end, desc = "Command palette" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notifications" },
    },
  },

  -- Tab bar
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "thin",
        hover = { enabled = true, delay = 150, reveal = { "close" } },
        -- Keep tabs above the editor only, not above the side panels
        offsets = {
          { filetype = "neo-tree", text = "Explorer", text_align = "left", separator = true },
          { filetype = "snacks_terminal", text = "Claude Code", text_align = "left", separator = true },
        },
      },
    },
  },

  -- Breadcrumbs (src > aiogram_screens > screens.py > Class > method)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "Pick breadcrumb" },
    },
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local function venv()
        local v = os.getenv("VIRTUAL_ENV")
        if vim.bo.filetype ~= "python" then return "" end
        if v then return "🐍 " .. vim.fn.fnamemodify(v, ":h:t") end
        if vim.uv.fs_stat(vim.fn.getcwd() .. "/.venv") then
          return "🐍 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end
        return ""
      end
      local function lsp_names()
        local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
        return table.concat(names, ", ")
      end
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "",
          section_separators = "",
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { "diagnostics", { "filename", path = 1 } },
          lualine_x = {
            { "location", fmt = function() return ("Ln %d, Col %d"):format(vim.fn.line("."), vim.fn.col(".")) end },
            { function() return (vim.bo.expandtab and "Spaces: " or "Tab Size: ") .. vim.bo.shiftwidth end },
            { "encoding", fmt = string.upper },
            { "fileformat", icons_enabled = false, fmt = function(s) return s == "unix" and "LF" or "CRLF" end },
            "filetype",
            venv,
            lsp_names,
          },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "mason" },
      }
    end,
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      -- Hide the Russian-layout twins from langmapper (they still work)
      filter = function(mapping)
        return not (mapping.lhs or ""):find("[\208\209]") -- Cyrillic UTF-8 lead bytes
      end,
      spec = {
        { "<leader>a", group = "Claude Code" },
        { "<leader>b", group = "Tabs" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git hunks" },
        { "<leader>t", group = "Terminal" },
        { "<leader>u", group = "UI" },
      },
    },
  },
}
