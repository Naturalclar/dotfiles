# git alias
alias g="git"
alias gaa="git add --all"
alias gbr="git branch"
alias gbranch="git branch"
alias gcm="git commit -m"
alias gcb="git switch -c"
alias gco="git checkout"
# get default branch using git remote. its slower than using symbolic-ref, but symbolic-ref does not work with git worktree
alias get_default_branch="git remote show origin | grep 'HEAD branch' | awk '{print \$3}'"
alias gcod='git switch $(get_default_branch)'
alias gcom="git switch master"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gdiff="git diff"
alias gdm="git branch --merged|egrep -v '\*|develop|master|release'|xargs git branch -d" # delete merged branches
alias gl="git log"
alias gll="git log --pretty=oneline" # display git logs in a single line
alias glog="git log"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"
alias gpcb='git push origin $(git_current_branch)'
alias gpcbf='git push origin $(git_current_branch) --force-with-lease'
alias gpo="git push origin"
alias gpom="git push origin -u master"
alias gpull="git pull"
alias gpl="git pull"
alias gplcb='git pull origin $(git_current_branch)'
alias gpsub="git submodule update --init --recursive" #clones submodules
alias gptag="git push origin --tags"
alias gpum="git pull upstream master"
alias gr="gcod && gpull"
alias grh="git restore --worktree"
alias grb="git rebase"
alias gsc="git switch -c"
alias gsd="git switch develop"
alias gsm="git switch master"
alias gst="git status"
alias gsu="git stash -u"
alias gw="git worktree"
# origin head (default branch) を最新の状態にする
alias gitsync="git remote set-head origin --auto"
alias bl="git branch"
alias branch="git branch"
alias pull="git pull"
alias get_default_branch_fast="git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"

alias up="git stash -u && git rebase main && git stash pop"

# move to top level of repository
autoload -Uz rr
rr() { cd $(git rev-parse --show-toplevel); }
# Git Worktree

autoload -Uz worktree_list
worktree_list() { git worktree list | sed '1d' | awk '{print $1}' | xargs -n 1 basename; } 

# Function to switch to the branch that matches the current worktree name
worktree_switch_branch() {
  # Get the repository root
  local worktree_path=$(git rev-parse --show-toplevel 2>/dev/null)
  
  if [[ -z "$worktree_path" ]]; then
    echo "Not in a git repository"
    return 1
  fi
  
  # Get the worktree name (which should match the branch name in your setup)
  local worktree_name=$(basename "$worktree_path")
  
  # Switch to the branch matching the worktree name
  git switch "$worktree_name" 2>/dev/null || echo "No branch named $worktree_name exists"
}
alias wsb=worktree_switch_branch

bindkey -s '^B' ". switch-worktree\n"

