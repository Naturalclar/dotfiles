#!/usr/bin/env bats

# Tests for the non-interactive behaviors of the tools in .scripts/.
# Run locally with `bats test/scripts.bats` (brew install bats-core).
# The fzf/tmux-interactive scripts (pmux, tmux-window-fzf, switch-worktree)
# can only be exercised by hand and are not covered here.

SCRIPTS="$BATS_TEST_DIRNAME/../.scripts"

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
