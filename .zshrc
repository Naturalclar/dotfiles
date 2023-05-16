# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# zmodload zsh/zprof
zmodload zsh/datetime
start_time=$(strftime '%s%.')


# Path to arm64 homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Init direnv
eval "$(direnv hook zsh)"

# Path to ruby
eval "$(rbenv init - zsh)"

# Path to deno
export PATH="$HOME/.deno/bin:$PATH"

# Path to python
export PATH="$HOME/Library/Python/2.7/bin:$PATH"

# Path to rust 
export PATH="$HOME/.cargo/bin:$PATH"

# Path to Poetry
export PATH="$HOME/.local/bin:$PATH"

# Path to asdf
export ASDF_DIR="/opt/homebrew/Cellar/asdf/0.11.2/libexec"
[ -s "$ASDF_DIR/asdf.sh" ] && \. "$ASDF_DIR/asdf.sh"
[ -s "$ASDF_DIR/etc/bash_completion.d/asdf.bash" ] && \. "$ASDF_DIR/etc/bash_completion.d/asdf.bash"

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

# vim
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

#alias for peco
alias pf="peco --initial-filter=Fuzzy"

# ls
alias lsa="ls -a"

# homebrew
alias brew_old="/usr/local/bin/brew"

# git alias
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

alias bl="git branch"
alias branch="git branch"
alias pull="git pull"
alias up="git pull upstream master"
alias get_default_branch="git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"
alias git_current_branch="git branch | grep \* | cut -d ' ' -f2"


galias() { alias | grep 'git'; }

# Ruby

## bundler

alias be="bundle exec"

# JavaScript

## yarn
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
alias yw="yarn watch"
alias ytest="yarn test"
alias yyb="yarn && yarn bootstrap"
yalias() { alias | grep 'yarn'; }

## pnpm
alias p="pnpm"
alias pb="pnpm build"
alias ph="pnpm start"
alias add="pnpm add"
alias addd="pnpm add -D"
alias addg="pnpm global add"


# github cli
alias getpr="gh pr checkout"
alias repo="gh repo create --public"
alias ghview="gh repo view -w"
alias makepr="gh pr create"
alias fork="gh repo fork"

# npx
alias monow="npx monow"
alias mwb="npx monow -b build"
alias upset="npx git-upstream --set"

# ghq
alias get="ghq get"

# rimraf
alias rimraf="rm -rf"

# cd to ghq directories
alias ws='cd $(ghq list --full-path | pf)'

#open code and github
alias ch="hub browse && code ."

# check if code-insider is available, and open code-insider instead of code if it exists
if command -v code-insiders >/dev/null 2>&1; then
    alias code="code-insiders"
fi

# Delete selected branch on git
alias gbd='git branch -d $(git branch | pf)'

# terraform
alias tf="terraform"

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

# alias for npm
alias nr="npm run"

alias ..='cd ../'
alias ~='cd $HOME/'
alias mcd='cd packages/$(ls packages | peco)'

# alias for docker
alias drun="docker run"
alias dps="docker ps"
alias dkill="docker kill"
alias dce="docker compose exec"

# alias for ripgrep
alias rgi="rg --no-ignore"

# alias for clear
alias cl="clear"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/completion.zsh.inc"; fi

# clasp
alias cl="clasp"

# opam configuration
test -r "$HOME/.opam/opam-init/init.zsh" && . "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null || true

# peco history selection
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

# asdf config
fpath=(
  $(brew --prefix asdf)/etc/bash_completion.d
  $fpath
)
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# fzf settings
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat  --color=always --style=header,grid --line-range :100 {}"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
export PATH="/usr/local/opt/bison@2.7/bin:$PATH"

# if type zprof >/dev/null 2>&1; then
#     zprof | less
# fi

end_time=$(strftime '%s%.')
echo $((end_time - start_time))

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export JAVA_HOME=$(/usr/libexec/java_home -v 11.0)
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

