# Change prompt
# \e[0;32m changes color. 0 represents weight, 32 represents color
# \u indicates username
# \s indicates shell name
export PS1="\e[0;32m╭─[\s]\w\n╰─\e[1;32m\$ \e[0m"

# nvim as vim
alias v=nvim
alias vim=nvim
# git alias
alias get_default_branch="git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"

alias g="git"
alias gaa="git add --all"
alias gbr="git branch"
alias gbranch="git branch"
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

# alias for ghq
alias ws='cd $(ghq list --full-path | peco)'

case "${OS}" in
Linux*)
  # asdf config
  . "$HOME/.asdf/asdf.sh"
  ;;
esac
. "$HOME/.cargo/env"

# Load Secrets API key from credentials file if present
if [ -f "$HOME/.config/secrets/credentials.sh" ]; then
  source "$HOME/.config/secrets/credentials.sh"
fi
