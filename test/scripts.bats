#!/usr/bin/env bats

# Tests for the non-interactive behaviors of the tools in .scripts/.
# Run locally with `bats test/scripts.bats` (brew install bats-core).
# The fzf/tmux-interactive scripts (pmux, tmux-window-fzf, switch-worktree)
# can only be exercised by hand and are not covered here.

SCRIPTS="$BATS_TEST_DIRNAME/../.scripts"

# Scratch tmux server for the tmux-pane-highlight tests. The highlight script
# resolves the server from $TMUX, so pointing that at the scratch socket keeps
# the tests away from any real tmux session.
TMUX_SOCKET="bats-tph-$$"

# tmux handles option values through its own locale, so under LC_CTYPE=POSIX it
# stores the status emoji as underscores and the comparison below fails while
# nothing is actually broken (#325). Choose a UTF-8 locale the same way
# .zsh/00-core.zsh does -- only one that is really generated, since setting a
# locale the system does not have is its own kind of noise.
setup() {
  local candidate
  for candidate in en_US.UTF-8 C.UTF-8; do
    if locale -a 2>/dev/null | grep -qiE "^${candidate%.*}\\.(utf-?8)$"; then
      export LC_ALL="$candidate" LANG="$candidate"
      return 0
    fi
  done
}

# Skip only where no UTF-8 locale exists to switch to. Deliberately asks the
# system rather than reading back what setup exported: keyed on $LC_ALL, losing
# setup would turn this test into a silent skip instead of a failure, and the
# emoji would stop being checked anywhere.
require_utf8_locale() {
  locale -a 2>/dev/null | grep -qiE '\.(utf-?8)$' && return 0
  skip "no UTF-8 locale generated; tmux would store the emoji as underscores"
}

teardown() {
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
}

start_scratch_tmux() {
  command -v tmux >/dev/null || skip "tmux not available"
  tmux -L "$TMUX_SOCKET" -f /dev/null new-session -d -x 80 -y 24
  TEST_PANE=$(tmux -L "$TMUX_SOCKET" display-message -p '#{pane_id}')
  TEST_TMUX="$(tmux -L "$TMUX_SOCKET" display-message -p '#{socket_path}'),0,0"
}

# Read a pane/window user option from the scratch server; empty when unset.
scratch_opt() {
  tmux -L "$TMUX_SOCKET" show-options "$1" -t "$TEST_PANE" -v "$2" 2>/dev/null || true
}

# --- urlencode ---------------------------------------------------------------

@test "urlencode passes through safe characters" {
  run "$SCRIPTS/urlencode" "abc-DEF_123.~"
  [ "$status" -eq 0 ]
  [ "$output" = "abc-DEF_123.~" ]
}

@test "urlencode encodes spaces" {
  run "$SCRIPTS/urlencode" "test ok"
  [ "$status" -eq 0 ]
  [ "$output" = "test%20ok" ]
}

@test "urlencode encodes reserved characters" {
  run "$SCRIPTS/urlencode" "a/b?c=d&e"
  [ "$status" -eq 0 ]
  [ "$output" = "a%2fb%3fc%3dd%26e" ]
}

@test "urlencode joins multiple arguments with a space" {
  run "$SCRIPTS/urlencode" foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "foo%20bar" ]
}

@test "urlencode encodes stdin lines" {
  run bash -c "printf 'a b\nc d\n' | '$SCRIPTS/urlencode'"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "a%20b" ]
  [ "${lines[1]}" = "c%20d" ]
}

# --- killport ----------------------------------------------------------------

@test "killport without arguments prints usage and fails" {
  run "$SCRIPTS/killport"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: killport <port>"* ]]
}

@test "killport rejects a non-numeric port" {
  run "$SCRIPTS/killport" abc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Port must be a number"* ]]
}

@test "killport succeeds when nothing listens on the port" {
  run "$SCRIPTS/killport" 64999
  [ "$status" -eq 0 ]
  [[ "$output" == *"No processes found"* ]]
}

@test "killport kills a process listening on the port" {
  command -v python3 >/dev/null || skip "python3 not available"
  port=58231
  python3 -m http.server "$port" >/dev/null 2>&1 &
  server_pid=$!
  # wait for the server to be up
  for _ in $(seq 1 20); do
    lsof -ti:"$port" >/dev/null 2>&1 && break
    sleep 0.2
  done
  lsof -ti:"$port" >/dev/null 2>&1 || skip "test server failed to start"

  run "$SCRIPTS/killport" "$port"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Killing processes on port $port"* ]]

  # the listener should be gone shortly after
  for _ in $(seq 1 20); do
    lsof -ti:"$port" >/dev/null 2>&1 || break
    sleep 0.2
  done
  ! lsof -ti:"$port" >/dev/null 2>&1
  ! kill -0 "$server_pid" 2>/dev/null
}

