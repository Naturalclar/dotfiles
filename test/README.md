# Test Directory

This directory contains test cases for various functions and scripts in the dotfiles repository.

## Running them

Every suite is [bats-core](https://github.com/bats-core/bats-core), which comes
from the `Brewfile` — `make brew` installs it along with the other tools CI
uses. Then run one:

```bash
bats test/scripts.bats
```

or all of them:

```bash
bats test/*.bats
```

CI runs every suite on every push: the bats job in `lint.yml` globs
`test/*.bats`, so a new suite is picked up with no workflow change. It still
needs a section here — `docs.bats` fails if one is missing.

## Contents

### scripts.bats

Tests for the non-interactive behaviors of the tools in `.scripts/` (`urlencode`, `killport`, help/usage flags, and the outside-tmux guards). These run in CI on every push.

### fish-config.bats

Tests for the parts of `.config/fish/` that mirror `.zsh/`: `.scripts` being on `PATH`, and the UTF-8 locale forcing that keeps multibyte output readable over SSH clients like Termius. Both fail silently when missing — the shell still starts, the scripts just are not there and text breaks — so each is asserted directly, with a stub `locale` used to vary which locales are available. A final test checks that fish and zsh pick the *same* locale from the same input. Needs `fish`; these run in CI on every push.

### prompt.bats

Tests for `_prompt_path` in `.zsh/40-prompt.zsh`, which replaces the working directory in the prompt with `<repo>[/<worktree>]` plus the path from the repository root. Each test covers one of the things the logic is easy to get wrong: `--git-common-dir` coming back relative from a subdirectory, detecting a linked worktree by `<root>/.git` being a file, and doubling `%` so a directory name cannot corrupt the prompt. The function is pulled out of the module on its own, so the rest of the config does not have to be loadable. Needs `zsh`; these run in CI on every push.

### aliases.bats

Tests that keep `.zsh/*.zsh`, `.config/fish/` and `windows/*.ps1` from drifting apart. They enforce the rule documented in the root `README.md`: zsh is the source of truth, and an alias defined in **both** shells must expand to the same thing. Fish is not required to carry every zsh alias — only to agree on the ones it does carry. A second check catches an alias defined twice across the `.zsh/*.zsh` modules, where the later definition silently wins. These run in CI on every push.

### makefile.bats

Tests for the symlink targets in the `Makefile` (`dotfiles`, `config`, `claude`, `unlink`, `list`, `help`). Each test points `HOME` at a throwaway directory, so a fresh machine is reproduced without touching the real one, and asserts on the symlinks that were actually produced — `ln -sfn` can fail in ways that still leave `make` green. These run in CI on both macOS and Linux.

### startup.bats

Tests for what a new shell prints. A leftover profiling probe printed a bare millisecond count on every start, which corrupts anything reading that stdout, so the rule is asserted directly: a plain startup emits no number, no timing line and no profile table, while `ZSH_STARTUP_TIME=1` and `ZSH_PROFILE=1` each produce theirs. A last test keeps both markers in `.zshrc` rather than in a module — an end marker parked in one module stops covering whatever is added after it, which is how the old one came to miss three modules. Later tests cover `$DOTFILES` resolving to this repository through the `~/.zshrc` symlink, and a machine without asdf starting without a load error. Needs `zsh`; these run in CI on every push.

### ssh-agent.bats

Tests for the ssh-agent handling in `.zsh/10-os.zsh`. It used to run `eval "$(ssh-agent)"` on every start, so each shell got its own agent: stray processes for every terminal ever opened, and a key added in one window missing from the next. Three properties are pinned — start an agent when none is reachable, reuse it afterwards, and never displace one that is already reachable (which is what SSH agent forwarding looks like) — plus replacing a socket left by a dead agent, and staying quiet where `ssh-agent` is not installed. `ssh-agent` and `ssh-add` are stubbed: real ones would leave agents behind on the machine running the tests, and the stale-socket case needs an agent that can be made to stop answering. These run in CI on every push.

### docs.bats

Tests that keep the documentation attached to the repository. `AGENTS.md` promised to mirror `CLAUDE.md`, then sat unchanged through the `.zshrc` split and ended up describing a file that no longer worked that way, so it is now a pointer rather than a copy — and these tests keep it one. The rest cover what rots in practice: a suite added without a section here, without a workflow step, or without a mention in `CLAUDE.md`, and a path named in the docs that no longer exists. These run in CI on every push.

### test-package-scripts

A test package to demonstrate the basic `run-script` function from `.zsh/81-run-script.zsh`. This test shows how to use the function to list and run npm scripts using fzf.

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

A test package to demonstrate the `run-script` function with scripts that have colons in their names. This tests the functionality in `.zsh/81-run-script.zsh` that allows selecting and running npm scripts using fzf, with proper handling of script names containing colons.

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
