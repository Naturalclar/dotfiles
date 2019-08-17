#  if zsh exists, use zsh
if [ -f "/usr/local/bin/zsh" ]; then
  exec "/usr/local/bin/zsh"
fi

# Path to ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#alias
alias g="git"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gaa="git add --all"
alias gcm="git commit -m"
alias gsu="git stash -u"
alias gpo="git push origin"
alias pull="git pull"

# display git logs in a single line
alias gll="git log --pretty=oneline"

# cd to ghq directories
alias ws='cd $(ghq list --full-path | peco)'

# Delete selected branch on git
alias gbd='git branch -d $(git branch | peco)'
