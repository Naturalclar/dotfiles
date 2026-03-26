# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `make` or `make dotfiles` — symlink all dotfiles (`.??*` except `.git`, `.gitignore`, etc.) into `$HOME`
- `make config` — symlink `.config/*` entries into `$HOME/.config/`
- `make vscodeExtensions` — sync VSCode extensions via `configs/.vscode/vscodeSync.sh`
- `make claudeCommands` — symlink `.config/claude/commands/` to `~/.claude/commands/` for global Claude Code slash commands
- `make list` — show which dotfiles will be symlinked
- `make help` — print all make targets
- Windows setup: run `./bootstrap.ps1` to concatenate `windows/*.ps1` into the PowerShell `$PROFILE`

## CI

- **lint.yml** — checks `.zshrc` syntax with `zsh -n` and sources it on Ubuntu
- **make.yml** — runs `make` on macOS

## Architecture

This is a cross-platform dotfiles repo (macOS, Linux/WSL, Windows). The core mechanism is simple: `make dotfiles` creates symlinks from this repo into `$HOME`.

### Key files
- `.zshrc` — main shell config; defines aliases, functions, PATH setup, keybindings. OS-specific blocks use `uname` detection (Darwin/Linux/Msys)
- `.config/nvim/` — Neovim config using LazyVim framework (`config/lazy.lua` bootstraps lazy.nvim, plugins in `lua/plugins/`)
- `.config/fish/` — Fish shell config (alternative shell)
- `configs/.vscode/` — VSCode settings, keybindings, and extension sync script
- `.scripts/` — custom CLI tools added to PATH (`duck`, `google`, `pmux`, `git-worktree-pull`)
- `powershell/` — komorebi window manager start/stop scripts
- `ahk/` — AutoHotKey scripts (remap keys, language switching, shortcuts)
- `keymaps/` — custom keyboard layout mappings
- `.config/kitty/`, `.config/hypr/`, `.config/i3/`, `.config/waybar/` — terminal and WM configs

### Key tools assumed installed
- **ghq** — repository management (`ghq get`, `ghq list`)
- **peco/fzf** — fuzzy selection (workspace switching, history, script selection)
- **asdf** — version manager for Node.js, Java, etc.
- **lazygit** — terminal git UI (aliased as `lg`)

### Notable shell functions
- `run-script` (alias `rs`, keybind `Ctrl+N`) — fzf-based package.json script selector; auto-detects package manager from lockfile
- `peco-workspace` (alias `ws`, keybind `Ctrl+W`) — cd to ghq-managed repos via peco
- `fzf-workspace` (alias `wf`, keybind `Ctrl+A`) — cd to ghq-managed repos via fzf with README preview
- `peco-history-selection` (keybind `Ctrl+Z`) — search shell history

### Testing
Tests are in `test/`. Each subdirectory has a `package.json` for testing the `run-script` function:
- `cd test/test-package-scripts && rs` — test basic script selection
- `cd test/test-colon-scripts && rs` — test scripts with colons in names

## Code Style

- Match existing formatting in each file
- Shell scripts: prefer POSIX-compatible syntax when possible
- PowerShell scripts: follow Microsoft best practices
- The `.zshrc` uses vi mode (`set -o vi`)

## Environment Variables

Secret API keys go in `~/.config/secrets/credentials.sh` (auto-sourced by `.zshrc`, gitignored).
