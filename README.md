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

Run `bootstrap.ps1` to point the PowerShell profile at this repository:

```
./bootstrap.ps1
```

It writes a `$PROFILE` that sources `windows/*.ps1` from the clone, in filename
order — the same idea as the symlinks `make` creates on Unix. A `git pull` takes
effect on the next shell, so this only needs running once per machine. Edit
`windows/*.ps1` here rather than `$PROFILE`, which is overwritten.

Any profile you already had is copied to `$PROFILE.bak` first. Re-running is
safe: it will not overwrite that backup with the generated loader.

### Everything else on Windows

`bootstrap.ps1` only sets up the shell. The rest is separate scripts, each
creating one symlink:

| Script | Links |
| --- | --- |
| `setup-nvim.ps1` | `.config/nvim` → `%USERPROFILE%\AppData\Local\nvim` |
| `setup-wezterm.ps1` | `.wezterm.lua` → `%USERPROFILE%` |
| `setup-komorebi.ps1` | `.config/komorebi/*.json` → `%USERPROFILE%\.config` |
| `setup-whkdrc.ps1` | `.config/whkdrc` → `%USERPROFILE%\.config` |
| `setup-yasb.ps1` | `.yasb` → `%USERPROFILE%` |

**Creating symlinks on Windows needs either an elevated shell or Developer Mode**
(Settings → Privacy & security → For developers). Without one of those,
`New-Item -ItemType SymbolicLink` fails with a permissions error.

These are not idempotent yet and assume `%USERPROFILE%\.config` already exists —
see #280.

The window-manager side is [komorebi](https://github.com/LGUG2Z/komorebi) with
[whkd](https://github.com/LGUG2Z/whkd) for hotkeys and
[yasb](https://github.com/amnweb/yasb) for the status bar;
`powershell/komorebi-start.ps1` and `komorebi-stop.ps1` (plus `.bat` wrappers)
drive it. `ahk/` holds AutoHotKey scripts for remapping Windows to Ctrl,
switching input language, and a few shortcuts — there is no setup script for
those, so place them in the startup folder yourself.

There is no `Brewfile` equivalent: the tools above, plus whatever
`windows/path.ps1` expects (scoop, direnv, poetry), have to be installed by
hand.

CI runs on Linux and macOS only. The PowerShell scripts are parsed and linted
with PSScriptAnalyzer on every push, but nothing exercises them on Windows —
changes there are worth trying on a real machine.

## Shells

**zsh is the source of truth.** It is the shell this repo is built around: it is what `install.sh` sets up, what CI lints (`zsh -n` per module plus a full `source`), and where every alias, function and keybinding lands first.

`.zshrc` itself is only a loader — the configuration lives in `.zsh/*.zsh`, sourced in filename order. The numeric prefix *is* the load order and it matters (options and PATH before what uses them, syntax highlighting after the aliases it highlights), so add new settings to the module that fits rather than to `.zshrc`.

`.config/fish/` is **experimental** and maintained on a best-effort basis. It carries a subset of the zsh aliases and none of the more involved functions (`run-script`, `peco-workspace`, `fzf-workspace`, …). Fish is not installed by `install.sh` and is not in the `Brewfile`.

If you touch aliases:

- Add or change them in the matching `.zsh/*.zsh` module first.
- Porting to fish is optional — but **a name that exists in both shells must behave identically**. A name that means one thing in zsh and another in fish is worse than not having it in fish at all.

`test/aliases.bats` enforces that in CI. It compares aliases textually, and — because a name can be an alias in one shell and a function in the other, where there is nothing to compare across two different syntaxes — it also requires any such pair to be listed in `KNOWN_EQUIVALENT` with a note saying it was checked by hand. A new mismatched pair therefore cannot appear unnoticed. It also fails if an alias is defined twice across the modules (where the later definition silently wins).

Both shells use vi key bindings (`set -o vi` in zsh, `fish_key_bindings` in fish) and export `EDITOR=vim` and `GIT_EDITOR=vim`.

Keybindings are mirrored too: `Ctrl+R`/`Ctrl+Z` history search, `Ctrl+W`/`Ctrl+A` ghq repo pickers, `Ctrl+F` tmux session, `Ctrl+B` git worktree, `Ctrl+N` package.json script. Several of them take over a fish default (`Ctrl+A` beginning-of-line, `Ctrl+F` accept-autosuggestion, `Ctrl+W` backward-kill-word), which is deliberate — the point is for the two shells to feel the same.

The prompt is the one place where fish deliberately carries a copy of zsh logic: `.config/fish/functions/__prompt_path.fish` mirrors `_prompt_path` in `.zsh/40-prompt.zsh`, and `__prompt_git_state.fish` mirrors the `vcs_info` zstyles. `test/prompt.bats` runs both implementations over the same repository layouts and fails if they disagree.

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

`.scripts/` is symlinked into `$HOME` by `make` and added to `PATH` by `.zsh/30-runtimes.zsh`.

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
