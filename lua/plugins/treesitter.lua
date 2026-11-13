-- nvim-treesitter `main` branch (the old `master` is archived).
-- Compiling parsers requires the tree-sitter CLI: `brew install tree-sitter-cli`
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "python", "lua", "luadoc", "vim", "vimdoc", "query", "bash", "fish",
      "toml", "yaml", "json", "markdown", "markdown_inline", "regex", "gitignore", "diff",
    }
    if vim.fn.executable("tree-sitter") == 1 then
      require("nvim-treesitter").install(parsers)
    else
      vim.schedule(function()
        vim.notify("tree-sitter CLI not found: brew install tree-sitter-cli", vim.log.levels.WARN)
      end)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
