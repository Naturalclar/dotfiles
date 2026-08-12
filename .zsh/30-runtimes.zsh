# Init direnv if it exists
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Init rbenv if it exists
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

# Init phpenv if it exists
if command -v phpenv &> /dev/null; then
  eval "$(phpenv init -)"
fi

# Path to deno
export PATH="$HOME/.deno/bin:$PATH"

# Path to python
export PATH="$HOME/Library/Python/2.7/bin:$PATH"

# Path to rust 
export PATH="$HOME/.cargo/bin:$PATH"

# Path to Poetry
export PATH="$HOME/.local/bin:$PATH"

# Path to scripts
export PATH="$HOME/.scripts:$PATH"

# imports
autoload -Uz vcs_info



# Path to dotfiles repository
export DOTFILES="/Users/`whoami`/.ghq/github.com/Naturalclar/dotfiles"

