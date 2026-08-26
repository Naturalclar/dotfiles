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

`install.sh` (also available as `make bootstrap`) is idempotent and safe to re-run. It installs Homebrew and the Brewfile packages (macOS), initializes the zsh-plugin submodules, symlinks all dotfiles, `.config` entries and the Claude Code settings and skills, installs asdf plus the runtimes in `.tool-versions`, and applies the macOS key-repeat settings.

For just the symlinks:

```
make            # symlink dotfiles into $HOME
make config     # symlink .config entries
make claude     # symlink Claude Code settings and skills into ~/.claude
```

## Windows

One command on a new machine:

```
git clone https://github.com/Naturalclar/dotfiles.git; cd dotfiles; .\install.ps1
```

`install.ps1` is the counterpart of `install.sh`: it points the PowerShell
profile at the clone, links the configs, and applies the machine settings. It is
idempotent, so re-running is safe.

**Creating symlinks on Windows needs either an elevated shell or Developer Mode**
(Settings → Privacy & security → For developers). Without one of those the link
steps warn and carry on, rather than stopping the run.

### What it runs

| Script | Does |
| --- | --- |
| `bootstrap.ps1` | Writes a `$PROFILE` that sources `windows/*.ps1` from the clone |
| `setup-nvim.ps1` | Links `.config/nvim` → `%LOCALAPPDATA%\nvim` |
| `setup-wezterm.ps1` | Links `.wezterm.lua` → `%USERPROFILE%` |
| `setup-komorebi.ps1` | Links `.config/komorebi/*.json` → `%USERPROFILE%\.config` |
| `setup-whkdrc.ps1` | Links `.config/whkdrc` → `%USERPROFILE%\.config` |
| `setup-yasb.ps1` | Links `.yasb` → `%USERPROFILE%` |
| `setup-defaults.ps1` | Key repeat and the persistent `PROMPT` variable |

Each runs standalone too. Linking follows the same rule as `make` on Unix: a
link we made before is replaced, and anything else already at the destination is
left alone with a warning.

`setup-ahk.ps1` links `ahk/*.ahk` into the Startup folder so they run at login —
remapping Windows to Ctrl, switching input language, and a few shortcuts.
`install.ps1` does **not** call it, since whether those should start
automatically is a choice rather than part of setting the machine up.

The profile is a loader, not a copy: a `git pull` takes effect on the next
shell. Edit `windows/*.ps1` here rather than `$PROFILE`, which is overwritten.
Any profile you already had is copied to `$PROFILE.bak` first, once.

### Other pieces

