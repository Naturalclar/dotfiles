#!/usr/bin/env bats

# Guards the rule documented in README.md: .zshrc is the source of truth, and an
# alias that exists in both shells must behave identically. Nothing here asks
# fish to carry every zsh alias -- only that the ones it does carry agree, so
# `up` never means one thing in zsh and another in fish again.
#
# Run locally with `bats test/aliases.bats` (brew install bats-core).

ZSHRC="$BATS_TEST_DIRNAME/../.zshrc"
FISH_ALIASES="$BATS_TEST_DIRNAME/../.config/fish/conf.d/aliases.fish"

# Print "name<TAB>definition" for every `alias name=...` line in $1. The
# surrounding quotes and any trailing comment are stripped so that the two
# shells can be compared as plain text regardless of quoting style.
alias_defs() {
  grep -E "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$1" |
    sed -E "s/^[[:space:]]*alias[[:space:]]+//" |
    sed -E "s/^([A-Za-z0-9_.:-]+)=/\1\t/" |
    sed -E "s/\t['\"]/\t/; s/['\"][[:space:]]*(#.*)?\$//"
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
