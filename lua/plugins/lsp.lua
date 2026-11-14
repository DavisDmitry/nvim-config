return {
  -- LSP servers installer (:Mason)
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  -- Installs servers and runs vim.lsp.enable() for them
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      -- Python: basedpyright for types/hover/completion, ruff for lint + quick fixes
      vim.lsp.config("basedpyright", {
        -- Use the project's .venv even if nvim was started without activating it
        before_init = function(_, config)
          local py = config.root_dir and (config.root_dir .. "/.venv/bin/python")
          if py and vim.uv.fs_stat(py) then
            config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
              python = { pythonPath = py },
            })
          end
        end,
        settings = {
          basedpyright = {
            analysis = { typeCheckingMode = "standard", autoImportCompletions = true },
          },
        },
      })

      -- ruff LSP (linting) only in projects with ruff in their .venv,
      -- running that local ruff
      local project = require("config.project")
      vim.lsp.config("ruff", {
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start({ project.bin(config.root_dir, "ruff"), "server" }, dispatchers, {
            cwd = config.root_dir,
          })
        end,
        root_dir = function(buf, on_dir)
          local root = project.root(buf)
          if project.uses(root, "ruff") then on_dir(root) end
        end,
      })

      require("mason-lspconfig").setup({
        -- ruff is not installed globally: it comes from each project's .venv
        ensure_installed = { "basedpyright", "lua_ls" },
        automatic_enable = { exclude = { "ruff" } },
      })
      vim.lsp.enable("ruff") -- enabled here, not by Mason (see root_dir above)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false -- leave hover to basedpyright
          end
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          -- Built-in defaults also exist: K, grn, gra, grr, gri, gO
          map("gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", function() Snacks.picker.lsp_references() end, "References")
          map("gI", function() Snacks.picker.lsp_implementations() end, "Implementations")
          map("gy", function() Snacks.picker.lsp_type_definitions() end, "Type definition")
          map("<F2>", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>ci", function()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
          end, "Organize imports")
          map("<leader>uh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, "Toggle inlay hints")
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, prefix = "●" },
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
          },
        },
      })
    end,
  },

  -- Lua LSP knows about the Neovim API while editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } }, "snacks.nvim" } },
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
    },
  },

  -- Formatting (format on save, like "editor.formatOnSave")
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = "Format" },
    },
    opts = function()
      local project = require("config.project")
      -- Python tools always run from the project's .venv
      local function venv_command(tool)
        return { command = function(_, ctx) return project.bin(project.root(ctx.buf), tool) end }
      end
      return {
        formatters_by_ft = {
          -- Only the tools installed in this project's .venv; none → no formatting.
          -- Code style only: no `ruff check --fix` (lint fixes stay manual, <leader>ca).
          python = function(buf)
            local root = project.root(buf)
            local list = {}
            if project.uses(root, "isort") then table.insert(list, "isort") end
            if project.uses(root, "black") then
              table.insert(list, "black")
            elseif project.uses(root, "ruff") then
              table.insert(list, "ruff_format")
            end
            return list
          end,
          lua = function(buf)
            return project.has_stylua(buf) and { "stylua" } or {}
          end,
        },
        formatters = {
          ruff_format = venv_command("ruff"),
          black = venv_command("black"),
          isort = venv_command("isort"),
        },
        format_on_save = function(buf)
          if vim.b[buf].autosaving then return end -- autosave writes as-is
          -- No LSP fallback on save: a project without a formatter stays untouched
          return { timeout_ms = 1000, lsp_format = "never" }
        end,
      }
    end,
  },
}
