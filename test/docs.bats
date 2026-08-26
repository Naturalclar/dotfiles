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

# Comments are stripped first: the workflow explains the glob in a comment that
# names test/*.bats, and matching that would pass whatever the steps do.
ci_globs_suites() {
  local wf
  for wf in "$REPO"/.github/workflows/*.yml; do
    sed 's/#.*//' "$wf" | grep -q 'test/\*\.bats' && return 0
  done
  return 1
}

@test "every bats suite is run by CI" {
  # Adding a suite and forgetting the workflow step leaves it passing locally
  # and never running anywhere else. A workflow that globs test/*.bats gets
  # that right for every suite at once, so it satisfies this on its own; the
  # per-suite check is what applies if the steps are ever spelled out again.
  ci_globs_suites && return 0

  local missing=""
  for suite in "$REPO"/test/*.bats; do
    grep -qr "bats test/$(basename "$suite")" "$REPO/.github/workflows" || missing+=" $(basename "$suite")"
  done
  [ -z "$missing" ] || {
    echo "suites no workflow runs:$missing"
    false
  }
}

@test "the suites are found by CI rather than listed" {
  # The glob is the thing that makes the check above unnecessary. Losing it
  # silently is what this pins: a suite that never runs looks exactly like a
  # suite that passes.
  ci_globs_suites
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

# --- the tools the docs and CI assume are installed ---------------------------

@test "every tool CI installs by hand is in the Brewfile" {
  # `make brew` is how a new machine gets the toolchain, so anything CI has to
  # `brew install` for itself is something that machine would otherwise not
  # have. bats-core was missing that way: every suite here told you to install
  # it separately (#307).
  local missing=""
  local formula
  while IFS= read -r formula; do
    grep -qE "^brew \"$formula\"" "$REPO/Brewfile" || missing+=" $formula"
  done < <(grep -rhoE 'brew install [a-z0-9._-]+' "$REPO/.github/workflows" |
    awk '{print $3}' | sort -u)

  [ -z "$missing" ] || {
    echo "formulae CI installs but the Brewfile does not list:$missing"
    false
  }
}

@test "the Brewfile carries the tools the test docs need" {
  # test/README.md sends you to bats; regenerating the Brewfile from
  # `brew leaves` on a machine would silently drop it again.
  grep -qE '^brew "bats-core"' "$REPO/Brewfile"
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

@test "every skill is listed in the README skill table" {
  # A skill nobody knows about is a skill nobody uses -- and unlike a shell
  # function, there is nothing to stumble over in the config. The table is the
  # only place they are advertised.
  local missing=""
  local skill name
  for skill in "$REPO"/.claude/skills/*/; do
    name="$(basename "$skill")"
    grep -q "| \`$name\` |" "$REPO/README.md" || missing+=" $name"
  done
  [ -z "$missing" ] || {
    echo "skills missing from the README table:$missing"
    false
  }
}
