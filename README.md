# dotfile for Naturalclar

```
███╗   ██╗ █████╗ ████████╗██╗   ██╗██████╗  █████╗ ██╗      ██████╗██╗      █████╗ ██████╗
████╗  ██║██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██║     ██╔════╝██║     ██╔══██╗██╔══██╗
██╔██╗ ██║███████║   ██║   ██║   ██║██████╔╝███████║██║     ██║     ██║     ███████║██████╔╝
██║╚██╗██║██╔══██║   ██║   ██║   ██║██╔══██╗██╔══██║██║     ██║     ██║     ██╔══██║██╔══██╗
██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║  ██║██║  ██║███████╗╚██████╗███████╗██║  ██║██║  ██║
╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
```

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

More on what `install.ps1` runs, and the tools around it, in
[docs/windows-setup.md](docs/windows-setup.md).

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

## What is in here

| Path | What it is |
| --- | --- |
| `.zshrc`, `.zsh/*.zsh` | The shell config. `.zshrc` is a loader; the numbered modules are the config itself |
| `.config/` | Everything that belongs under `~/.config` — nvim, fish, kitty, komorebi, … |
| `.scripts/` | Small CLI tools added to `PATH` |
| `.claude/skills/` | Claude Code skills, linked into `~/.claude/skills` by `make claude` |
| `windows/`, `powershell/`, `ahk/` | The Windows side: profile parts, symlink helpers, AutoHotKey |
| `test/` | bats-core suites, all of them run in CI |
| `docs/` | The longer explanations linked below |

## Docs

- [Shells](docs/shells.md) — zsh as the source of truth, the fish and PowerShell
  ports, keybindings, and how to set fish up
- [Scripts](docs/scripts.md) — what each tool in `.scripts/` does
- [Claude Code](docs/claude-code.md) — the skills in this repo and how they are installed
- [Clipboard over SSH](docs/clipboard-over-ssh.md) — yanking into the client's clipboard via OSC 52
- [Windows setup](docs/windows-setup.md) — what `install.ps1` runs, komorebi, the manage rules
- [Neovim](docs/nvim.md), [vim notes](docs/note.md), [Windows memo](docs/windows.md)

Working on this repository: [CLAUDE.md](CLAUDE.md) has the architecture and the
conventions, and [test/README.md](test/README.md) describes each test suite.
