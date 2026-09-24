. "$HOME/.cargo/env"

# Secrets: .zshrc (80-late.zsh) だけだと対話シェルにしか入らないので、ここでも読む。
# 非対話シェル（Claude Code の Bash、SAI から起動されるセッション）で JEV_API_KEY 等が
# 無くなっていたのがこれ。二重に source されても export が上書きされるだけで害は無い。
if [ -f "$HOME/.config/secrets/credentials.sh" ]; then
  . "$HOME/.config/secrets/credentials.sh"
fi
