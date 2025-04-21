# dotfile for Naturalclar

[![Main workflow][mainworkflowbadge]][githubactions]

Easily set dotfiles using `Makefile`

![makefile](https://user-images.githubusercontent.com/6936373/63206028-6458d600-c0e8-11e9-8f6f-64ad969c5280.png)

[mainworkflowbadge]: https://github.com/Naturalclar/dotfiles/workflows/Main%20workflow/badge.svg
[githubactions]: https://github.com/Naturalclar/dotfiles/actions

## Mac or Linux

Run `make` to automatically set all dotfiles to `$HOME`

```
make
```

## Windows

Run `bootstrap.ps1` to setup configuration for PowerShell

```
./bootstrap.ps1
```

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
