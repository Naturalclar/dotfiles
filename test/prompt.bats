#!/usr/bin/env bats

# Tests for _prompt_path in .zshrc, which decides what the prompt shows in
# place of the working directory. The logic has three easy things to get wrong,
# so each one has a case here:
#   - `git rev-parse --git-common-dir` returns a *relative* path from a
#     subdirectory, so it has to be made absolute before the repo name is taken
#   - a linked worktree is identified by <root>/.git being a file, not a
#     directory; comparing --git-dir against --git-common-dir gives a false
#     positive in any subdirectory
#   - text substituted into the prompt is re-scanned for % escapes, so a `%` in
#     a directory name corrupts the prompt unless it is doubled
#
# Run locally with `bats test/prompt.bats` (needs zsh and bats-core).

ZSHRC="$BATS_TEST_DIRNAME/../.zshrc"

setup() {
  command -v zsh >/dev/null || skip "zsh not available"
  WORK="$(mktemp -d)"
  git init -q "$WORK/myrepo"
  git -C "$WORK/myrepo" config user.email t@example.com
  git -C "$WORK/myrepo" config user.name test
  mkdir -p "$WORK/myrepo/src/components"
  git -C "$WORK/myrepo" add -A
  git -C "$WORK/myrepo" commit -qm init --allow-empty
}

teardown() {
  [ -n "${WORK:-}" ] && rm -rf "$WORK"
}

# Run the real _prompt_path from .zshrc inside $1 and print what the prompt
# would contain. Only the function is pulled out, so the rest of .zshrc (asdf,
# plugins, PATH setup) does not have to be loadable here.
prompt_path_in() {
  (
    cd "$1" || return 1
    zsh -c "
      $(sed -n '/^_prompt_path() {/,/^}$/p' "$ZSHRC")
      _prompt_path
      print -r -- \$_prompt_path_msg
    "
  )
}

@test "outside a git repository the full path is shown" {
  run prompt_path_in "$WORK"
  [ "$status" -eq 0 ]
  [ "$output" = "$WORK" ]
}

@test "at a repository root only the repository name is shown" {
  run prompt_path_in "$WORK/myrepo"
  [ "$status" -eq 0 ]
  [ "$output" = "myrepo" ]
}

@test "in a subdirectory the path is relative to the repository root" {
  run prompt_path_in "$WORK/myrepo/src/components"
  [ "$status" -eq 0 ]
  [ "$output" = "myrepo/src/components" ]
}

@test "a linked worktree shows repository and worktree name" {
  git -C "$WORK/myrepo" worktree add -q "$WORK/wt" -b feature
  run prompt_path_in "$WORK/wt"
  [ "$status" -eq 0 ]
  [ "$output" = "myrepo/wt" ]
}

@test "a subdirectory of a linked worktree keeps the repository name" {
  git -C "$WORK/myrepo" worktree add -q "$WORK/wt" -b feature
  mkdir -p "$WORK/wt/src"
  run prompt_path_in "$WORK/wt/src"
  [ "$status" -eq 0 ]
  [ "$output" = "myrepo/wt/src" ]
}

@test "the bare-clone worktree layout resolves the repository name" {
  # <proj>/.bare plus <proj>/main, which is what git-worktree-pull and pmux
  # expect. The repository name has to come from the common dir, not from the
  # parent of the current worktree.
  mkdir -p "$WORK/proj"
  git clone -q --bare "$WORK/myrepo" "$WORK/proj/.bare"
  echo "gitdir: ./.bare" >"$WORK/proj/.git"
  git -C "$WORK/proj" worktree add -q main 2>/dev/null || skip "worktree add unsupported here"

  run prompt_path_in "$WORK/proj/main"
  [ "$status" -eq 0 ]
  [ "$output" = "proj/main" ]
}

@test "a bare clone named <repo>.git resolves the repository name" {
  # The other bare convention: the bare repo *is* foo.git, with worktrees
  # beside it. Here the common dir is the repository, so its parent is not the
  # repository name -- the .git suffix has to be stripped instead.
  git clone -q --bare "$WORK/myrepo" "$WORK/foo.git"
  git -C "$WORK/foo.git" worktree add -q "$WORK/foo-wt" 2>/dev/null || skip "worktree add unsupported here"

  run prompt_path_in "$WORK/foo-wt"
  [ "$status" -eq 0 ]
  [ "$output" = "foo/foo-wt" ]
}

@test "inside a bare repository the full path is shown" {
  git clone -q --bare "$WORK/myrepo" "$WORK/foo.git"
  # There is no working tree here, so there is no root to be relative to.
  run prompt_path_in "$WORK/foo.git"
  [ "$status" -eq 0 ]
  [ "$output" = "$WORK/foo.git" ]
}

@test "a percent sign in a directory name is escaped for the prompt" {
  mkdir -p "$WORK/myrepo/we%20ird"
  run prompt_path_in "$WORK/myrepo/we%20ird"
  [ "$status" -eq 0 ]
  # Doubled in the raw value so that prompt expansion renders a single %.
  [ "$output" = "myrepo/we%%20ird" ]
  rendered="$(zsh -c "setopt prompt_subst; p='$output'; print -rn -- \${(%%)p}")"
  [ "$rendered" = "myrepo/we%20ird" ]
}
