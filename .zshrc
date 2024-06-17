# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# set vim motion
set -o vi

# Uncomment the following line to profile zsh
# zmodload zsh/zprof
zmodload zsh/datetime
start_time=$(strftime '%s%.')

OS=`uname`

# Set option depending on OS
case "${OS}" in
    Darwin*)
        # ASDF config - expected to be cloned from git
        export ASDF_DIR="$HOME/.asdf"
        # initialize asdf
        . "$HOME/.asdf/asdf.sh"
        # Add Brew Path
        export PATH="/opt/homebrew/bin:$PATH"
        export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
    ;;
    Linux*)
        # ASDF config - expected to be cloned from git
        export ASDF_DIR="$HOME/.asdf"
        . "$HOME/.asdf/asdf.sh"
        # Allow using ssh-add command
        eval "$(ssh-agent)"
        # Check if required commands are installed
      if ! command -v asdf &> /dev/null; then
        echo "asdf is not installed"
        echo "git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1"
        echo "For additional guides, check: https://asdf-vm.com/guide/getting-started.html"
      fi
      if ! command -v node &> /dev/null; then
        echo "node is not installed"
        echo "asdf plugin add nodejs"
        echo "asdf install nodejs latest"
        echo "For additional guides, check: https://github.com/asdf-vm/asdf-nodejs"
      fi
      if ! command -v ghq &> /dev/null; then
        echo "ghq is not installed"
        echo "asdf plugin add ghq"
        echo "asdf install ghq latest"
        echo "For additional guides, check: https://github.com/x-motemen/ghq"
      fi
      if ! command -v peco &> /dev/null; then
        echo "peco is not installed"
        echo "sudo apt install peco"
        echo "For additional guides, check: https://github.com/peco/peco"
      fi
      export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
      export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
      export PATH=/snap/bin:$PATH
      # end set JAVA_HOME
      # TODO: only do this if linuxbrew exists
      # eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac


# Init direnv if it exists
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Init rbenv if it exists
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

# Init phpenv if it exists
if command -v phpenv &> /dev/null; then
  eval "$(phpenv init -)"
fi

# Path to deno
export PATH="$HOME/.deno/bin:$PATH"

# Path to python
export PATH="$HOME/Library/Python/2.7/bin:$PATH"

# Path to rust 
export PATH="$HOME/.cargo/bin:$PATH"

# Path to Poetry
export PATH="$HOME/.local/bin:$PATH"

# Path to scripts
export PATH="$HOME/.scripts:$PATH"

# imports
autoload -Uz vcs_info



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

# Set default editor for gh cli to vim
export GIT_EDITOR=vim

# zsh-autosuggestions
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

autoload -Uz galias
galias() { alias | grep 'git' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

autoload -Uz refresh
refresh() {
  source ~/.zshrc
  zle reset-prompt
}
zle -N refresh
# alias
alias zshedit="vim ~/.zshrc"
bindkey '^R' refresh
alias zshr=refresh

# lynx
alias lynx="lynx -vikeys"

# scripts
alias scripts="cd ~/.scripts"
alias '?'="duck"
alias '??'="google"

# vim
if command -v nvim &> /dev/null; then
  alias vim="nvim"
  alias vi="nvim"
fi
alias ivm="vim"
alias vmi="vim"

# lazygit
alias lg="lazygit"

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
alias up="git pull upstream master"
alias get_default_branch="git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"


# move to top level of repository
autoload -Uz rr
rr() { cd $(git rev-parse --show-toplevel); }
# Git Worktree

autoload -Uz worktree_list
worktree_list() { git worktree list | sed '1d' | awk '{print $1}' | xargs -n 1 basename; } 

bindkey -s '^B' ". switch-worktree\n"

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
alias pi="pnpm install"
alias add="pnpm add"
alias addd="pnpm add -D"
alias addg="pnpm global add"
alias lint="pnpm lint"
alias format="pnpm format"
alias tc="pnpm type-check"
alias type-check="yarn type-check"
alias ptc="pnpm type:check"

# github cli
alias getpr="gh pr checkout"
alias repo="gh repo create --public"
alias ghview="gh repo view -w"
alias makepr="gh pr create"
alias fork="gh repo fork"
alias gpc="gh pr create"

# npx
alias upset="npx git-upstream --set"

# ghq
alias get="ghq get"
## TODO: get used to working with github workspace to fully migrate to bare repo clones
alias getb="ghq get --bare"

# rimraf
alias rimraf="rm -rf"

# cd to ghq directories
peco-workspace() {
  cd $(ghq list --full-path | peco)
  zle reset-prompt
}
zle -N peco-workspace
alias ws=peco-workspace
bindkey '^W' peco-workspace

bindkey -s '^F' "pmux\n"

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

# alias for npm scripts
# list npm scripts and output chosen script
list() { cat package.json | jq .scripts |  sed '1d' | sed '$d' | pf | sed 's/: ".*".//g' | sed 's/"//g'; }
alias n='yarn $(list)'
alias psls="cat package.json | jq .scripts | sed '1d' | sed '$d'"
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

# peco commands

# chose files to add with git add
alias gap="git ls-files -m | peco | xargs git add"

# chose files to open with vim
alias v="git ls-files | peco | xargs -o vim"

# search files with given keyword and open with vim
vg() {
    rg -l "$1" | peco | xargs -o vim
}

# peco history selection
peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^Z' peco-history-selection

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
export PATH="/usr/local/opt/bison@2.7/bin:$PATH"

end_time=$(strftime '%s%.')
echo $((end_time - start_time))

# keep awake
alias awakeon="sudo pmset -a disablesleep 1"
alias awakeoff="sudo pmset -a disablesleep 0"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# set JAVA_HOME on every change directory
asdf_update_java_home() {
  asdf current java 2>&1 > /dev/null
  if [[ "$?" -eq 0 ]]
  then
      export JAVA_HOME=$(asdf where java)
  fi
}

precmd() { 
  asdf_update_java_home; 
  vcs_info;
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Uncomment the following line to profile zsh
# zprof
