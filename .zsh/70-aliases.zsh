autoload -Uz galias
galias() { alias | grep 'git' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

autoload -Uz zle-refresh
refresh() {
  source ~/.zshrc
}
zle-refresh() {
  refresh
  zle reset-prompt
}
zle -N zle-refresh
# alias
alias zshedit="vim ~/.zshrc"
# Ctrl+R is history search, matching fish and every other shell; reload the
# config with the `zshr` alias instead.
alias zshr=refresh

# lynx
alias lynx="lynx -vikeys"

# scripts
alias scripts="cd ~/.scripts"
alias '?'="duck"
alias '??'="google"
alias gwp="git-worktree-pull"

# vim
if command -v nvim &> /dev/null; then
  alias vim="nvim"
  alias vi="nvim"
fi
alias ivm="vim"
alias vmi="vim"
alias v="vim"

# lazygit
alias lg="lazygit"

#alias for peco
alias pf="peco --initial-filter=Fuzzy"

# ls
alias lsa="ls -a"

# homebrew
alias brew_old="/usr/local/bin/brew"

