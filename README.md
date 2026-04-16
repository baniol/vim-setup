# Dev Setup — Neovim + Ghostty

Portable config for Neovim and Ghostty terminal on macOS.

## Requirements

- macOS (install script uses Homebrew)
- Neovim 0.11+ (required for `vim.lsp.config` / `vim.lsp.enable` API)
- Language toolchains installed separately as needed: `rustup`, `go`, `python`

## Quick Install

```bash
git clone https://github.com/baniol/dev-setup ~/projects/dev-setup
cd ~/projects/dev-setup
./install.sh
```

The script installs Homebrew (if missing), Neovim, ripgrep, fd, Ghostty, and JetBrains Mono Nerd Font, then copies config files to `~/.config/`. Existing configs are backed up with a `.bak` suffix.

## Post-Install

1. Open Ghostty
2. Run `nvim` — lazy.nvim bootstraps and installs plugins automatically
3. If plugins don't install: `:Lazy sync`
4. LSP servers install on first open via Mason (`:Mason` to check status)

## Repo Structure

```
├── install.sh        # one-command setup
├── nvim/
│   └── init.lua      # Neovim config (lazy.nvim + all plugins)
└── ghostty/
    └── config        # Ghostty terminal config
```

## What's Included

### Neovim

| Category | Plugins |
|----------|---------|
| Theme | tokyonight, catppuccin, kanagawa, rose-pine, nightfox, gruvbox-material |
| Navigation | Telescope (fuzzy finder), nvim-tree (file explorer) |
| Editing | treesitter, autopairs, Comment.nvim |
| LSP | mason + lspconfig (gopls, lua_ls, rust_analyzer, pyright) |
| Completion | nvim-cmp + LuaSnip + friendly-snippets |
| Git | gitsigns (hunks), vim-fugitive (status, commit, push) |
| Languages | rustaceanvim (Rust), go.nvim (Go) |
| Markdown | render-markdown.nvim (styled in-buffer preview) |

### Ghostty

| Setting | Value |
|---------|-------|
| Font | JetBrainsMono Nerd Font Mono, 14pt |
| Theme | TokyoNight Night |
| Window | macOS tabs, 8px padding |
| Cursor | block, no blink |
| macOS | Option-as-Alt, copy-on-select |

## Keymaps

Leader = `Space`

### Theme Switching

`<leader>ft` opens a Telescope picker with themes that are available in both Neovim and Ghostty. Moving the cursor previews the theme live in Neovim; pressing Enter applies it to both Neovim and Ghostty simultaneously. Pressing Esc cancels and restores the previous theme.

Available paired themes:

| Neovim colorscheme | Ghostty theme |
|---|---|
| `tokyonight-night` / `storm` / `moon` / `day` | TokyoNight Night / Storm / Moon / Day |
| `catppuccin-mocha` / `latte` / `frappe` / `macchiato` | Catppuccin Mocha / Latte / Frappe / Macchiato |
| `kanagawa` / `kanagawa-dragon` / `kanagawa-lotus` | Kanagawa Wave / Dragon / Lotus |
| `rose-pine` / `rose-pine-moon` / `rose-pine-dawn` | Rose Pine / Moon / Dawn |
| `gruvbox-material` | Gruvbox Material |
| `nightfox` / `dayfox` / `carbonfox` / `nordfox` | Nightfox / Dayfox / Carbonfox / Nordfox |

Ghostty config is updated at `~/.config/ghostty/config` and reloaded automatically via `Cmd+Shift+,`.

### General

| Shortcut | Action |
|----------|--------|
| `Space ft` | Pick theme (Neovim + Ghostty) |
| `Space t` | Toggle file tree |
| `Space ff` | Find files |
| `Space fg` | Live grep |
| `Space fb` | Buffers |
| `Space q` | Close quickfix/loclist |
| `Space cp` | Copy file path to clipboard |
| `Space sh` | Open terminal in bottom split |
| `Esc` (in terminal) | Exit terminal mode to normal |

### LSP (active when server attaches)

| Shortcut | Action |
|----------|--------|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `gl` | Line diagnostics |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `Space f` | Format file |
| `[d` / `]d` | Prev/next diagnostic |

### Git

| Shortcut | Action |
|----------|--------|
| `Space gs` | Git status |
| `Space gc` | Git commit |
| `Space gp` | Git push |
| `Space gl` | Git log |
| `Space gd` | Diff split |
| `]h` / `[h` | Next/prev hunk |
| `Space hs` | Stage hunk |
| `Space hr` | Reset hunk |
| `Space hp` | Preview hunk |
| `Space hb` | Blame line |

## Updating Configs

Edit configs in `~/.config/` as usual. To save changes back to the repo:

```bash
cp ~/.config/nvim/init.lua <repo-dir>/nvim/init.lua
cp ~/.config/ghostty/config <repo-dir>/ghostty/config
```

To re-apply repo configs to the system, run `./install.sh` again.
