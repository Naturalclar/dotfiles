alias get_default_branch="git remote show origin | grep 'HEAD branch' | cut -d ':' -f2 | sed 's/[ ]//g'"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"

#alias for peco
alias pf="peco --initial-filter=Fuzzy"

# ls
alias lsa="ls -a"

# git alias
alias g="git"
alias gaa="git add --all"
alias gbr="git branch"
alias gbranch="git branch"
alias gcm="git commit -m"
alias gcb="git switch -c"
alias gco="git checkout"
alias gcom="git switch master"
alias gd="git diff"
alias gdiff="git diff"
alias gdm="git branch --merged|egrep -v '\*|develop|master|release'|xargs git branch -d" # delete merged branches
alias gl="git log"
alias gll="git log --pretty=oneline" # display git logs in a single line
alias glog="git log"
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

alias bl="git branch"
alias branch="git branch"
alias pull="git pull"
alias up="git pull upstream master"

# git functions

# switch to default branch
function gcod
  git switch (get_default_branch)
end

# push current branch
function gpcb
  git push origin (git_current_branch)
end

# Delete selected branch on git
function gbd
  git branch -d (git branch | pf)
end

# yarn
alias y="yarn"
alias yb="yarn build"
alias ys="yarn start"
alias yl="yarn lint"
alias ytc="yarn type-check"
alias build="yarn build"
alias start="yarn start"
alias lint="yarn lint"
alias type-check="yarn type-check"
alias tc="yarn type-check"
alias ybuild="yarn build"
alias ystart="yarn start"
alias ylint="yarn lint"
alias bootstrap="yarn bootstrap"
alias ybt="yarn bootstrap"
alias yarnstrap="yarn bootstrap"
alias yad="yarn add -D"
alias ya="yarn add"
alias add="yarn add"
alias addd="yarn add -D"
alias yag="yarn global add"
alias addg="yarn global add"
alias yw="yarn watch"
alias ytest="yarn test"
alias yyb="yarn && yarn bootstrap"

# npx
alias monow="npx monow"
alias mwb="npx monow -b build"
alias upset="npx git-upstream --set"

# hub
alias hb="hub browse"

# ghq
alias get="ghq get"

# rimraf
alias rimraf="rm -rf"

# cd to ghq directories
function ws
  set repo (ghq list --full-path | pf)
  cd $repo  
end

function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \c] ws
end

#open code and github
alias ch="hub browse && code ."

# alias to run android emulator
alias emulaor="$HOME/Library/Android/sdk/emulator/emulator"
alias listdroid='emulator -list-avds'

# open selected android emulator
function rundroid
  emulator -avd (listdroid | peco)
end

# alias to copy file or folder to dotfiles repository
# alias cpdf="cp -r "(ls -a | pf)" $DOTFILES"

# alias for npm scripts
# list npm scripts and output chosen script
function n
  yarn (cat package.json | jq .scripts |  sed '1d' | sed '$d' | pf | sed 's/: ".*".//g' | sed 's/"//g' | sed 's/[ ]//g');
end

alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'

# alias for docker
alias drun="docker run"
alias dps="docker ps"
alias dkill="docker kill"

# alias for ripgrep
alias rgi="rg --no-ignore"

# alias for clear
alias cl="clear"

# alias for exit
alias .exit="exit"
alias .quit="exit"
alias quit="exit"

