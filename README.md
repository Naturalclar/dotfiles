# dotfile for Naturalclar

███╗   ██╗ █████╗ ████████╗██╗   ██╗██████╗  █████╗ ██╗      ██████╗██╗      █████╗ ██████╗ 
████╗  ██║██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██║     ██╔════╝██║     ██╔══██╗██╔══██╗
██╔██╗ ██║███████║   ██║   ██║   ██║██████╔╝███████║██║     ██║     ██║     ███████║██████╔╝
██║╚██╗██║██╔══██║   ██║   ██║   ██║██╔══██╗██╔══██║██║     ██║     ██║     ██╔══██║██╔══██╗
██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║  ██║██║  ██║███████╗╚██████╗███████╗██║  ██║██║  ██║
╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ 

[![Main workflow][mainworkflowbadge]][githubactions]

Easily set dotfiles using `Makefile`

[mainworkflowbadge]: https://github.com/Naturalclar/dotfiles/workflows/Main%20workflow/badge.svg
[githubactions]: https://github.com/Naturalclar/dotfiles/actions

## Mac or Linux

One-command setup for a new machine:

```
git clone https://github.com/Naturalclar/dotfiles.git && cd dotfiles && ./install.sh
```

`install.sh` (also available as `make bootstrap`) is idempotent and safe to re-run. It installs Homebrew and the Brewfile packages (macOS), initializes the zsh-plugin submodules, symlinks all dotfiles, installs asdf plus the runtimes in `.tool-versions`, and applies the macOS key-repeat settings.

For just the symlinks:

```
make            # symlink dotfiles into $HOME
make config     # symlink .config entries
```

## Windows

Run `bootstrap.ps1` to setup configuration for PowerShell

```
./bootstrap.ps1
```

## Shells

**zsh (`.zshrc`) is the source of truth.** It is the shell this repo is built around: it is what `install.sh` sets up, what CI lints (`zsh -n` plus a full `source`), and where every alias, function and keybinding lands first.

`.config/fish/` is **experimental** and maintained on a best-effort basis. It carries a subset of the zsh aliases and none of the more involved functions (`run-script`, `peco-workspace`, `fzf-workspace`, …). Fish is not installed by `install.sh` and is not in the `Brewfile`.

If you touch aliases:

- Add or change them in `.zshrc` first.
- Porting to fish is optional — but **an alias that exists in both shells must behave identically**. A name that means one thing in zsh and another in fish is worse than not having it in fish at all.

`test/aliases.bats` enforces that in CI, and also fails if an alias is defined twice in `.zshrc` (where the later definition silently wins).

### Setting up fish

Fish is opt-in. `install.sh` does not touch it and it is deliberately absent from the `Brewfile`.

1. **Install fish.**

   ```bash
   brew install fish            # macOS
   sudo apt-get install fish    # Debian/Ubuntu/WSL
   ```

2. **Symlink the config.** `.config/fish/` is picked up by the existing target — no fish-specific step:

   ```bash
   make config
   ```

3. **Optionally make it your login shell.** zsh remains the shell this repo is built around, so this is a deliberate choice, not part of setup:

   ```bash
   echo "$(command -v fish)" | sudo tee -a /etc/shells
   chsh -s "$(command -v fish)"
   ```

That is the whole setup — everything else fish needs is either already in the repo or shared with zsh:

- **No plugin-manager step.** The `fisher` plugins listed in `.config/fish/fishfile` (`plugin-asdf`, `plugin-peco`, `plugin-balias`, `fish-nvm`) are vendored under `.config/fish/functions/` and `.config/fish/conf.d/`, so they arrive with the symlink.
- **No extra packages.** `peco` and `fzf` come from the `Brewfile`. Fish uses its own default prompt rather than a separate prompt tool.
- **asdf, rustup and opam are optional.** `config.fish` picks up asdf from the `~/.asdf` clone `install.sh` creates — the same install `.zshrc` uses — and each of the three is guarded, so fish starts cleanly whether or not they are present.

## Scripts

`.scripts/` is symlinked into `$HOME` by `make` and added to `PATH` by `.zshrc`.

| Script | Description |
| --- | --- |
| `pmux` | Pick a ghq-managed repo via fzf (with README preview) and open/attach a tmux session for it. Bound to `F1` in tmux. |
| `tmux-window-fzf` | Fuzzy-select a tmux window across all sessions (with pane preview) and switch to it. Bound to `F4` and `prefix + w` in tmux. |
| `tmux-cheatsheet` | Show the prefix-less keybinds in a popup, generated from `tmux list-keys`. Bound to `F6` in tmux. |
| `tmux-send-all` | Send a command to tmux panes in the current session, targeting (`-t`) or excluding (`-i`) specific panes. |
| `tmux-cleanup-windows.sh` | Close all tmux windows except the active one and windows 0–2. |
| `tmux-pane-name` | Rename the current tmux window to the current git branch (or a given name). |
| `tmux-pane-highlight` | Set a colored border + status emoji on the current pane/window; used to signal Claude Code state from hooks. `off` clears it. |
| `tssh` | List Tailscale hosts and ssh into the selected one (fzf picker, `tailscale ssh` for Linux targets, plain ssh otherwise). See `tssh -h`. |
| `switch-worktree` | Pick a git worktree via fzf and cd into it. Sourced via the `Ctrl+B` keybind in zsh. |
| `git-worktree-pull` | Fix the fetch refspec of a bare/worktree clone so `git fetch origin` gets all remote branches. Aliased as `gwp`. |
| `killport` | Kill the processes listening on a given port (`killport 8080`). |
| `duck` / `google` | Search DuckDuckGo / Google from the terminal via lynx. |
| `urlencode` | URL-encode arguments or stdin; used by `duck` and `google`. |

## Environment Variables

To configure your secrets API key securely, create a credentials file outside version control:

```bash
mkdir -p ~/.config/secrets
cat << 'EOF' > ~/.config/secrets/credentials.sh
export OPENAI_API_KEY="sk-…"
export ANTHROPIC_API_KEY=sk_...
EOF
chmod 600 ~/.config/secrets/credentials.sh
```

This file is ignored by git via `.config/secrets/.gitignore`, so your key stays private, and your shell configs (`.bashrc`, `.zshrc`) will automatically load it.

A template listing the expected variables is committed at `.config/secrets/credentials.sh.example` — copy it to `credentials.sh` and fill in the values. CI runs [gitleaks](https://github.com/gitleaks/gitleaks) to catch secrets accidentally committed to the repo.
