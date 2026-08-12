# NOTE: .zshrc is the source of truth for these. See README.md -- when an alias
# exists in both shells it must behave identically here.

alias get_default_branch="git remote show origin | grep 'HEAD branch' | awk '{print \$3}'"
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
alias up="git stash -u && git rebase main && git stash pop"

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
alias type-check="yarn type-check"
alias ybuild="yarn build"
alias ystart="yarn start"
alias ylint="yarn lint"
alias bootstrap="yarn bootstrap"
alias ybt="yarn bootstrap"
alias yarnstrap="yarn bootstrap"
alias yad="yarn add -D"
alias ya="yarn add"
alias yag="yarn global add"

# pnpm
alias add="pnpm add"
alias addd="pnpm add -D"
alias addg="pnpm global add"
alias lint="pnpm lint"
alias tc="pnpm type-check"
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

# cd to ghq directories. zsh's ws is peco-workspace, which uses plain peco --
# not pf, which turns on the fuzzy filter.
function ws
  cd (ghq list --full-path | peco)
end

# NOTE: these mirror the bindkey lines in .zsh/, which are the source of truth.
# Several of them take over a fish default (Ctrl+A beginning-of-line, Ctrl+F
# accept-autosuggestion, Ctrl+W backward-kill-word, Ctrl+N history-next); that
# is deliberate, since the point is for the two shells to feel the same.
function fish_user_key_bindings
  # history search -- Ctrl+Z as well, which is where zsh had it first
  bind \cr 'peco_select_history (commandline -b)'
  bind \cz 'peco_select_history (commandline -b)'

  bind \cw ws              # ghq repo via peco
  bind \ca wf              # ghq repo via fzf, with README preview
  bind \cf pmux            # ghq repo -> tmux session
  bind \cb switch-worktree # git worktree
  bind \cn run-script      # package.json script

  bind \c] ws
end

#open code and github
alias ch="hub browse && code ."

# alias to run android emulator
set -gx EMULATOR "$HOME/Library/Android/sdk/emulator/emulator"
alias listdroid='$EMULATOR -list-avds'

# open selected android emulator
function rundroid
  $EMULATOR -avd (listdroid | peco)
end

# alias to copy file or folder to dotfiles repository
# alias cpdf="cp -r "(ls -a | pf)" $DOTFILES"

# alias for run-script (bound to Ctrl+N, see fish_user_key_bindings)
alias rs="run-script"

# alias for npm scripts
# list npm scripts and output chosen script
function n
  yarn (cat package.json | jq .scripts |  sed '1d' | sed '$d' | pf | sed 's/: ".*".//g' | sed 's/"//g' | sed 's/[ ]//g');
end

alias ..='cd ../'
alias ....='cd ../..'
alias ......='cd ../../..'

# alias for docker
alias drun="docker run"
alias dps="docker ps"
alias dkill="docker kill"

# alias for ripgrep
alias rgi="rg --no-ignore"

# alias for exit
alias .exit="exit"
alias .quit="exit"
alias quit="exit"

