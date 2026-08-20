#!/usr/bin/env bats

# Tests for the ssh-agent handling in .zsh/10-os.zsh (Linux branch).
#
# It used to be `eval "$(ssh-agent)"`, which started a fresh agent for every
# shell: stray processes for every terminal ever opened, and a key added in one
# window missing from the next (#303). What replaced it has to hold three
# properties, so all three are pinned here:
#
#   1. start an agent when nothing is reachable
#   2. reuse it in later shells rather than starting another
#   3. never displace an agent that is already reachable (SSH forwarding)
#
# ssh-agent and ssh-add are stubbed. Real ones would leave agents behind on the
# machine running the tests, and a stub can be made to fail on demand, which is
# what the stale-socket case needs. The stub mimics the exit codes the real
# ssh-add uses: 2 for "could not reach an agent", 1 for "agent, but no keys".
#
# Run locally with `bats test/ssh-agent.bats` (brew install bats-core).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TMP="$(mktemp -d)"
  RUNTIME="$TMP/run"
  STUB="$TMP/bin"
  AGENT_LOG="$TMP/starts"
  mkdir -p "$RUNTIME" "$STUB"
  : >"$AGENT_LOG"

  # A bound AF_UNIX socket leaves its filesystem entry behind after the process
  # exits, which is exactly what a real agent's socket looks like to `-S`.
  cat >"$STUB/ssh-agent" <<'STUB_AGENT'
#!/bin/sh
echo "start $*" >>"$AGENT_LOG"
sock=""
while [ $# -gt 0 ]; do
  case "$1" in
    -a) sock="$2"; shift 2 ;;
    *) shift ;;
  esac
done
if [ -n "$sock" ]; then
  python3 -c 'import socket, sys
s = socket.socket(socket.AF_UNIX)
s.bind(sys.argv[1])
s.listen(1)' "$sock"
  : >"$sock.alive"
fi
echo "SSH_AUTH_SOCK=$sock; export SSH_AUTH_SOCK;"
STUB_AGENT

  # Reachable only while the marker is there, so a socket can be left behind
  # without an agent answering on it.
  cat >"$STUB/ssh-add" <<'STUB_ADD'
#!/bin/sh
[ -n "$SSH_AUTH_SOCK" ] && [ -f "$SSH_AUTH_SOCK.alive" ] && exit 1
exit 2
STUB_ADD

  chmod +x "$STUB/ssh-agent" "$STUB/ssh-add"
  export AGENT_LOG
}

teardown() {
  [ -n "${TMP:-}" ] && rm -rf "$TMP"
}

# Report SSH_AUTH_SOCK as the shell ends up with it.
start_shell() {
  env PATH="$STUB:$PATH" XDG_RUNTIME_DIR="$RUNTIME" "$@" \
    zsh -c "source '$REPO/.zshrc'; print \"sock=\$SSH_AUTH_SOCK\"" 2>/dev/null |
    grep '^sock='
}

agents_started() {
  wc -l <"$AGENT_LOG" | tr -d ' '
}

@test "starts an agent when none is reachable" {
  run start_shell SSH_AUTH_SOCK=
  [ "$output" = "sock=$RUNTIME/ssh-agent-$(id -u).sock" ]
  [ "$(agents_started)" -eq 1 ]
}

@test "a second shell reuses the running agent" {
  start_shell SSH_AUTH_SOCK= >/dev/null
  run start_shell SSH_AUTH_SOCK=

  [ "$output" = "sock=$RUNTIME/ssh-agent-$(id -u).sock" ]
  # The regression this whole file exists for: one agent, not one per shell.
  [ "$(agents_started)" -eq 1 ]
}

@test "an agent already reachable is left alone" {
  # What SSH agent forwarding looks like: SSH_AUTH_SOCK points somewhere else
  # entirely, and something is answering on it.
  local forwarded="$TMP/forwarded.sock"
  python3 -c 'import socket, sys
s = socket.socket(socket.AF_UNIX)
s.bind(sys.argv[1])
s.listen(1)' "$forwarded"
  : >"$forwarded.alive"

  run start_shell SSH_AUTH_SOCK="$forwarded"

  [ "$output" = "sock=$forwarded" ]
  [ "$(agents_started)" -eq 0 ]
}

@test "a socket left by a dead agent is replaced" {
  start_shell SSH_AUTH_SOCK= >/dev/null
  # The agent goes away; its socket file stays behind. ssh-agent -a will not
  # bind over it, so the config has to clear it first.
  rm -f "$RUNTIME/ssh-agent-$(id -u).sock.alive"

  run start_shell SSH_AUTH_SOCK=

  [ "$output" = "sock=$RUNTIME/ssh-agent-$(id -u).sock" ]
  [ "$(agents_started)" -eq 2 ]
}

@test "no ssh-agent installed is not an error" {
  # Containers and CI images often have no openssh-client at all.
  rm -f "$STUB/ssh-agent" "$STUB/ssh-add"
  cat >"$STUB/ssh-add" <<'STUB_ADD'
#!/bin/sh
exit 2
STUB_ADD
  chmod +x "$STUB/ssh-add"

  run env PATH="$STUB:$PATH" XDG_RUNTIME_DIR="$RUNTIME" SSH_AUTH_SOCK= \
    zsh -c "source '$REPO/.zshrc'" 2>&1 >/dev/null

  ! grep -q 'ssh-agent' <<<"$output"
}
