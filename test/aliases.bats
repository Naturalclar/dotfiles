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

# .zshrc is only a loader now; the definitions live in .zsh/*.zsh.
ZSH_PARTS=("$BATS_TEST_DIRNAME"/../.zsh/*.zsh)
PS_ALIASES="$BATS_TEST_DIRNAME/../windows/alias.ps1"
PS_FUNCS="$BATS_TEST_DIRNAME/../windows/functions.ps1"
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
#   wf        zsh aliases fzf-workspace; fish inlines it, sharing the fzf
#             preview string verbatim since fzf runs it with sh either way
#   run-script  same selector, same lockfile order; rewritten in fish syntax
KNOWN_EQUIVALENT="gbd gcod gpcb n run-script rundroid wf ws"

# Same idea for PowerShell. Only the one-liners are comparable at all; anything
# multi-line is rewritten in PowerShell and is not checked here.
#
#   gpcbf, gplcb  command substitution syntax, and zsh's git_current_branch is
#                 spelled get_current_branch on the PowerShell side
#   open          zsh runs explorer.exe under WSL; PowerShell has Invoke-Item
#   gpcb, gpcbf, gplcb  command substitution syntax; zsh's git_current_branch
#                       is spelled get_current_branch here
#   ws                  zsh calls peco-workspace; PowerShell inlines the same
#                       one-liner
#   get_default_branch, get_default_branch_fast
#                       rewritten with Select-String and -replace, since awk and
#                       sed are not on Windows
#   open                zsh runs explorer.exe under WSL; PowerShell Invoke-Item
#
# Anything whose PowerShell side is longer than one command is not extracted at
# all and so cannot be listed here -- gdm, wf, run-script and switch-worktree
# are real rewrites, described in the comments where they are defined.
PS_KNOWN_EQUIVALENT="get_default_branch get_default_branch_fast gpcb gpcbf gplcb open ws"

# Print "name<TAB>definition" for every `alias name=...` line in $1. The
# surrounding quotes and any trailing comment are stripped so that the two
# shells can be compared as plain text regardless of quoting style.
alias_defs() {
  grep -hE "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$@" |
    sed -E "s/^[[:space:]]*alias[[:space:]]+//" |
    sed -E "s/^([A-Za-z0-9_.:-]+)=/\1\t/" |
    sed -E "s/\t['\"]/\t/; s/['\"][[:space:]]*(#.*)?\$//"
}

# Every name a shell puts in front of the user: aliases plus functions. The
# alias-only comparison misses whatever the other shell implements as a
# function, which is how `ws` came to mean two different things.
zsh_names() {
  {
    grep -hoE "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "${ZSH_PARTS[@]}" | sed -E 's/^[[:space:]]*alias //; s/=$//'
    grep -hoE "^[A-Za-z_][A-Za-z0-9_-]*\(\)" "${ZSH_PARTS[@]}" | sed 's/()//'
    grep -hoE "^function [A-Za-z_][A-Za-z0-9_-]*" "${ZSH_PARTS[@]}" | sed 's/^function //'
  } | sort -u
}

fish_names() {
  {
    grep -hoE "^[[:space:]]*alias [A-Za-z0-9_.:-]+=" "$FISH_DIR"/conf.d/*.fish | sed -E 's/^[[:space:]]*alias //; s/=$//'
    grep -hoE "^function [A-Za-z0-9_.:-]+" "$FISH_DIR"/conf.d/*.fish | sed 's/^function //'
    basename -s .fish "$FISH_DIR"/functions/*.fish
  } | sort -u
}

# name<TAB>definition for the PowerShell one-liners: single-line functions with
# the trailing $args forwarding removed, plus Set-Alias entries that take no
# arguments. Set-Alias cannot carry arguments -- binding it to "pnpm build"
# produces an alias for a command of that name, which does not exist -- so an
# argument-carrying entry is a bug rather than something to compare.
ps_defs() {
  {
    grep -hoE "^Function [A-Za-z0-9_.-]+ \{ [^}]+ \}" "$PS_ALIASES" "$PS_FUNCS" |
      sed -E 's/^Function ([A-Za-z0-9_.-]+) \{ (.*) \}$/\1\t\2/'
    # Multi-line functions whose body is a single command. Most of them are --
    # `gst { git status }` written across three lines -- and skipping those is
    # how `gco` and `gpull` drifted unnoticed. Anything longer is a genuine
    # PowerShell rewrite and belongs in PS_KNOWN_EQUIVALENT instead.
    awk '
      /^Function [A-Za-z0-9_.-]+ \{$/ { name = $2; n = 0; next }
      name && /^\}$/ { if (n == 1) print name "\t" body; name = ""; next }
      name && !/^[[:space:]]*#/ && !/^[[:space:]]*$/ {
        line = $0
        sub(/^[[:space:]]+/, "", line); sub(/[[:space:]]+$/, "", line)
        body = line; n++
      }
    ' "$PS_ALIASES" "$PS_FUNCS"
    grep -hoE "^Set-Alias -Name [A-Za-z0-9_.-]+ -Value [A-Za-z0-9_.-]+$" "$PS_ALIASES" |
      sed -E 's/^Set-Alias -Name ([A-Za-z0-9_.-]+) -Value (.*)$/\1\t\2/'
  } | sed -E 's/[[:space:]]*\$args[[:space:]]*$//' | sort -u
}

defined_as_alias() {
  case "$1" in
    zsh) grep -qhE "^[[:space:]]*alias $2=" "${ZSH_PARTS[@]}" ;;
    fish) grep -qhE "^[[:space:]]*alias $2=" "$FISH_DIR"/conf.d/*.fish ;;
  esac
}

# Guard against the extraction silently matching nothing, which would make
# every other check in this file pass for the wrong reason.
@test "alias extraction finds the aliases in both shells" {
  [ "$(alias_defs "${ZSH_PARTS[@]}" | wc -l)" -gt 50 ]
  [ "$(alias_defs "$FISH_ALIASES" | wc -l)" -gt 30 ]
  [[ "$(alias_defs "${ZSH_PARTS[@]}")" == *"gst"$'\t'"git status"* ]]
  [[ "$(alias_defs "$FISH_ALIASES")" == *"gst"$'\t'"git status"* ]]
}

@test "no alias is defined more than once across the zsh config" {
  dupes="$(alias_defs "${ZSH_PARTS[@]}" | cut -f1 | sort | uniq -d)"
  if [ -n "$dupes" ]; then
    echo "these aliases are defined twice across .zsh/*.zsh; the later one wins:"
    echo "$dupes"
    false
  fi
}

@test "an alias defined in both shells means the same thing" {
  conflicts="$(join -t$'\t' \
    <(alias_defs "${ZSH_PARTS[@]}" | sort -u -t$'\t' -k1,1) \
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

# --- PowerShell ---------------------------------------------------------------

@test "no Set-Alias carries arguments" {
  # Set-Alias binds a name to one command. Given "pnpm build" it makes an alias
  # for a command called "pnpm build", which fails the moment it is run.
  bad="$(grep -nE '^Set-Alias .* -Value "[^"]* ' "$PS_ALIASES" || true)"
  if [ -n "$bad" ]; then
    echo "these aliases can never run; make them functions instead:"
    echo "$bad"
    false
  fi
}

@test "no Set-Alias expands a subshell at load time" {
  # $( ) inside a double-quoted value runs when the profile loads, freezing the
  # result -- which for gpcbf meant force-pushing to whatever branch was checked
  # out when the shell opened.
  bad="$(grep -nE '^Set-Alias .*\$\(' "$PS_ALIASES" || true)"
  if [ -n "$bad" ]; then
    echo "these evaluate at profile load rather than when run:"
    echo "$bad"
    false
  fi
}

@test "PowerShell definition extraction finds the one-liners" {
  [ "$(ps_defs | wc -l)" -gt 30 ]
  ps_defs | grep -qx "$(printf 'gbr\tgit branch')"
}

@test "a name defined in zsh and PowerShell means the same thing" {
  conflicts="$(join -t$'\t' \
    <(alias_defs "${ZSH_PARTS[@]}" | sort -u -t$'\t' -k1,1) \
    <(ps_defs | sort -u -t$'\t' -k1,1) |
    awk -F'\t' -v known=" $PS_KNOWN_EQUIVALENT " \
      '$2 != $3 && index(known, " " $1 " ") == 0 { printf "%s\n  zsh: %s\n  ps:  %s\n", $1, $2, $3 }')"
  if [ -n "$conflicts" ]; then
    echo "these disagree between zsh and PowerShell (.zsh/*.zsh is the source of truth):"
    echo "$conflicts"
    false
  fi
}

@test "PS_KNOWN_EQUIVALENT has no stale entries" {
  # An entry earns its place only while the two sides actually differ. Once they
  # agree, keeping it here would quietly stop checking a name that is fine.
  paired="$(join -t$'\t' \
    <(alias_defs "${ZSH_PARTS[@]}" | sort -u -t$'\t' -k1,1) \
    <(ps_defs | sort -u -t$'\t' -k1,1))"

  stale=""
  for name in $PS_KNOWN_EQUIVALENT; do
    row="$(echo "$paired" | awk -F'\t' -v n="$name" '$1 == n')"
    if [ -z "$row" ]; then
      stale="$stale $name(not-compared)"
    elif [ "$(echo "$row" | cut -f2)" = "$(echo "$row" | cut -f3)" ]; then
      stale="$stale $name(now-agrees)"
    fi
  done

  if [ -n "$stale" ]; then
    echo "PS_KNOWN_EQUIVALENT entries that are no longer needed:$stale"
    false
  fi
}
