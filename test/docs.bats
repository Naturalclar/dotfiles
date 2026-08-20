#!/usr/bin/env bats

# Tests that keep the documentation from drifting away from the repository.
#
# AGENTS.md promised to mirror CLAUDE.md and then sat unchanged through the
# .zshrc split, so it described a file that no longer existed in that form and
# sent Windows setup through the wrong script (#305). Two files that promise to
# mirror each other drift the moment one is edited alone, so AGENTS.md now
# points at CLAUDE.md instead of copying it, and that is asserted here.
#
# The other checks are about what actually goes stale in practice: a path that
# was renamed, and a test suite that was added without being documented or run.
#
# Run locally with `bats test/docs.bats` (brew install bats-core).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

# --- AGENTS.md is a pointer, not a copy --------------------------------------

@test "AGENTS.md sends the reader to CLAUDE.md" {
  grep -q 'CLAUDE.md' "$REPO/AGENTS.md"
}

@test "AGENTS.md carries no second copy of the guidance" {
  # A pointer is a few lines. Anything approaching CLAUDE.md's size means the
  # content came back, and with it the drift.
  local agents claude
  agents=$(wc -l <"$REPO/AGENTS.md")
  claude=$(wc -l <"$REPO/CLAUDE.md")

  [ "$agents" -lt 30 ]
  [ "$agents" -lt "$claude" ]
}

@test "AGENTS.md does not restate CLAUDE.md's sections" {
  # The old copy had its own Commands / CI / Architecture / Code Style
  # headings. Those are the ones that went out of date.
  ! grep -qE '^## (Commands|CI|Architecture|Code Style|Environment Variables)' "$REPO/AGENTS.md"
}

# --- every suite is documented and run ---------------------------------------

@test "every bats suite has a section in test/README.md" {
  local missing=""
  for suite in "$REPO"/test/*.bats; do
    grep -q "^### $(basename "$suite")\$" "$REPO/test/README.md" || missing+=" $(basename "$suite")"
  done
  [ -z "$missing" ] || {
    echo "undocumented suites:$missing"
    false
  }
}

@test "every bats suite is run by CI" {
  # Adding a suite and forgetting the workflow step leaves it passing locally
  # and never running anywhere else.
  local missing=""
  for suite in "$REPO"/test/*.bats; do
    grep -qr "bats test/$(basename "$suite")" "$REPO/.github/workflows" || missing+=" $(basename "$suite")"
  done
  [ -z "$missing" ] || {
    echo "suites no workflow runs:$missing"
    false
  }
}

@test "CLAUDE.md lists every bats suite" {
  local missing=""
  for suite in "$REPO"/test/*.bats; do
    grep -q "$(basename "$suite")" "$REPO/CLAUDE.md" || missing+=" $(basename "$suite")"
  done
  [ -z "$missing" ] || {
    echo "suites missing from CLAUDE.md:$missing"
    false
  }
}

# --- the paths the docs name still exist -------------------------------------

@test "repository paths named in the docs exist" {
  # Catches the rename half of doc rot: `.zshrc` splitting into `.zsh/`,
  # `windows/keyboard.ps1` moving to `setup-defaults.ps1`, and so on. Only
  # backticked tokens that look like paths into this repository are checked --
  # not $HOME paths, globs or shell snippets.
  local missing=""
  local doc token
  for doc in README.md CLAUDE.md AGENTS.md test/README.md docs/*.md; do
    while IFS= read -r token; do
      case "$token" in
        *'*'* | *'~'* | *'$'* | *' '*) continue ;;
        # A bare extension in prose ("plus `.bat` wrappers"), not a path. Real
        # dotfiles like `.zshrc` exist, so they pass on their own merits.
        .[a-z0-9] | .[a-z0-9][a-z0-9] | .[a-z0-9][a-z0-9][a-z0-9] | .[a-z0-9][a-z0-9][a-z0-9][a-z0-9]) continue ;;
      esac
      [ -e "$REPO/$token" ] || missing+=" $doc:$token"
    done < <(grep -oE '`[.a-zA-Z0-9_/-]+`' "$REPO/$doc" |
      tr -d '`' |
      grep -E '^(\.|configs/|test/|windows/|powershell/|ahk/|keymaps/|docs/|osx/)' |
      sort -u)
  done
  [ -z "$missing" ] || {
    echo "documented paths that do not exist:$missing"
    false
  }
}
