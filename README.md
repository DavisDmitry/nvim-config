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

The workspace has four zones, and each one uses the same keys:
`<leader>{zone}f` focuses the zone (opening it if hidden),
`<leader>{zone}t` shows or hides it without moving the cursor.

| Zone | Focus | Show / hide |
|---|---|---|
| Files (`e`) | `<leader>ef` | `<leader>et` |
| Code (`c`) | `<leader>cf` | — |
| Claude (`a`) | `<leader>af` | `<leader>at` |
| Terminal (`t`) | `<leader>tf` | `<leader>tt` |

Shortcuts that also work from inside the terminal and Claude:
`<C-b>` (files), `<C-1>` (code), `<C-,>` (Claude), `` <C-`> `` (terminal).

| Key | Action |
|---|---|
| `<leader>L` / `:IDE` | Open the full layout |
| `<leader>ar` | Resume a Claude chat |
| `<leader>c=` | Format file |
| `<C-p>` / `<leader>fg` | Find files / search text |
| `<leader>q` / `:Q` | Quit everything |