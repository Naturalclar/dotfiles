#  if zsh exists, use zsh
if [ -f "/usr/local/bin/zsh" ]; then
  exec "/usr/local/bin/zsh"
fi
if [ -f "/usr/bin/zsh" ]; then
  exec "/usr/bin/zsh"
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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

complete -C /opt/homebrew/bin/terraform terraform
. "$HOME/.cargo/env"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Change prompt
# \e[0;32m changes color. 0 represents weight, 32 represents color
# \u indicates username
# \s indicates shell name
# \w indicates current directory
export PS1="\e[0;32m╭─[\s] \w\n╰─\e[1;32m\$ \e[0m"

# git alias
alias get_default_branch="git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"

# git aliases
alias g="git"
alias gaa="git add --all"
alias gbr="git branch"
alias gcm="git commit -m"
alias gcb="git switch -c"
alias gco="git checkout"
alias gcod='git switch $(get_default_branch)'
alias gcom="git switch master"
alias gd="git diff"
alias gdiff="git diff"
alias gdm="git branch --merged|egrep -v '\*|develop|master|release'|xargs git branch -d" # delete merged branches
alias gl="git log"
alias gll="git log --pretty=oneline" # display git logs in a single line
alias glog="git log"
alias gpcb='git push origin $(git_current_branch)'
alias gpo="git push origin"
alias gpom="git push origin -u master"
alias gpull="git pull"
alias gpsub="git submodule update --init --recursive" #clones submodules
alias gptag="git push origin --tags"
alias gpum="git pull upstream master"
alias grh="git restore --worktree"
alias gsc="git switch -c"
alias gsd="git switch develop"
alias gsm="git switch master"
alias gst="git status"
alias gsu="git stash -u"
# origin head (default branch) を最新の状態にする
alias gitsync="git remote set-head origin --auto"

# alias for gh cli
alias ghview="gh repo view --web"

# alias for ghq
alias ws='cd $(ghq list --full-path | peco)'

# setup for each os
case "${OS}" in
Linux*)
  # asdf config
  . "$HOME/.asdf/asdf.sh"
  export ASDF_DIR="$HOME/.asdf"
  export PATH=/snap/bin:$PATH
  export PATH="$HOME/.asdf/shims:$PATH"
  ;;
Windows*)
  # direnv config
  eval "$(direnv hook bash)"
  ;;
esac
