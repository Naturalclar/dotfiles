# Test Directory

This directory contains test cases for various functions and scripts in the dotfiles repository.

## Contents

### test-package-scripts

A test package to demonstrate the basic `run-script` function added to your .zshrc file. This test shows how to use the function to list and run npm scripts using fzf.

To use this test:

1. Source your .zshrc file to load the function:

   ```bash
   source ~/.zshrc
   ```

2. Navigate to the test directory:

   ```bash
   cd test/test-package-scripts
   ```

3. Run the `run-script` function using one of the methods described in the README.md file in that directory.

### test-colon-scripts

A test package to demonstrate the `run-script` function with scripts that have colons in their names. This tests the functionality added to the .zshrc file that allows selecting and running npm scripts using fzf, with proper handling of script names containing colons.

To use this test:

1. Source your .zshrc file to load the updated function:

   ```bash
   source ~/.zshrc
   ```

2. Navigate to the test directory:

   ```bash
   cd test/test-colon-scripts
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

4. Select a script with a colon in its name (like `build:dev`) to verify it works correctly.

For more details, see the README.md file in the test-colon-scripts directory.
