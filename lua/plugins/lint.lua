-- Linters that have no language server, run from the project's .venv.
-- Report-only: they never change the file.
return {
  "mfussenegger/nvim-lint",
  ft = "python",
  config = function()
    local lint = require("lint")
    local project = require("config.project")

    -- mypy reads the file from disk, so it runs on open and on every save
    -- (autosave included), with the project's settings from its root.
    -- The .venv mypy also resolves imports from that same environment.
    lint.linters.mypy.cmd = function()
      return project.bin(project.root(0), "mypy") or "mypy"
    end

    local function run(buf)
      if vim.bo[buf].filetype ~= "python" then return end
      local root = project.root(buf)
      if project.uses(root, "mypy") then
        lint.try_lint("mypy", { cwd = root })
      end
    end

    local group = vim.api.nvim_create_augroup("project_lint", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "python",
      callback = function(ev) run(ev.buf) end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      callback = function(ev) run(ev.buf) end,
    })
    -- The Python buffer whose FileType triggered loading this plugin
    local buf = vim.api.nvim_get_current_buf()
    vim.schedule(function() run(buf) end)
  end,
}