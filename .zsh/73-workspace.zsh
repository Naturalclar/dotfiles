# cd to ghq directories
peco-workspace() {
  cd $(ghq list --full-path | peco)
}
zle-peco-workspace(){
  peco-workspace
  zle reset-prompt
}
zle -N zle-peco-workspace
alias ws=peco-workspace
bindkey '^W' zle-peco-workspace

# cd to ghq directories via fzf
fzf-workspace() {
  cd $(ghq list --full-path | fzf --layout=reverse --preview "REPO={}; README=\$(find \"\$REPO\" -maxdepth 1 -name 'README*' -type f | head -n 1); if [ -z \"\$README\" ]; then README=\$(find \"\$REPO/main\" \"\$REPO/master\" \"\$REPO/develop\" \"\$REPO/dev\" -maxdepth 1 -name 'README*' -type f 2>/dev/null | head -n 1); fi; if [ -n \"\$README\" ]; then bat --color=always --style=header,grid --line-range :80 \"\$README\"; else echo 'No README found'; fi")
}
zle-fzf-workspace(){
  fzf-workspace
  zle reset-prompt
}
zle -N zle-fzf-workspace
alias wf=fzf-workspace
bindkey '^A' zle-fzf-workspace

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

# tmux
alias tsa="tmux-send-all"
alias pn="tmux-pane-name"
alias td="tmux detach"

