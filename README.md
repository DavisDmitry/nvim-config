# nvim-config

My Neovim config with an IDE-style layout: file tree on the left, editor with tabs and breadcrumbs in the middle, a terminal under the editor, and Claude Code on the right.

## Install

```sh
git clone git@github.com:DavisDmitry/nvim-config.git ~/.config/nvim
brew install tree-sitter-cli   # needed to compile tree-sitter parsers
nvim                           # lazy.nvim installs plugins, Mason installs LSP servers
```

Requirements: Neovim 0.12+, git, a Nerd Font, and the `claude` CLI in `PATH` for the Claude Code panel.

## Plugins

- **UI:** github-nvim-theme (`github_dark_dimmed`), bufferline, lualine, dropbar, which-key, snacks.nvim
- **Explorer:** neo-tree
- **Claude Code:** claudecode.nvim
- **Code:** nvim-treesitter, basedpyright + ruff (via Mason), blink.cmp, conform.nvim, gitsigns

## Keys

`<leader>` is Space.

| Key | Action |
|---|---|
| `<leader>L` / `:IDE` | Open the full layout |
| `<leader>e` | Focus file tree / jump back |
| `<C-b>` | Toggle file tree |
| `` <C-`> `` / `<C-\>` | Toggle terminal |
| `<leader>ac` | Toggle Claude Code |
| `<leader>ar` | Resume a Claude chat |
| `<C-p>` / `<leader>fg` | Find files / search text |
| `<leader>q` / `:Q` | Quit everything |