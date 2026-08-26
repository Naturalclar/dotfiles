# keep awake
alias awakeon="sudo pmset -a disablesleep 1"
alias awakeoff="sudo pmset -a disablesleep 0"

# pnpm: PNPM_HOME is set per-OS in .zsh/10-os.zsh (~/Library/pnpm on macOS).

# jq
## list scripts in package.json or tasks in deno.json
show_scripts() {
  if [[ -f package.json ]]; then
    echo "📦 npm scripts:"
    jq '.scripts' package.json
  elif [[ -f deno.json ]]; then
    echo "🦕 deno tasks:"
    jq '.tasks' deno.json
  elif [[ -f deno.jsonc ]]; then
    echo "🦕 deno tasks:"
    jq '.tasks' deno.jsonc
  else
    echo "❌ No package.json or deno.json found in current directory"
    return 1
  fi
}

# alias for backward compatibility
alias ns="show_scripts"

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
  _prompt_path;
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

