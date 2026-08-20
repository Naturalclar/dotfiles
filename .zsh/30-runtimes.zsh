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



# Path to dotfiles repository.
#
# Derived from this file rather than spelled out: the literal it replaced began
# /Users/<name>/.ghq/..., so it was wrong on Linux and WSL, wrong for a clone
# kept anywhere other than under ghq, and wrong for a worktree.
#
# %N is the file being sourced, :A resolves it through the ~/.zshrc symlink,
# and the two :h take .zsh/30-runtimes.zsh up to the repository root.
export DOTFILES="${${(%):-%N}:A:h:h}"