The window manager is [komorebi](https://github.com/LGUG2Z/komorebi) with
[whkd](https://github.com/LGUG2Z/whkd) for hotkeys and
[yasb](https://github.com/amnweb/yasb) for the status bar;
`powershell/komorebi-start.ps1` and `komorebi-stop.ps1` (plus `.bat` wrappers)
drive it.

`manage_rules` in `.config/komorebi/.komorebi.json` force-manages windows
komorebi would otherwise leave floating. Scope those rules as tightly as the
application allows: a bare `Exe` rule matches *every* window of that process,
so an app whose plugin or dialog windows are separate top-level windows would
get all of them tiled too. A nested array is a composite rule — every entry in
it has to match — which is how the UAD Console entry keeps to the main window.
Note that `manage_rules` wins over `ignore_rules`, so a too-broad force-manage
rule cannot be walked back with an ignore rule; narrow the rule itself.

`ignore_rules` is for the other direction: windows komorebi *would* tile on its
own but shouldn't. The UAD entry is the negative of its manage rule — every
window of that process whose title is not the Console's — so the plugin editor
windows stay floating however they are titled. A window already on screen when
the config is reloaded keeps its current state; reopen it to re-evaluate.

`komorebic visible-windows` prints the exe, title and class of what is on
screen, which is where the ids in those rules come from. Matching is exact for
`Equals`, so a wrong id is a silent no-op. Changes need
`komorebic reload-configuration`.

There is no `Brewfile` equivalent: those tools, plus whatever
`windows/path.ps1` expects (scoop, direnv, poetry), have to be installed by
hand.

CI runs on Linux and macOS only. The PowerShell scripts are parsed and linted
with PSScriptAnalyzer on every push, but nothing exercises them on Windows —
changes there are worth trying on a real machine.

## Shells

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

## Clipboard over SSH

`y` in vim/nvim on an SSH target can only reach the client's clipboard through
the terminal, via the OSC 52 escape sequence. When `$SSH_TTY`/`$SSH_CONNECTION`
is set:

- **Neovim** (`.config/nvim/lua/config/options.lua`) forces the OSC 52
  clipboard provider. The built-in auto-detection is *not* enough: it only kicks
  in when no `pbcopy`/`xclip`/`wl-copy` exists on the server and it is inhibited
  by tmux (`:h clipboard-osc52`), so a Mac target would silently copy to its own
  clipboard. Paste (`"+p`, `P`) returns the last yank instead of asking the
  terminal, because most terminals refuse clipboard reads and nvim would wait
  up to 10 s.
- **Vim** (`.vim/vimrc`) writes OSC 52 on `TextYankPost` with a few lines of
  vimscript; no plugin needed.
- **tmux** (`.tmux.conf`) has `set-clipboard on` and `allow-passthrough on` so
  the sequence is relayed to the outer terminal instead of swallowed.
- Locally (no SSH variables) nothing changes.

Terminals: WezTerm, kitty, Ghostty, Windows Terminal and Alacritty accept
OSC 52 writes by default. **iTerm2 does not** — enable
*Settings → General → Selection → "Applications in terminal may access
clipboard"* (GUI only, not in dotfiles).

To check the path without an editor, run this on the server and paste on the
client (inside tmux, `tmux show-buffer` shows whether tmux relayed it):

```sh
printf '\033]52;c;%s\a' "$(printf hello | base64)"
```

Note that a tmux server started locally and attached later over SSH does not
have the SSH variables in already-open shells; open a new window or
`tmux set-environment`.

Payload limit: tmux does not truncate (checked with 500 lines / 20 KB), but some
terminals cap a single OSC 52 at 100 000 bytes of base64 (~74 KB of text, the
xterm default). A yank above that is dropped silently. Workaround for anything
bigger: write it to a file and `scp`, or yank in chunks.

## Claude Code

Skills live in `.claude/skills/`, the location Claude Code reads project skills
from, so they are available to anyone working in this repository — and to a
cloud session, which clones the repository and never sees `~/.claude` on any
machine.

`make claude` is what carries them to the rest of your work: it links
`configs/claude/settings.json` to `~/.claude/settings.json` and every directory
under `.claude/skills/` into `~/.claude/skills/`, so the skills apply in other
repositories too. The skills are linked one at a time rather than as a whole
directory, so skills installed from anywhere else stay where they are. A skill
directory that already exists in `~/.claude/skills` as a real directory is
reported and skipped rather than overwritten.

Most of `.claude/` is Claude Code's own per-machine state, so `.gitignore`
ignores its contents and re-includes only `skills/`. That takes two lines —
`/.claude/*` then `!/.claude/skills/` — because git does not descend into an
excluded directory, which makes a negation under `/.claude/` silently do
nothing.

A third route, independent of this repository: uploading a skill to your
claude.ai account syncs it into `~/.claude/skills/synced/` for Cowork and cloud
sessions everywhere. Manage those from **Customize** in the desktop app sidebar
or the skills settings on claude.ai.

| Skill | Description |
| --- | --- |
| `tailscale-serve` | Expose a dev server on the machine you are SSH'd into to the rest of the tailnet with `tailscale serve`, so a browser on the machine you are sitting at can reach it. Pairs with `tssh`. |
| `repo-survey` | Read a repository for defects that can be reproduced, and file them as one-PR-sized GitHub issues. Repo-agnostic. |

A skill is a `SKILL.md` with YAML frontmatter; the `name` has to match its
directory and the `description` is what Claude Code matches against to decide
when to load it. `test/makefile.bats` checks both.

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
