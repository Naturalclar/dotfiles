# opam configuration
test -r "$HOME/.opam/opam-init/init.zsh" && . "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null || true

# peco commands

# chose files to add with git add
alias gap="git ls-files -m | peco | xargs git add"

# search files with given keyword and open with vim
vg() {
    rg -l "$1" | peco | xargs -o vim
}

# peco history selection (using tac for cross-platform compatibility between macOS and WSL)
peco-history-selection() {
    BUFFER=`history -n 1 | tac | awk '!a[$0]++' | peco`
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

