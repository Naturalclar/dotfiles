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
  # .claude is this repository's own configuration -- its skills are linked
  # individually by `make claude`, and ~/.claude is Claude Code's state
  # directory, not somewhere to point at a clone.
  for entry in .git .github .gitignore .gitmodules .config .claude; do
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
    "$REPO/.claude/skills/tailscale-serve"
  [ -f "$FAKE_HOME/.claude/skills/tailscale-serve/SKILL.md" ]
}

@test "every hook command in settings.json is a tool in .scripts" {
  # settings.json is the same file on every machine `make claude` runs on, so
  # a hook that spells out an interpreter and an absolute path -- as the sai
  # recorder once did, with one machine's home directory baked into an `env`
  # block -- works on one machine and errors on every other. Anything a hook
  # needs that differs per machine belongs in the environment, read by a
  # wrapper in .scripts that copes with it being absent.
  local bad=""
  local cmd
  while IFS= read -r cmd; do
    [ -x "$REPO/.scripts/${cmd%% *}" ] || bad+=" '$cmd'"
  done < <(grep -oE '"command": *"[^"]+"' "$REPO/configs/claude/settings.json" |
    sed -E 's/^"command": *"//; s/"$//')

  [ -z "$bad" ] || {
    echo "hook commands that are not tools in .scripts:$bad"
    false
  }
  ! grep -nE '/(Users|home)/' "$REPO/configs/claude/settings.json"
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
    "$REPO/.claude/skills/tailscale-serve"
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
    "$REPO/.claude/skills/tailscale-serve"
  [ ! -e "$FAKE_HOME/.claude/skills/tailscale-serve/tailscale-serve" ]
}

# --- skills ------------------------------------------------------------------

@test "every skill has SKILL.md with a name and description in its frontmatter" {
  # Claude Code reads the frontmatter to decide when to load a skill, so a
  # skill missing either field is installed but never triggers.
  shopt -s nullglob
  local found=0 problems=() name
  for skill in "$REPO"/.claude/skills/*/; do
    found=$((found + 1))
    name="$(basename "$skill")"

    # Name the skill in every message: the loop covers all of them, so a bare
    # assertion failure leaves the reader grepping to find which one broke.
    if [ ! -f "$skill/SKILL.md" ]; then
      problems+=("$name: no SKILL.md")
      continue
    fi
    [ "$(head -1 "$skill/SKILL.md")" = "---" ] ||
      problems+=("$name: SKILL.md does not open with ---")
    grep -q '^description: ' "$skill/SKILL.md" ||
      problems+=("$name: no description in the frontmatter")
    # The directory name is the skill name; a mismatch is confusing at best.
    grep -q "^name: $name\$" "$skill/SKILL.md" ||
      problems+=("$name: frontmatter name does not match the directory")
  done

  if [ "${#problems[@]}" -gt 0 ]; then
    printf 'skill frontmatter problems:\n' >&2
    printf '  %s\n' "${problems[@]}" >&2
    false
  fi
  # nullglob is what makes an empty or moved .claude/skills produce zero
  # iterations rather than one literal `*/`, so this guard is the only thing
  # standing between "every skill is fine" and "there were no skills to check".
  [ "$found" -gt 0 ] || {
    echo "no skill directories found under $REPO/.claude/skills" >&2
    false
  }
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

@test "make unlink removes the Claude Code links too" {
  # install.sh runs dotfiles, config and claude (#306), so unlink has to undo
  # all three. Leaving the ~/.claude links behind turns them into dangling
  # links the moment the clone moves (#320).
  make -C "$REPO" dotfiles config claude HOME="$FAKE_HOME"
  [ -L "$FAKE_HOME/.claude/settings.json" ]

  run make -C "$REPO" unlink HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ ! -e "$FAKE_HOME/.claude/settings.json" ]
  [ ! -e "$FAKE_HOME/.claude/skills/tailscale-serve" ]
}

@test "make unlink leaves skills it did not install alone" {
  # ~/.claude/skills is shared. Only the links this repository made may go --
  # anything else there belongs to someone else, link or not.
  make -C "$REPO" claude HOME="$FAKE_HOME"
  mkdir -p "$FAKE_HOME/.claude/skills/someone-elses"
  touch "$FAKE_HOME/.claude/skills/someone-elses/SKILL.md"
  ln -s /tmp "$FAKE_HOME/.claude/skills/foreign-link"

  run make -C "$REPO" unlink HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]
  [ -f "$FAKE_HOME/.claude/skills/someone-elses/SKILL.md" ]
  [ -L "$FAKE_HOME/.claude/skills/foreign-link" ]
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

# --- install.sh --------------------------------------------------------------

@test "install.sh runs every symlink target the Makefile provides" {
  # install.sh calls itself one-command setup for a new machine, so a linking
  # target it does not call is a part of the setup that silently never happens
  # -- which is how ~/.claude went missing on new machines (#306). Derived from
  # the Makefile rather than listed here, so a target added later is covered.
  local missing=""
  local target
  for target in dotfiles config claude; do
    grep -qE "^${target}:" "$REPO/Makefile" || {
      echo "no such make target: $target"
      false
    }
    grep -q "make -C \"\$REPO_DIR\" $target" "$REPO/install.sh" || missing+=" $target"
  done
  [ -z "$missing" ] || {
    echo "targets install.sh never runs:$missing"
    false
  }
}

@test "the symlink targets together produce a usable ~/.claude" {
  # What install.sh does, in one go, against a throwaway HOME.
  run make -C "$REPO" dotfiles config claude HOME="$FAKE_HOME"
  [ "$status" -eq 0 ]

  assert_links_to "$FAKE_HOME/.claude/settings.json" "$REPO/configs/claude/settings.json"
  assert_links_to "$FAKE_HOME/.claude/skills/tailscale-serve" \
    "$REPO/.claude/skills/tailscale-serve"
  [ -f "$FAKE_HOME/.claude/skills/tailscale-serve/SKILL.md" ]
  # The rest of the run still happened.
  assert_links_to "$FAKE_HOME/.zshrc" "$REPO/.zshrc"
}
