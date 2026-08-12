# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `make` or `make dotfiles` — symlink all dotfiles (`.??*` except `.git`, `.gitignore`, etc.) into `$HOME`
- `make config` — symlink `.config/*` entries into `$HOME/.config/`
- `make claude` — symlink `configs/claude/settings.json` to `~/.claude/settings.json` (Claude Code hooks etc.; machine-local state like `feedbackSurveyState` is intentionally not committed)
- `make vscodeExtensions` — sync VSCode extensions via `configs/.vscode/vscodeSync.sh`
- `make list` — show which dotfiles will be symlinked
- `make help` — print all make targets
- Windows setup: run `./bootstrap.ps1` to point the PowerShell `$PROFILE` at `windows/*.ps1` in the clone; the `setup-*.ps1` scripts symlink the remaining configs and need Developer Mode or an elevated shell; `setup-defaults.ps1` applies one-time machine settings (key repeat) and is not part of the profile

## CI

- **lint.yml** — checks `.zshrc` and each `.zsh/*.zsh` module with `zsh -n`, sources the whole config, then runs shellcheck, actionlint, gitleaks and the bats suites on Ubuntu
- **make.yml** — runs `make` on macOS
- PowerShell scripts are parsed and linted with PSScriptAnalyzer on Ubuntu (`pwsh` needs no Windows runner for that); nothing exercises them on Windows

## Architecture

This is a cross-platform dotfiles repo (macOS, Linux/WSL, Windows). The core mechanism is simple: `make dotfiles` creates symlinks from this repo into `$HOME`.

### Key files
- `.zshrc` — loader only; sources `.zsh/*.zsh` in filename order
- `.zsh/*.zsh` — the actual shell config, split by concern. The numeric prefix is load order and matters: `00` options/locale, `10` OS-specific (`uname` detection for Darwin/Linux/Msys), `20` history, `30` runtimes, `40` prompt, `50` PATH, `60` plugins, `70`–`75` aliases and widgets, `80`+ late setup. Concatenating them in order reproduces the single file they replaced
- `.config/nvim/` — Neovim config using LazyVim framework (`config/lazy.lua` bootstraps lazy.nvim, plugins in `lua/plugins/`)
- `.config/fish/` — Fish shell config (experimental, best-effort). zsh is the source of truth for aliases and functions; fish carries only a subset. An alias defined in both shells must behave identically — add it to the matching `.zsh/*.zsh` module first
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
- The zsh config uses vi mode (`set -o vi`, in `.zsh/00-core.zsh`)
- Add zsh settings to the module that matches their concern, not to `.zshrc`

## Environment Variables

Secret API keys go in `~/.config/secrets/credentials.sh` (auto-sourced by `.zsh/80-late.zsh`, gitignored).
