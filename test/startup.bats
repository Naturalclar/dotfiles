#!/usr/bin/env bats

# Tests for what a new shell prints.
#
# A shell that writes to stdout on every start corrupts anything reading that
# stdout, and the offender here was a leftover profiling probe that printed a
# bare millisecond count (#301). So the rule is asserted directly: by default
# the loader prints nothing of its own, and the timing and profiling output
# appear only when asked for.
#
# Run locally with `bats test/startup.bats` (brew install bats-core).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

# The modules print their own advice on a machine that is missing asdf, ghq and
# friends, which is exactly the case in CI. Those lines are theirs to print --
# what must not appear is output from the loader itself.
startup_stdout() {
  env "$@" zsh -c "source '$REPO/.zshrc'" 2>/dev/null
}

# --- default: silent ---------------------------------------------------------

@test "a plain startup prints no bare number" {
  run startup_stdout
  [ "$status" -eq 0 ]
  # `echo $((end_time - start_time))` printed exactly this: digits, nothing else.
  ! grep -qE '^[0-9]+$' <<<"$output"
}

@test "a plain startup prints no timing line" {
  run startup_stdout
  [ "$status" -eq 0 ]
  ! grep -q 'zsh startup:' <<<"$output"
}

@test "a plain startup prints no profile table" {
  run startup_stdout
  [ "$status" -eq 0 ]
  ! grep -q 'num  calls' <<<"$output"
}

# --- opt-in ------------------------------------------------------------------

@test "ZSH_STARTUP_TIME reports the load time in ms" {
  run startup_stdout ZSH_STARTUP_TIME=1
  [ "$status" -eq 0 ]
  grep -qE '^zsh startup: [0-9]+ms$' <<<"$output"
}

@test "ZSH_PROFILE prints the zprof table" {
  run startup_stdout ZSH_PROFILE=1
  [ "$status" -eq 0 ]
  grep -q 'num  calls' <<<"$output"
}

# --- structure ---------------------------------------------------------------

@test "the timer lives in the loader, not in a module" {
  # An end marker parked in one module stops covering whatever is added after
  # it -- the old one sat in 74 and missed 75, 80 and 81. Keeping both markers
  # in .zshrc is what makes the number mean "the whole load".
  run grep -rn 'EPOCHREALTIME\|zprof\|strftime' "$REPO/.zsh"
  [ "$status" -ne 0 ]

  grep -q 'ZSH_STARTUP_TIME' "$REPO/.zshrc"
  grep -q 'ZSH_PROFILE' "$REPO/.zshrc"
}
