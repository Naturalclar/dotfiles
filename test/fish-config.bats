#!/usr/bin/env bats

# Tests for the parts of .config/fish/ that mirror .zshrc: the PATH entry for
# .scripts, and the UTF-8 locale forcing. Both were missing from fish and are
# invisible when broken -- the shell still starts, the scripts just are not
# there and multibyte output silently breaks over SSH.
#
# Run locally with `bats test/fish-config.bats` (needs fish and bats-core).

REPO="$BATS_TEST_DIRNAME/.."
FISH_DIR="$BATS_TEST_DIRNAME/../.config/fish"
FISH_FUNCS="$FISH_DIR/functions"

setup() {
  command -v fish >/dev/null || skip "fish not available"
  WORK="$(mktemp -d)"
}

teardown() {
  [ -n "${WORK:-}" ] && rm -rf "$WORK"
}

# Shells are always run with stdin closed and a deadline. A shell that blocks
# on a read would otherwise stall the CI step for hours instead of failing, and
# the timeout makes it obvious *which* case is at fault.
sh_run() {
  timeout 30 "$@" </dev/null
}

# Run fish with $HOME pointing at a throwaway directory that has .scripts
# linked in, the way `make` sets it up.
fish_with_home() {
  ln -sfn "$(cd "$REPO" && pwd)/.scripts" "$WORK/.scripts"
  HOME="$WORK" sh_run fish -c "source $FISH_DIR/config.fish 2>/dev/null; $1"
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
  run sh_run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "en_US.UTF-8" ]
}

@test "fish falls back to C.UTF-8 when that is all there is" {
  stub_locale 'C\nC.utf8\nPOSIX'
  run sh_run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "C.UTF-8" ]
}

@test "fish sets no locale when none is generated" {
  stub_locale 'C\nPOSIX'
  # fish sets LANG=C.UTF-8 on its own when the environment has no usable
  # locale, so LC_ALL is what shows whether the block actually ran.
  run sh_run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "fish and zsh choose the same locale" {
  command -v zsh >/dev/null || skip "zsh not available"
  stub_locale 'C\nC.utf8\nen_US.utf8\nPOSIX'

  # Only the locale block is pulled out of .zshrc, the same way prompt.bats
  # takes just _prompt_path. Sourcing the whole file would drag in compinit,
  # plugins and tool hooks -- none of which this is testing, and any one of
  # which can leave a process behind holding the CI step's pipes open.
  zsh_locale_block="$(sed -n '/^for _l in /,/^unset _l$/p' "$REPO"/.zsh/*.zsh)"
  [ -n "$zsh_locale_block" ]

  from_fish="$(sh_run env PATH="$WORK/bin:$PATH" fish -c "source $FISH_DIR/conf.d/locale.fish; echo \$LC_ALL" 2>/dev/null)"
  from_zsh="$(sh_run env PATH="$WORK/bin:$PATH" zsh -c "$zsh_locale_block"'; echo $LC_ALL' 2>/dev/null)"
  [ "$from_fish" = "$from_zsh" ] || {
    echo "fish=[$from_fish] zsh=[$from_zsh]"
    false
  }
}

# --- keybinding targets ported from zsh (#272) --------------------------------

# fzf is interactive, so it is replaced with "take the first candidate". That is
# enough to exercise everything around the picker.
make_repo() {
  git init -q "$1"
  git -C "$1" config user.email t@example.com
  git -C "$1" config user.name test
  git -C "$1" commit -qm init --allow-empty
}

fish_pick_first() {
  sh_run fish -c "
    source $FISH_FUNCS/$1.fish
    function fzf; head -1; end
    $2
  "
}

@test "run-script refuses to run outside a package.json directory" {
  run sh_run fish -c "cd $WORK; source $FISH_FUNCS/run-script.fish; run-script"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No package.json"* ]]
}

@test "run-script picks the package manager from the lockfile" {
  mkdir -p "$WORK/pkg"
  cat >"$WORK/pkg/package.json" <<'JSON'
{ "scripts": { "start": "true" } }
JSON

  run fish_pick_first run-script "cd $WORK/pkg; run-script"
  [[ "$output" == *"Running: npm run start"* ]]

  for pair in "yarn.lock:yarn start" "pnpm-lock.yaml:pnpm start" "bun.lockb:bun run start"; do
    lock="${pair%%:*}"
    expected="${pair#*:}"
    : >"$WORK/pkg/$lock"
    run fish_pick_first run-script "cd $WORK/pkg; run-script"
    [[ "$output" == *"Running: $expected"* ]] || {
      echo "$lock should select '$expected', got: $output"
      false
    }
    rm -f "$WORK/pkg/$lock"
  done
}

@test "switch-worktree reports when there are no linked worktrees" {
  make_repo "$WORK/repo"
  run sh_run fish -c "cd $WORK/repo; source $FISH_FUNCS/switch-worktree.fish; switch-worktree"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No linked worktrees"* ]]
}

@test "switch-worktree changes to the selected worktree" {
  make_repo "$WORK/repo"
  git -C "$WORK/repo" worktree add -q "$WORK/wt" -b feature
  run fish_pick_first switch-worktree "cd $WORK/repo; switch-worktree; echo \$PWD"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$WORK/wt"* ]]
}

# --- parity with zsh on editor and key bindings (#274) ------------------------

@test "fish and zsh export the same editor variables" {
  from_fish="$(sh_run fish -c "source $FISH_DIR/conf.d/editor.fish; echo \$EDITOR \$GIT_EDITOR" 2>/dev/null)"
  from_zsh="$(sh_run zsh -c "source $REPO/.zsh/50-path.zsh >/dev/null 2>&1; echo \$EDITOR \$GIT_EDITOR" 2>/dev/null)"
  [ "$from_fish" = "vim vim" ]
  [ "$from_fish" = "$from_zsh" ]
}

@test "both shells use vi key bindings" {
  # zsh sets it with `set -o vi`; fish pins fish_key_bindings as a universal
  # variable, which is committed so it does not get rewritten on every start.
  run sh_run zsh -c "source $REPO/.zsh/00-core.zsh >/dev/null 2>&1; setopt"
  [[ "$output" == *"vi"* ]]
  grep -qx "SETUVAR fish_key_bindings:fish_vi_key_bindings" "$FISH_DIR/fish_variables"
}
