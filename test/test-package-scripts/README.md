# Test Package Scripts

This is a test package to demonstrate the basic `run-script` function added to your .zshrc file.

## How to Use

1. Source your .zshrc file to load the function:

   ```bash
   source ~/.zshrc
   ```

2. Navigate to this directory:

   ```bash
   cd test/test-package-scripts
   ```

3. Run the `run-script` function:

   ```bash
   run-script
   ```

   Or use the alias:

   ```bash
   rs
   ```

   Or use the keyboard shortcut: `Ctrl+N`

4. You'll see a list of available scripts from package.json with a preview of what each script does.

5. Select a script using the arrow keys and press Enter to run it.

## Features

- Automatically detects the package manager (npm, yarn, pnpm, or bun) based on lock files
- Shows a preview of the actual command that will be executed
- Provides a fuzzy search interface with fzf
- Handles errors gracefully (e.g., if no package.json exists)

## Requirements

- jq: For parsing JSON
- fzf: For interactive selection
- A package manager (npm, yarn, pnpm, or bun)
