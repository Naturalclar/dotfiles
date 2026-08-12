# Package.json script selector with fzf
run-script() {
  # Check if package.json exists
  if [[ ! -f package.json ]]; then
    echo "No package.json found in current directory"
    return 1
  fi

  # Create temporary file for script data
  local tmp_file=$(mktemp)

  # Extract scripts to temporary file with format "script_name:::actual_command"
  # Using ::: as delimiter to avoid conflicts with script names containing colons
  jq -r '.scripts | to_entries | .[] | .key + ":::" + .value' package.json > $tmp_file

  # Select script using fzf with preview of the command
  local selected=$(cat $tmp_file | fzf --layout=reverse --prompt="Run script: " \
    --preview 'echo -e "Command:\n\n$(echo {} | cut -d: -f3-)"')

  # Clean up temporary file
  rm $tmp_file

  # Exit if nothing was selected
  if [[ -z "$selected" ]]; then
    return 0
  fi

  # Extract script name - split on the first occurrence of :::
  local script_name=$(echo $selected | sed 's/:::.*//')

  # Determine which package manager to use
  local cmd="npm run"
  if [[ -f "yarn.lock" ]]; then
    cmd="yarn"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    cmd="pnpm"
  elif [[ -f "bun.lockb" ]]; then
    cmd="bun run"
  fi

  # Run the selected script
  echo "Running: $cmd $script_name"
  $cmd $script_name
}

# Alias for run-script
alias rs="run-script"

# Keyboard shortcut for run-script (Ctrl+N)
bindkey -s '^N' "run-script\n"

if [ -x "$HOME/.local/bin/claude" ]; then
    alias claude="$HOME/.local/bin/claude"
fi

# Claude Code update alias
alias claude-code-update="cd ~/.local/bin && npm update @anthropic-ai/claude-code"
