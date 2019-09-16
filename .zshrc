# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"

# Path to python
export PATH="$HOME/Library/Python/2.7/bin:$PATH"

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

# git alias
alias g="git"
alias gaa="git add --all"
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias gco="git checkout"
alias gcod="git checkout develop"
alias gcom="git checkout master"
alias gd="git diff"
alias gdiff="git diff"
alias gdm="git branch --merged|egrep -v '\*|develop|master|release'|xargs git branch -d" # delete merged branches
alias gl="git log"
alias glog="git log"
alias gpo="git push origin"
alias gpcb='git push origin $(git_current_branch)'
alias gpom="git push origin -u master"
alias gpsub="git submodule update --init --recursive" #clones submodules
alias gptag="git push origin --tags"
alias gst="git status"
alias gsu="git stash -u"
alias pull="git pull"
alias gpull="git pull"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"
# display git logs in a single line
alias gll="git log --pretty=oneline"

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

# hub
alias hb="hub browse"

# rimraf
alias rimraf="rm -rf"

# cd to ghq directories
alias ws='cd $(ghq list --full-path | peco)'

# Delete selected branch on git
alias gbd='git branch -d $(git branch | peco)'

# alias to run android emulator
alias rundroid='$HOME/Library/Android/sdk/emulator/emulator -avd Nexus_5X_API_28_x86'

# alias to copy file or folder to dotfiles repository
alias cpdf='cp -r $(ls -a | peco) $DOTFILES'