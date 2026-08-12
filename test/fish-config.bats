#!/usr/bin/env bats

# Tests for the parts of .config/fish/ that mirror .zshrc: the PATH entry for
# .scripts, and the UTF-8 locale forcing. Both were missing from fish and are
# invisible when broken -- the shell still starts, the scripts just are not
# there and multibyte output silently breaks over SSH.
#
# Run locally with `bats test/fish-config.bats` (needs fish and bats-core).

REPO="$BATS_TEST_DIRNAME/.."
FISH_DIR="$BATS_TEST_DIRNAME/../.config/fish"

setup() {
  command -v fish >/dev/null || skip "fish not available"
  WORK="$(mktemp -d)"
}

teardown() {
  [ -n "${WORK:-}" ] && rm -rf "$WORK"
}

# Run fish with $HOME pointing at a throwaway directory that has .scripts
# linked in, the way `make` sets it up.
fish_with_home() {
  ln -sfn "$(cd "$REPO" && pwd)/.scripts" "$WORK/.scripts"
  HOME="$WORK" fish -c "source $FISH_DIR/config.fish 2>/dev/null; $1"
}

# Put a stub `locale` earlier on PATH so the available locales can be varied.
stub_locale() {
  mkdir -p "$WORK/bin"
  {
    echo '#!/bin/sh'
    printf "printf '%s\\\\n'\n" "$1"
  } >"$WORK/bin/locale"
  chmod +x "$WORK/bin/locale"
}

# --- .scripts on PATH (#271) -------------------------------------------------

@test "fish puts .scripts on PATH" {
  run fish_with_home 'string match -q "*/.scripts*" "$PATH"; and echo found'
  [ "$status" -eq 0 ]
  [ "$output" = "found" ]
}

@test "the repository's scripts are callable from fish" {
  for script in pmux tssh killport urlencode tmux-window-fzf; do
    run fish_with_home "command -v $script >/dev/null; and echo ok"
    [ "$output" = "ok" ] || {
      echo "$script is not on PATH in fish"
      false
    }
  done
}

# --- UTF-8 locale (#273) -----------------------------------------------------

@test "fish prefers en_US.UTF-8 when it is generated" {
  stub_locale 'C\nC.utf8\nen_US.utf8\nPOSIX'
  run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "en_US.UTF-8" ]
}

@test "fish falls back to C.UTF-8 when that is all there is" {
  stub_locale 'C\nC.utf8\nPOSIX'
  run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "C.UTF-8" ]
}

@test "fish sets no locale when none is generated" {
  stub_locale 'C\nPOSIX'
  # fish sets LANG=C.UTF-8 on its own when the environment has no usable
  # locale, so LC_ALL is what shows whether the block actually ran.
  run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "fish and zsh choose the same locale" {
  command -v zsh >/dev/null || skip "zsh not available"
  stub_locale 'C\nC.utf8\nen_US.utf8\nPOSIX'

  from_fish="$(env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL")"
  from_zsh="$(env PATH="$WORK/bin:$PATH" zsh -c "source $REPO/.zshrc >/dev/null 2>&1; echo \$LC_ALL")"
  [ "$from_fish" = "$from_zsh" ] || {
    echo "fish=[$from_fish] zsh=[$from_zsh]"
    false
  }
}
