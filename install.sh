#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m==> %s\033[0m\n' "$1"; }
ok()    { printf '\033[1;32m  OK: %s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m  WARN: %s\033[0m\n' "$1"; }

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "Homebrew already installed"
fi

# --- Packages ---
info "Installing packages via Homebrew..."
brew install neovim ripgrep fd
brew install --cask ghostty
brew install --cask font-jetbrains-mono-nerd-font

# --- Neovim config ---
info "Copying Neovim config..."
mkdir -p ~/.config/nvim
if [ -e ~/.config/nvim/init.lua ]; then
  warn "~/.config/nvim/init.lua exists — backing up to init.lua.bak"
  cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.bak
fi
cp "$REPO_DIR/nvim/init.lua" ~/.config/nvim/init.lua
ok "Copied nvim/init.lua -> ~/.config/nvim/init.lua"

# --- Ghostty config ---
info "Copying Ghostty config..."
mkdir -p ~/.config/ghostty
if [ -e ~/.config/ghostty/config ]; then
  warn "~/.config/ghostty/config exists — backing up to config.bak"
  cp ~/.config/ghostty/config ~/.config/ghostty/config.bak
fi
cp "$REPO_DIR/ghostty/config" ~/.config/ghostty/config
ok "Copied ghostty/config -> ~/.config/ghostty/config"

# --- Done ---
echo ""
info "Done! Next steps:"
echo "  1. Open Ghostty"
echo "  2. Run 'nvim' — plugins install automatically on first launch"
echo "  3. Inside nvim run :Lazy sync if needed"