# --- tmux helpers outside tmux ----------------------------------------------

@test "tmux-pane-name fails outside tmux" {
  run env -u TMUX "$SCRIPTS/tmux-pane-name" some-name
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not in a tmux session"* ]]
}

@test "tmux-pane-highlight is a silent no-op outside tmux" {
  run env -u TMUX -u TMUX_PANE "$SCRIPTS/tmux-pane-highlight" red
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- notify-sound ------------------------------------------------------------
#
# Everything here runs with a stub player on PATH: a test that actually made
# noise on the machine running it would be a poor citizen, and the point of the
# script is which command it decides to run, not the audio.

setup_notify_sound() {
  NS_TMP="$(mktemp -d)"
  NS_BIN="$NS_TMP/bin"
  mkdir -p "$NS_BIN"
  printf '#!/bin/sh\necho "$@" >>"%s/called"\n' "$NS_TMP" >"$NS_BIN/afplay"
  chmod +x "$NS_BIN/afplay"
  : >"$NS_TMP/sound.mp3"
}

# The player is detached, so the marker file lands a moment after the script
# returns.
ns_called() {
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -s "$NS_TMP/called" ] && break
    sleep 0.1
  done
  cat "$NS_TMP/called" 2>/dev/null
}

@test "notify-sound plays the file with the first player it finds" {
  setup_notify_sound
  run env PATH="$NS_BIN:$PATH" "$SCRIPTS/notify-sound" "$NS_TMP/sound.mp3"
  [ "$status" -eq 0 ]
  [ "$(ns_called)" = "$NS_TMP/sound.mp3" ]
  rm -rf "$NS_TMP"
}

@test "notify-sound takes the file from NOTIFY_SOUND" {
  setup_notify_sound
  run env PATH="$NS_BIN:$PATH" NOTIFY_SOUND="$NS_TMP/sound.mp3" "$SCRIPTS/notify-sound"
  [ "$status" -eq 0 ]
  [ "$(ns_called)" = "$NS_TMP/sound.mp3" ]
  rm -rf "$NS_TMP"
}

@test "notify-sound is a silent no-op with no player installed" {
  # What a Linux machine looks like: the hook fires, nothing can play it (#321).
  # PATH points at an empty directory, and bash is named by absolute path:
  # `env` resolves the command it runs through the PATH it just set, so a bare
  # `bash` here would fail to launch and prove nothing about the script.
  setup_notify_sound
  mkdir -p "$NS_TMP/empty"
  local bash_bin
  bash_bin="$(command -v bash)"

  run env PATH="$NS_TMP/empty" "$bash_bin" "$SCRIPTS/notify-sound" "$NS_TMP/sound.mp3"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -s "$NS_TMP/called" ]
  rm -rf "$NS_TMP"
}

@test "notify-sound is a silent no-op when the sound file is missing" {
  # The mp3 is not in this repository, so this is the state on any machine
  # that has not been given one.
  setup_notify_sound
  run env PATH="$NS_BIN:$PATH" "$SCRIPTS/notify-sound" "$NS_TMP/absent.mp3"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -s "$NS_TMP/called" ]
  rm -rf "$NS_TMP"
}

@test "notify-sound --help prints usage" {
  run "$SCRIPTS/notify-sound" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: notify-sound"* ]]
}

# --- sai-record --------------------------------------------------------------
#
# The Claude Code hooks call this on every turn, so it must never fail and
# never print: a non-zero exit stops the agent, and stdout is where a hook's
# permission decision would go. A stub record.py stands in for sai's.

write_record_stub() {
  mkdir -p "$1/feed"
  cat > "$1/feed/record.py" <<'PY'
import os, sys
open(os.environ["RECORD_OUT"], "w").write(sys.stdin.read())
print("a decision that must not reach the hook")
sys.exit(int(os.environ.get("RECORD_EXIT", "0")))
PY
}

@test "sai-record --help prints usage" {
  run "$SCRIPTS/sai-record" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: sai-record"* ]]
}

