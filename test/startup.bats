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

  # Every test here sources .zshrc, and on Linux that starts an ssh-agent
  # (#303). An agent inherits the pipe bats is reading, does not exit with the
  # shell that spawned it, and so holds that pipe open -- which is how the bats
  # job once sat for 34 minutes after every test had already passed. Stub it
  # out: `eval "$(ssh-agent)"` with no output is a no-op.
  STUB="$(mktemp -d)"
  printf '#!/bin/sh\nexit 0\n' >"$STUB/ssh-agent"
  chmod +x "$STUB/ssh-agent"
  PATH="$STUB:$PATH"
}

teardown() {
  [ -n "${STUB:-}" ] && rm -rf "$STUB"
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

# --- stderr ------------------------------------------------------------------

# asdf is a git clone, not a package, so "not installed yet" is a normal state
# for a fresh machine, a container or CI. The modules may advise you to install
# it; they may not fail trying to load it (#302).
startup_stderr() {
  env "$@" zsh -c "source '$REPO/.zshrc'" 2>&1 >/dev/null
}

@test "a machine without asdf gets advice, not a load error" {
  local home
  home="$(mktemp -d)"

  run startup_stderr HOME="$home"
  rm -rf "$home"

  ! grep -q 'asdf.sh' <<<"$output"
  ! grep -q 'no such file or directory' <<<"$output"
}

@test "asdf is still sourced when it is there" {
  local home
  home="$(mktemp -d)"
  mkdir -p "$home/.asdf"
  echo 'export ASDF_WAS_SOURCED=1' >"$home/.asdf/asdf.sh"

  run env HOME="$home" zsh -c "source '$REPO/.zshrc'; print \"sourced=\$ASDF_WAS_SOURCED\"" 2>/dev/null
  rm -rf "$home"

  grep -q '^sourced=1$' <<<"$output"
}

# --- $DOTFILES ---------------------------------------------------------------

# It used to be the literal /Users/`whoami`/.ghq/github.com/Naturalclar/dotfiles
# (#304): wrong on Linux and WSL, and wrong for a clone kept anywhere else.
# Deriving it from the module's own path is only correct if it survives the
# ~/.zshrc symlink, which is how every real shell reaches it.

@test "DOTFILES points at this repository" {
  run env zsh -c "source '$REPO/.zshrc'; print \"dotfiles=\$DOTFILES\"" 2>/dev/null
  grep -q "^dotfiles=$REPO\$" <<<"$output"
}

@test "DOTFILES survives being reached through the ~/.zshrc symlink" {
  local home
  home="$(mktemp -d)"
  ln -s "$REPO/.zshrc" "$home/.zshrc"

  run env HOME="$home" zsh -c "source '$home/.zshrc'; print \"dotfiles=\$DOTFILES\"" 2>/dev/null
  rm -rf "$home"

  grep -q "^dotfiles=$REPO\$" <<<"$output"
}

@test "DOTFILES is a directory holding the Makefile" {
  # cpdf copies into it, so a stale path would scatter files into a directory
  # that does not exist rather than fail.
  run env zsh -c "source '$REPO/.zshrc'; [[ -f \$DOTFILES/Makefile ]] && print ok" 2>/dev/null
  grep -q '^ok$' <<<"$output"
}

# --- per-OS paths ------------------------------------------------------------

# ~/Library is macOS's own layout. Exporting ANDROID_HOME into it from a Linux
# shell is worse than leaving it unset: Gradle and the React Native CLI take the
# variable as the truth and stop looking (#323).
@test "no macOS-only path is exported on Linux" {
  [ "$(uname)" = "Linux" ] || skip "checks what the Linux branch exports"

  run env zsh -c "source '$REPO/.zshrc'; env" 2>/dev/null
  ! grep -q '/Library/' <<<"$output"
}

@test "the Linux branch sets no Android or pnpm variable of its own" {
  [ "$(uname)" = "Linux" ] || skip "checks what the Linux branch exports"

  # Cleared first, so this measures what the config does rather than what the
  # machine already had: GitHub's Ubuntu runners export ANDROID_HOME
  # (/usr/local/lib/android/sdk) themselves, and an inherited value is none of
  # this repository's business -- what matters is that sourcing does not
  # invent one.
  run env -u ANDROID_HOME -u EMULATOR -u PNPM_HOME \
    zsh -c "source '$REPO/.zshrc'; print \"\${ANDROID_HOME-unset}|\${EMULATOR-unset}|\${PNPM_HOME-unset}\"" 2>/dev/null
  grep -q '^unset|unset|unset$' <<<"$output"
}

@test "the Linux branch leaves an inherited ANDROID_HOME alone" {
  [ "$(uname)" = "Linux" ] || skip "checks what the Linux branch exports"

  # The flip side: a machine that really does have an SDK sets the variable
  # before zsh starts, and the config has no business overwriting it.
  run env ANDROID_HOME=/opt/android-sdk \
    zsh -c "source '$REPO/.zshrc'; print \"android=\$ANDROID_HOME\"" 2>/dev/null
  grep -q '^android=/opt/android-sdk$' <<<"$output"
}

@test "the Darwin branch still sets them" {
  # The module keys on $OS, so the macOS half can be exercised anywhere. This
  # is what keeps "do not set it on Linux" from quietly becoming "do not set it
  # at all".
  run zsh -c "OS=Darwin; source '$REPO/.zsh/10-os.zsh'; print \"\$ANDROID_HOME|\$EMULATOR|\$PNPM_HOME\"" 2>/dev/null
  grep -q "Library/Android/sdk|.*Library/Android/sdk/emulator/emulator|.*Library/pnpm" <<<"$output"
}

# --- structure ---------------------------------------------------------------

@test "the timer lives in the loader, not in a module" {
  # An end marker parked in one module stops covering whatever is added after
  # it -- the old one sat in 74 and missed 75, 80 and 81. Keeping both markers
  # in .zshrc is what makes the number mean "the whole load".
  # Search only this repository's numbered modules.  A recursive search also
  # descends into the initialized zsh plugin submodules, whose own test suites
  # legitimately use zprof and make this assertion fail only on local setups.
  run grep -n 'EPOCHREALTIME\|zprof\|strftime' "$REPO"/.zsh/*.zsh
  [ "$status" -ne 0 ]

  grep -q 'ZSH_STARTUP_TIME' "$REPO/.zshrc"
  grep -q 'ZSH_PROFILE' "$REPO/.zshrc"
}
