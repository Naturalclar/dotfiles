# PATHS

# Android Studio: ANDROID_HOME and the PATH entries built from it live in
# .zsh/10-os.zsh, where the OS decides the layout.

# NVM PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# jEnv. The old JENV_ROOT was /usr/local/opt/jenv -- Intel Homebrew's prefix,
# so on Apple Silicon the -d guard was simply never true and jenv never
# initialised. Ask where it is instead of guessing.
if command -v jenv >/dev/null 2>&1; then
  export JENV_ROOT="${JENV_ROOT:-${${:-$(command -v jenv)}:A:h:h}}"
  eval "$(jenv init -)"
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Default editor. GIT_EDITOR is what gh and git use; EDITOR is the fallback
# everything else (crontab, visudo, ...) reads.
export EDITOR=vim
export GIT_EDITOR=vim