@test "sai-record is a silent no-op when SAI_HOME does not exist" {
  run env SAI_HOME="$BATS_TEST_TMPDIR/nowhere" "$SCRIPTS/sai-record" <<< '{}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "sai-record is a silent no-op when SAI_HOME has no record.py" {
  run env SAI_HOME="$BATS_TEST_TMPDIR" "$SCRIPTS/sai-record" <<< '{}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "sai-record hands the hook event on stdin to record.py and prints nothing" {
  command -v python3 >/dev/null || skip "python3 not available"
  write_record_stub "$BATS_TEST_TMPDIR"
  run env SAI_HOME="$BATS_TEST_TMPDIR" RECORD_OUT="$BATS_TEST_TMPDIR/out" \
    "$SCRIPTS/sai-record" <<< '{"hook_event_name":"Stop"}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ "$(cat "$BATS_TEST_TMPDIR/out")" = '{"hook_event_name":"Stop"}' ]
}

@test "sai-record exits 0 even when record.py fails" {
  command -v python3 >/dev/null || skip "python3 not available"
  write_record_stub "$BATS_TEST_TMPDIR"
  run env SAI_HOME="$BATS_TEST_TMPDIR" RECORD_OUT="$BATS_TEST_TMPDIR/out" RECORD_EXIT=3 \
    "$SCRIPTS/sai-record" <<< '{}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "tmux-cleanup-windows fails outside tmux" {
  run env -u TMUX "$SCRIPTS/tmux-cleanup-windows.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not in a tmux session"* ]]
}

# --- tmux-pane-highlight inside a scratch tmux server -------------------------

@test "tmux-pane-highlight sets color, icon, and @claude_at timestamp" {
  require_utf8_locale
  start_scratch_tmux
  before=$(date +%s)

  run env TMUX="$TEST_TMUX" TMUX_PANE="$TEST_PANE" "$SCRIPTS/tmux-pane-highlight" yellow
  [ "$status" -eq 0 ]

  [ "$(scratch_opt -p @pane_color)" = "yellow" ]
  [ "$(scratch_opt -w @claude_status)" = "🟡" ]
  pane_at=$(scratch_opt -p @claude_at)
  [[ "$pane_at" =~ ^[0-9]+$ ]]
  [ "$pane_at" -ge "$before" ]
  # window scope carries the same timestamp for the status-line display
  [ "$(scratch_opt -w @claude_at)" = "$pane_at" ]
}

@test "tmux-pane-highlight off clears pane and window options" {
  start_scratch_tmux
  env TMUX="$TEST_TMUX" TMUX_PANE="$TEST_PANE" "$SCRIPTS/tmux-pane-highlight" red

  run env TMUX="$TEST_TMUX" TMUX_PANE="$TEST_PANE" "$SCRIPTS/tmux-pane-highlight" off
  [ "$status" -eq 0 ]

  [ -z "$(scratch_opt -p @pane_color)" ]
  [ -z "$(scratch_opt -p @claude_at)" ]
  [ -z "$(scratch_opt -w @claude_status)" ]
  [ -z "$(scratch_opt -w @claude_at)" ]
}

# --- tmux-claude-elapsed ------------------------------------------------------

@test "tmux-claude-elapsed prints nothing without an argument" {
  run "$SCRIPTS/tmux-claude-elapsed"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "tmux-claude-elapsed prints nothing for a non-numeric argument" {
  run "$SCRIPTS/tmux-claude-elapsed" "not-a-timestamp"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "tmux-claude-elapsed prints seconds under a minute" {
  run "$SCRIPTS/tmux-claude-elapsed" "$(( $(date +%s) - 5 ))"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+s$ ]]
}

@test "tmux-claude-elapsed prints minutes under an hour" {
  run "$SCRIPTS/tmux-claude-elapsed" "$(( $(date +%s) - 120 ))"
  [ "$status" -eq 0 ]
  [ "$output" = "2m" ]
}

@test "tmux-claude-elapsed prints hours and minutes" {
  run "$SCRIPTS/tmux-claude-elapsed" "$(( $(date +%s) - 7500 ))"
  [ "$status" -eq 0 ]
  [ "$output" = "2h05m" ]
}

# --- help/usage flags --------------------------------------------------------

@test "tmux-send-all --help prints usage" {
  run "$SCRIPTS/tmux-send-all" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: tmux-send-all"* ]]
}

@test "tmux-send-all rejects mixing --target and --ignore" {
  run "$SCRIPTS/tmux-send-all" -t 1 -i 2 -c ls
  [ "$status" -eq 1 ]
  [[ "$output" == *"mutually exclusive"* ]]
}

@test "tssh --help prints usage" {
  run "$SCRIPTS/tssh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: tssh"* ]]
}

@test "tssh rejects unknown options" {
  run "$SCRIPTS/tssh" --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown option"* ]]
}
