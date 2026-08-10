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

@test "tmux-cleanup-windows fails outside tmux" {
  run env -u TMUX "$SCRIPTS/tmux-cleanup-windows.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not in a tmux session"* ]]
}

# --- tmux-pane-highlight inside a scratch tmux server -------------------------

@test "tmux-pane-highlight sets color, icon, and @claude_at timestamp" {
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
