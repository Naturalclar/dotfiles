#!/usr/bin/env bats

# Guards the rule documented in README.md: .zshrc is the source of truth, and a
# name that exists in both shells must behave identically. Nothing here asks
# fish to carry every zsh alias -- only that the ones it does carry agree, so
# `up` never means one thing in zsh and another in fish again.
#
# A name can be an alias in one shell and a function in the other, in which case
# there is nothing to compare textually -- fish and zsh do not share a syntax.
# Those pairs have to be checked by hand and recorded in KNOWN_EQUIVALENT below,
# so a *new* one cannot appear without someone looking at it.
#
# Run locally with `bats test/aliases.bats` (brew install bats-core).

ZSHRC="$BATS_TEST_DIRNAME/../.zshrc"
FISH_DIR="$BATS_TEST_DIRNAME/../.config/fish"
FISH_ALIASES="$FISH_DIR/conf.d/aliases.fish"

# Verified by hand to behave the same in both shells despite being written
# differently. Do not add a name here without checking it.
#
#   gbd       git branch -d $(git branch | pf)      -- command substitution syntax
#   gcod      git switch $(get_default_branch)      -- command substitution syntax
#   gpcb      git push origin $(git_current_branch) -- command substitution syntax
#   rundroid  $EMULATOR -avd "$(listdroid | peco)"  -- command substitution syntax
#   ws        zsh calls peco-workspace; fish inlines the same one-liner
#   n         zsh calls list(); fish inlines it plus a trailing-space strip,
#             because fish's (...) does not word-split the way zsh's $(...) does
KNOWN_EQUIVALENT="gbd gcod gpcb n rundroid ws"

# Print "name<TAB>definition" for every `alias name=...` line in $1. The
# surrounding quotes and any trailing comment are stripped so that the two
# shells can be compared as plain text regardless of quoting style.
alias_defs() {
  grep -E "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$1" |
    sed -E "s/^[[:space:]]*alias[[:space:]]+//" |
    sed -E "s/^([A-Za-z0-9_.:-]+)=/\1\t/" |
    sed -E "s/\t['\"]/\t/; s/['\"][[:space:]]*(#.*)?\$//"
}

# Every name a shell puts in front of the user: aliases plus functions. The
# alias-only comparison misses whatever the other shell implements as a
# function, which is how `ws` came to mean two different things.
zsh_names() {
  {
    grep -oE "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$ZSHRC" | sed -E 's/^[[:space:]]*alias //; s/=$//'
    grep -oE "^[A-Za-z_][A-Za-z0-9_-]*\(\)" "$ZSHRC" | sed 's/()//'
    grep -oE "^function [A-Za-z_][A-Za-z0-9_-]*" "$ZSHRC" | sed 's/^function //'
  } | sort -u
}

fish_names() {
  {
    grep -hoE "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$FISH_DIR"/conf.d/*.fish | sed -E 's/^[[:space:]]*alias //; s/=$//'
    grep -hoE "^function [A-Za-z0-9_.:-]+" "$FISH_DIR"/conf.d/*.fish | sed 's/^function //'
    basename -s .fish "$FISH_DIR"/functions/*.fish
  } | sort -u
}

defined_as_alias() {
  case "$1" in
    zsh) grep -qE "^[[:space:]]*alias $2=" "$ZSHRC" ;;
    fish) grep -qhE "^[[:space:]]*alias $2=" "$FISH_DIR"/conf.d/*.fish ;;
  esac
}

# Guard against the extraction silently matching nothing, which would make
# every other check in this file pass for the wrong reason.
@test "alias extraction finds the aliases in both shells" {
  [ "$(alias_defs "$ZSHRC" | wc -l)" -gt 50 ]
  [ "$(alias_defs "$FISH_ALIASES" | wc -l)" -gt 30 ]
  [[ "$(alias_defs "$ZSHRC")" == *"gst"$'\t'"git status"* ]]
  [[ "$(alias_defs "$FISH_ALIASES")" == *"gst"$'\t'"git status"* ]]
}

@test "no alias is defined more than once in .zshrc" {
  dupes="$(alias_defs "$ZSHRC" | cut -f1 | sort | uniq -d)"
  if [ -n "$dupes" ]; then
    echo "these aliases are defined twice; the later one silently wins:"
    echo "$dupes"
    false
  fi
}

@test "an alias defined in both shells means the same thing" {
  conflicts="$(join -t$'\t' \
    <(alias_defs "$ZSHRC" | sort -u -t$'\t' -k1,1) \
    <(alias_defs "$FISH_ALIASES" | sort -u -t$'\t' -k1,1) |
    awk -F'\t' '$2 != $3 { printf "%s\n  zsh:  %s\n  fish: %s\n", $1, $2, $3 }')"
  if [ -n "$conflicts" ]; then
    echo "these aliases disagree between the shells (.zshrc is the source of truth):"
    echo "$conflicts"
    false
  fi
}

@test "name extraction covers functions as well as aliases" {
  # Without this the checks below can pass by finding nothing at all.
  [ "$(zsh_names | wc -l)" -gt 100 ]
  [ "$(fish_names | wc -l)" -gt 50 ]
  # A function in each shell, which the alias-only extraction would miss.
  zsh_names | grep -qx "run-script"
  fish_names | grep -qx "gcod"
}

@test "a name defined in both shells is comparable or known-equivalent" {
  unreviewed=""
  for name in $(comm -12 <(zsh_names) <(fish_names)); do
    # Both aliases: the test above already compares them textually.
    if defined_as_alias zsh "$name" && defined_as_alias fish "$name"; then
      continue
    fi
    case " $KNOWN_EQUIVALENT " in
      *" $name "*) continue ;;
    esac
    unreviewed="$unreviewed $name"
  done

  if [ -n "$unreviewed" ]; then
    echo "these names exist in both shells but are implemented differently, so"
    echo "they cannot be compared as text. Check that each behaves the same and"
    echo "add it to KNOWN_EQUIVALENT with a note, or make both sides aliases:"
    for name in $unreviewed; do echo "  $name"; done
    false
  fi
}

@test "KNOWN_EQUIVALENT has no stale entries" {
  # Keeps the list from silently outliving the names it excuses.
  shared="$(comm -12 <(zsh_names) <(fish_names))"
  stale=""
  for name in $KNOWN_EQUIVALENT; do
    echo "$shared" | grep -qx "$name" || stale="$stale $name"
  done
  if [ -n "$stale" ]; then
    echo "KNOWN_EQUIVALENT lists names that are no longer in both shells:$stale"
    false
  fi
}
