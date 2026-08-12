# Test Directory

This directory contains test cases for various functions and scripts in the dotfiles repository.

## Contents

### scripts.bats

Automated [bats-core](https://github.com/bats-core/bats-core) tests for the non-interactive behaviors of the tools in `.scripts/` (`urlencode`, `killport`, help/usage flags, and the outside-tmux guards). These run in CI on every push; locally:

```bash
brew install bats-core
bats test/scripts.bats
```

### aliases.bats

Automated [bats-core](https://github.com/bats-core/bats-core) tests that keep `.zshrc` and `.config/fish/` from drifting apart. They enforce the rule documented in the root `README.md`: `.zshrc` is the source of truth, and an alias defined in **both** shells must expand to the same thing. Fish is not required to carry every zsh alias — only to agree on the ones it does carry. A second check catches an alias defined twice in `.zshrc`, where the later definition silently wins. These run in CI on every push; locally:

```bash
brew install bats-core
bats test/aliases.bats
```

### makefile.bats

Automated [bats-core](https://github.com/bats-core/bats-core) tests for the symlink targets in the `Makefile` (`dotfiles`, `config`, `claude`, `unlink`, `list`, `help`). Each test points `HOME` at a throwaway directory, so a fresh machine is reproduced without touching the real one, and asserts on the symlinks that were actually produced — `ln -sfn` can fail in ways that still leave `make` green. These run in CI on both macOS and Linux; locally:

```bash
brew install bats-core
bats test/makefile.bats
```

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
