# Package.json Script Selector with FZF

This document outlines a plan to create a command that will:

1. Get the list of scripts from package.json in the current directory
2. List them using fzf (fuzzy finder)
3. Run the selected command

## Implementation Plan

### 1. Create a new function called `run-script` or `rs`

This function will:

1. Check if package.json exists in the current directory
2. Use jq to extract script names and commands from package.json
3. Display them using fzf with a preview window showing the actual command
4. Detect which package manager to use (npm, yarn, or pnpm) based on lock files or preference
5. Execute the selected script with the appropriate package manager

### 2. Function Structure

```bash
run-script() {
  # Check if package.json exists
  if [[ ! -f package.json ]]; then
    echo "No package.json found in current directory"
    return 1
  fi

  # Create temporary file for script data
  local tmp_file=$(mktemp)

  # Extract scripts to temporary file with format "script_name:actual_command"
  jq -r '.scripts | to_entries | .[] | .key + ":" + .value' package.json > $tmp_file

  # Select script using fzf with preview of the command
  local selected=$(cat $tmp_file | fzf --layout=reverse --prompt="Run script: " \
    --preview 'echo -e "Command:\n\n$(echo {} | cut -d: -f2-)"')

  # Clean up temporary file
  rm $tmp_file

  # Exit if nothing was selected
  if [[ -z "$selected" ]]; then
    return 0
  fi

  # Extract script name
  local script_name=$(echo $selected | cut -d: -f1)

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
```

### 3. Add an alias for quick access

```bash
alias rs="run-script"
```

### 4. Optional: Add keyboard shortcut

Similar to other shortcuts in the .zshrc file, we could add a keyboard binding:

```bash
bindkey -s '^N' "run-script\n"  # Ctrl+N to run scripts
```

## Enhancements

1. **Package Manager Detection**: The function will automatically detect whether to use npm, yarn, pnpm, or bun based on lock files.

2. **Preview Window**: Using fzf's preview feature to show the actual command that will be executed.

3. **Error Handling**: Checks for the existence of package.json and handles cases where no script is selected.

4. **Formatting**: Clean display of script names with their corresponding commands.

## Implementation Steps

1. Add the `run-script` function to the .zshrc file
2. Add the alias and optional keyboard shortcut
3. Source the .zshrc file or restart the terminal
4. Test the function in a directory with a package.json file

## Requirements

- jq: For parsing JSON
- fzf: For interactive selection
- A package manager (npm, yarn, pnpm, or bun)
