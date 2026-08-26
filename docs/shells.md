# Shells

# Shells

**zsh is the source of truth.** It is the shell this repo is built around: it is what `install.sh` sets up, what CI lints (`zsh -n` per module plus a full `source`), and where every alias, function and keybinding lands first.

`.zshrc` itself is only a loader — the configuration lives in `.zsh/*.zsh`, sourced in filename order. The numeric prefix *is* the load order and it matters (options and PATH before what uses them, syntax highlighting after the aliases it highlights), so add new settings to the module that fits rather than to `.zshrc`.

When startup feels slow, the loader can time and profile itself. Both are off by default — a shell that prints on every start corrupts anything reading its output:

```bash
ZSH_STARTUP_TIME=1 zsh -i -c exit   # zsh startup: 123ms
ZSH_PROFILE=1 zsh -i -c exit        # zprof table: where that time went
```

`.config/fish/` is **experimental** and maintained on a best-effort basis. It carries a subset of the zsh aliases and none of the more involved functions (`run-script`, `peco-workspace`, `fzf-workspace`, …). Fish is not installed by `install.sh` and is not in the `Brewfile`.

If you touch aliases:

- Add or change them in the matching `.zsh/*.zsh` module first.
- Porting to fish is optional — but **a name that exists in both shells must behave identically**. A name that means one thing in zsh and another in fish is worse than not having it in fish at all.

PowerShell (`windows/alias.ps1`, `windows/functions.ps1`) follows the same rule
for the definitions that can be compared at all: one-liners, plus multi-line
functions whose body is a single command — which most of them are. Its prompt mirrors the zsh one too.
Anything genuinely platform-specific (`open` is `explorer.exe` under WSL and
`Invoke-Item` in PowerShell) is recorded as a known difference rather than
forced to match.

`test/aliases.bats` enforces that in CI. It compares aliases textually, and — because a name can be an alias in one shell and a function in the other, where there is nothing to compare across two different syntaxes — it also requires any such pair to be listed in `KNOWN_EQUIVALENT` with a note saying it was checked by hand. A new mismatched pair therefore cannot appear unnoticed. It also fails if an alias is defined twice across the modules (where the later definition silently wins), and it rejects two PowerShell mistakes that cannot work: a `Set-Alias` carrying arguments (`Set-Alias pb "pnpm build"` aliases a command *named* `pnpm build`, which does not exist) and a `Set-Alias` whose value contains `$( )`, which runs once at profile load rather than when the command is used.

All three shells use vi key bindings (`set -o vi` in zsh, `fish_key_bindings` in fish, `Set-PSReadLineOption -EditMode Vi` in PowerShell) and export `EDITOR=vim` and `GIT_EDITOR=vim`.

Keybindings are mirrored too:

| Key | Does | zsh | fish | PowerShell |
| --- | --- | --- | --- | --- |
| `Ctrl+R` / `Ctrl+Z` | history search | ✓ | ✓ | ✓ |
| `Ctrl+W` | ghq repo (peco) | ✓ | ✓ | ✓ |
| `Ctrl+A` | ghq repo (fzf) | ✓ | ✓ | ✓ |
| `Ctrl+B` | git worktree | ✓ | ✓ | ✓ |
| `Ctrl+N` | package.json script | ✓ | ✓ | ✓ |
| `Ctrl+F` | tmux session (`pmux`) | ✓ | ✓ | ✓ (repo, no tmux) |

`Ctrl+F` opens a tmux session for the picked repository on Unix. There is no tmux on Windows, so it switches to the repository instead — the same thing `Ctrl+W` does. The habit survives even though the destination is a shell rather than a session. `Ctrl+A` on Windows picks without the README preview, since fzf runs its preview through cmd and the Unix version leans on `find` and `bat`.

Several of these take over a default (`Ctrl+A` beginning-of-line, `Ctrl+F` accept-autosuggestion in fish, `Ctrl+W` backward-kill-word), which is deliberate — the point is for the shells to feel the same. In fish and PowerShell they are bound in both vi modes, so they work whether or not you are in insert mode.

The prompt is the one place where fish deliberately carries a copy of zsh logic: `.config/fish/functions/__prompt_path.fish` mirrors `_prompt_path` in `.zsh/40-prompt.zsh`, and `__prompt_git_state.fish` mirrors the `vcs_info` zstyles. `test/prompt.bats` runs both implementations over the same repository layouts and fails if they disagree.

## Setting up fish

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

[Back to the README](../README.md).
