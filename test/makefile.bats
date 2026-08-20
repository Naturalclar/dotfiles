#!/usr/bin/env bats

# Tests for the symlink targets in the Makefile (dotfiles / config / unlink).
#
# Everything runs against a throwaway $HOME, so a fresh machine is reproduced
# without touching the real one. `make` is checked for what it actually
# produced, not just for exit status: `ln -sfn` fails silently in ways that
# still leave make green (see #260).
#
# Run locally with `bats test/makefile.bats` (brew install bats-core).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FAKE_HOME="$(mktemp -d)"
}

teardown() {
  [ -n "${FAKE_HOME:-}" ] && rm -rf "$FAKE_HOME"
}

# `readlink -f` is GNU-only, and these tests also run on macOS, so compare
# against the single-level link target that the Makefile writes.
assert_links_to() {
  [ -L "$1" ]
  [ "$(readlink "$1")" = "$2" ]
}

# --- make dotfiles -----------------------------------------------------------

@test "make dotfiles symlinks a dotfile into HOME" {
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.zshrc" "$REPO/.zshrc"
}

@test "make dotfiles symlinks a directory into HOME" {
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.scripts" "$REPO/.scripts"
  # .scripts is symlinked as a whole, so new scripts land in $HOME for free.
  [ -x "$FAKE_HOME/.scripts/pmux" ]
}

@test "make dotfiles skips repository-only entries" {
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  for entry in .git .github .gitignore .gitmodules .config; do
    [ ! -e "$FAKE_HOME/$entry" ]
  done
}

@test "make dotfiles is idempotent" {
  make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.zshrc" "$REPO/.zshrc"
  # A second run must not bury the link inside the first one.
  [ ! -e "$FAKE_HOME/.scripts/.scripts" ]
}

@test "make dotfiles replaces a pre-existing regular file" {
  echo "stale" >"$FAKE_HOME/.zshrc"
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.zshrc" "$REPO/.zshrc"
}

@test "make dotfiles does not nest the link inside an existing real directory" {
  mkdir -p "$FAKE_HOME/.vim/pack"
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ ! -e "$FAKE_HOME/.vim/.vim" ]
  # The user's directory is left exactly as it was, and the skip is reported.
  [ -d "$FAKE_HOME/.vim/pack" ]
  [ ! -L "$FAKE_HOME/.vim" ]
  [[ "$output" == *"skip $FAKE_HOME/.vim"* ]]
}

@test "make dotfiles replaces a symlinked directory rather than skipping it" {
  ln -s /tmp "$FAKE_HOME/.vim"
  run make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.vim" "$REPO/.vim"
}

@test "make dotfiles does not symlink repository tooling directories" {
  make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  [ ! -e "$FAKE_HOME/.devcontainer" ]
  [ ! -e "$FAKE_HOME/.vscode" ]
}

# --- make config -------------------------------------------------------------

@test "make config symlinks .config entries into HOME/.config" {
  mkdir -p "$FAKE_HOME/.config"
  run make -C "$REPO" config HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.config/nvim" "$REPO/.config/nvim"
}

@test "make config does not nest the link inside an existing real directory" {
  mkdir -p "$FAKE_HOME/.config/nvim/lua"
  run make -C "$REPO" config HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ ! -e "$FAKE_HOME/.config/nvim/nvim" ]
  [ -d "$FAKE_HOME/.config/nvim/lua" ]
  # Unaffected entries are still linked.
  assert_links_to "$FAKE_HOME/.config/kitty" "$REPO/.config/kitty"
}

@test "make config succeeds when HOME/.config does not exist yet" {
  run make -C "$REPO" config HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.config/nvim" "$REPO/.config/nvim"
}

# --- make claude -------------------------------------------------------------

@test "make claude creates ~/.claude and symlinks settings.json" {
  run make -C "$REPO" claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.claude/settings.json" "$REPO/configs/claude/settings.json"
}

