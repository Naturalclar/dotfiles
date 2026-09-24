. "$HOME/.cargo/env"

# Secrets are also loaded from .zsh/80-late.zsh, but that path runs only for
# interactive shells. Load them here so non-interactive shells get them too.
if [ -f "$HOME/.config/secrets/credentials.sh" ]; then
  . "$HOME/.config/secrets/credentials.sh"
fi
