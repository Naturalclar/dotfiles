#  if zsh exists, use zsh
if [ -f "/usr/local/bin/zsh"]
  exec "/usr/local/bin/zsh"
fi

# Path to ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#alias
alias g="git"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gaa="git add --all"
alias gcm="git commit -m"
alias gsu="git stash -u"

# display git logs in a single line
alias gll="git log --pretty=oneline"

# cd to ghq directories
alias ws='cd $(ghq list --full-path | peco)'

# Delete selected branch on git
alias gbd='git branch -d $(git branch | peco)'