@test "make claude symlinks each skill into ~/.claude/skills" {
  run make -C "$REPO" claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.claude/skills/tailscale-serve" \
    "$REPO/configs/claude/skills/tailscale-serve"
  [ -f "$FAKE_HOME/.claude/skills/tailscale-serve/SKILL.md" ]
}

@test "make claude leaves skills it did not install alone" {
  # ~/.claude/skills is shared, so linking the directory as a whole would hide
  # whatever else is in it. Link the skills one at a time instead.
  mkdir -p "$FAKE_HOME/.claude/skills/someone-elses"
  touch "$FAKE_HOME/.claude/skills/someone-elses/SKILL.md"

  run make -C "$REPO" claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ -f "$FAKE_HOME/.claude/skills/someone-elses/SKILL.md" ]
  assert_links_to "$FAKE_HOME/.claude/skills/tailscale-serve" \
    "$REPO/configs/claude/skills/tailscale-serve"
}

@test "make claude does not nest the link inside an existing real skill directory" {
  mkdir -p "$FAKE_HOME/.claude/skills/tailscale-serve"
  echo "mine" >"$FAKE_HOME/.claude/skills/tailscale-serve/SKILL.md"

  run make -C "$REPO" claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ ! -e "$FAKE_HOME/.claude/skills/tailscale-serve/tailscale-serve" ]
  [ "$(cat "$FAKE_HOME/.claude/skills/tailscale-serve/SKILL.md")" = "mine" ]
}

@test "make claude is idempotent" {
  make -C "$REPO" claude HOME="$FAKE_HOME"
  run make -C "$REPO" claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  assert_links_to "$FAKE_HOME/.claude/skills/tailscale-serve" \
    "$REPO/configs/claude/skills/tailscale-serve"
  [ ! -e "$FAKE_HOME/.claude/skills/tailscale-serve/tailscale-serve" ]
}

# --- skills ------------------------------------------------------------------

@test "every skill has SKILL.md with a name and description in its frontmatter" {
  # Claude Code reads the frontmatter to decide when to load a skill, so a
  # skill missing either field is installed but never triggers.
  shopt -s nullglob
  local found=0
  for skill in "$REPO"/configs/claude/skills/*/; do
    found=$((found + 1))
    [ -f "$skill/SKILL.md" ]
    run head -1 "$skill/SKILL.md"
    [ "$output" = "---" ]
    grep -q '^name: ' "$skill/SKILL.md"
    grep -q '^description: ' "$skill/SKILL.md"
    # The directory name is the skill name; a mismatch is confusing at best.
    grep -q "^name: $(basename "$skill")\$" "$skill/SKILL.md"
  done
  [ "$found" -gt 0 ]
}

# --- make unlink -------------------------------------------------------------

@test "make unlink removes the symlinks it created" {
  mkdir -p "$FAKE_HOME/.config"
  make -C "$REPO" dotfiles HOME="$FAKE_HOME"
  make -C "$REPO" config HOME="$FAKE_HOME"
  [ -L "$FAKE_HOME/.zshrc" ]

  run make -C "$REPO" unlink HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ ! -e "$FAKE_HOME/.zshrc" ]
  [ ! -e "$FAKE_HOME/.scripts" ]
  [ ! -e "$FAKE_HOME/.config/nvim" ]
}

@test "make unlink leaves files it did not create alone" {
  echo "mine" >"$FAKE_HOME/.zshrc"
  run make -C "$REPO" unlink HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ -f "$FAKE_HOME/.zshrc" ]
  [ "$(cat "$FAKE_HOME/.zshrc")" = "mine" ]
}

# --- make list / help --------------------------------------------------------

@test "make list names the dotfiles it would link" {
  run make -C "$REPO" list
  [ "$status" -eq 0 ]
  [[ "$output" == *".zshrc"* ]]
  [[ "$output" == *".tmux.conf"* ]]
}

@test "make help lists the available targets" {
  run make -C "$REPO" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"dotfiles:"* ]]
  [[ "$output" == *"config:"* ]]
  [[ "$output" == *"unlink:"* ]]
}
