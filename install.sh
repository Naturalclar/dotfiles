#!/usr/bin/env bash

# install.sh — one-command setup for a new machine (macOS / Linux).
#
#   git clone https://github.com/Naturalclar/dotfiles.git && cd dotfiles && ./install.sh
#
# Idempotent: every step checks before acting, so re-running is safe.
# Windows uses bootstrap.ps1 instead.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASDF_VERSION="v0.13.1" # keep in sync with the version .zshrc expects

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# --- Homebrew (macOS) --------------------------------------------------------
if [ "$(uname)" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  # Third-party taps must be tapped and trusted before `brew bundle` can
  # install from them non-interactively (`brew trust` is a no-op on older brew).
  log "Tapping and trusting third-party taps"
  awk -F'"' '/^tap /{print $2}' "$REPO_DIR/Brewfile" | while read -r tap; do
    brew tap "$tap" >/dev/null 2>&1 || true
    brew trust "$tap" >/dev/null 2>&1 || true
  done

  log "Installing Homebrew packages (brew bundle --no-upgrade)"
  make -C "$REPO_DIR" brew
else
  log "Skipping Homebrew (non-macOS)"
fi

# --- git submodules (zsh plugins) --------------------------------------------
log "Initializing git submodules"
git -C "$REPO_DIR" submodule update --init

# --- symlinks -----------------------------------------------------------------
log "Symlinking dotfiles and .config into \$HOME"
make -C "$REPO_DIR" dotfiles
make -C "$REPO_DIR" config

# --- asdf and runtimes --------------------------------------------------------
if [ ! -d "$HOME/.asdf" ]; then
  log "Installing asdf ($ASDF_VERSION)"
  git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch "$ASDF_VERSION"
fi

log "Installing asdf runtimes from .tool-versions"
# shellcheck disable=SC1091
. "$HOME/.asdf/asdf.sh"
while read -r tool version; do
  case "$tool" in '' | \#*) continue ;; esac
  asdf plugin add "$tool" 2>/dev/null || true
  asdf install "$tool" "$version"
done <"$REPO_DIR/.tool-versions"

# --- macOS defaults -----------------------------------------------------------
if [ "$(uname)" = "Darwin" ]; then
  log "Setting macOS key-repeat defaults"
  defaults write -g InitialKeyRepeat -int 12 # normal minimum is 15 (225 ms)
  defaults write -g KeyRepeat -int 1         # normal minimum is 2 (30 ms)
fi

log "Done. Start a new zsh to pick everything up."
