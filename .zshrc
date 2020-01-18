# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
export GEM_HOME="$HOME/Software/ruby"
export PATH="$PATH:$HOME/Software/ruby/bin"

# Path to deno
export PATH="$HOME/.deno/bin:$PATH"

# Path to python
export PATH="$HOME/Library/Python/2.7/bin:$PATH"

# Path to rust 
export PATH="$HOME/.cargo/bin:$PATH"

# imports
autoload -Uz vcs_info

## displayed at prompt
precmd () { vcs_info }

# Path to dotfiles repository
export DOTFILES="/Users/`whoami`/.ghq/github.com/Naturalclar/dotfiles"

## prompt
### vcs_info 表示内容をカスタマイズ
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

setopt prompt_subst

PROMPT="%F{green}╭─ %~ %f"'${vcs_info_msg_0_}'"
%F{green}╰─%B$%b %f"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

# PATHS

# Android Studio
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator

# NVM PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# jEnv
export JENV_ROOT="/usr/local/opt/jenv"
if [ -d "${JENV_ROOT}" ]; then
  export PATH="$JENV_ROOT/bin:$PATH"
  eval "$(jenv init -)"
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# zsh-syntax-highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

galias() { alias | grep 'git' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# alias
alias zshconfig="code ~/.zshrc"
alias sz="source ~/.zshrc"

#alias for peco
alias pf="peco --initial-filter=Fuzzy"

# ls
alias lsa="ls -a"

# git alias
alias g="git"
alias gaa="git add --all"
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

alias pull="git pull"
alias up="git pull upstream master"
alias get_default_branch='git remote show origin | grep "HEAD branch" | cut -d ":" -f 2'
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"


galias() { alias | grep 'git'; }

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
yalias() { alias | grep 'yarn'; }

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
alias ws='cd $(ghq list --full-path | pf)'

#open code and github
alias ch="hub browse && code ."

# Delete selected branch on git
alias gbd='git branch -d $(git branch | pf)'

# alias to run android emulator
export EMULATOR="$HOME/Library/Android/sdk/emulator/emulator"
alias listdroid='$EMULATOR -list-avds'
alias rundroid='$EMULATOR -avd "$(listdroid | peco)"'
# alias to copy file or folder to dotfiles repository
alias cpdf='cp -r $(ls -a | pf) $DOTFILES'

# alias for frequently used folder
HERB_MOBILE=$HOME/.ghq/github.com/CureApp/herb/modules/herb-mobile-rx-ja
HERB_CONSOLE=$HOME/.ghq/github.com/CureApp/herb/modules/herb-console
HERB_COMPONENTS=$HOME/.ghq/github.com/CureApp/herb/modules/herb-components
alias herbmo='cd $HERB_MOBILE'
alias herbco='cd $HERB_CONSOLE'
alias herbcom='cd $HERB_COMPONENTS'

# alias for npm scripts
# list npm scripts and output chosen script
list() { cat package.json | jq .scripts |  sed '1d' | sed '$d' | pf | sed 's/: ".*".//g' | sed 's/"//g'; }
alias n='yarn $(list)'

alias ..='cd ../'
alias ~='cd $HOME/'
alias mcd='cd packages/$(ls packages | peco)'

# alias for docker
alias drun="docker run"
alias dps="docker ps"
alias dkill="docker kill"

# alias for ripgrep
alias rgi="rg --no-ignore"

# alias for clear
alias cl="clear"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/completion.zsh.inc"; fi


# fnm
eval "$(fnm env --multi)"

# opam configuration
test -r "$HOME/.opam/opam-init/init.zsh" && . "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null || true
