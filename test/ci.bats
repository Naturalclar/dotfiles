#!/usr/bin/env bats

# Tests for the workflow configuration itself.
#
# CI failures announce themselves; CI *gaps* do not. The one asserted here is
# duplicate runs: `on: [push, pull_request]` fires both events for a branch
# pushed to this repository, so every commit on a PR started two full sets of
# jobs. That is not merely wasteful -- the same job name can be green in one set
# and red in the other, and then "CI is green" depends on which one you looked
# at (#324, #349).
#
# The `concurrency` block does not prevent it, which is what made this worth a
# test rather than a comment: it groups on github.ref, and that is
# refs/heads/<branch> for a push but refs/pull/<n>/merge for a pull_request, so
# the two events never share a group. The configuration read as if it were
# handled while the pull request was showing 16 check runs for 8 jobs.
#
# These assert the shape of the configuration, not the behaviour -- the run
# count can only be seen on GitHub. Count the check runs on a pull request if
# you want the real thing.
#
# Run locally with `bats test/ci.bats` (brew install bats-core).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

# The `on:` block, from the `on:` line to the next key at column 0. Everything
# here works on that slice rather than on the whole file, so a `push:` under
# some other key -- a step named "push", a path filter -- cannot be mistaken for
# a trigger.
on_block() {
  awk '
    /^on:/            { inblock = 1; print; next }
    inblock && /^[^ ]/ { inblock = 0 }
    inblock           { print }
  ' "$1"
}

# The `push:` subsection of that block, from `  push:` to the next key at the
# same indentation. `branches:` has to be found in here specifically: a
# `pull_request:` with its own branch filter would otherwise make an
# unrestricted `push:` look restricted.
push_subsection() {
  on_block "$1" | awk '
    /^  push:/          { inpush = 1; print; next }
    inpush && /^  [^ ]/ { inpush = 0 }
    inpush              { print }
  '
}

# Every job name in a workflow, one per line. Jobs are the keys two spaces in
# under `jobs:`, so the slice starts there and ends at the next key at column 0.
job_names() {
  awk '
    /^jobs:/            { injobs = 1; next }
    injobs && /^[^ ]/   { injobs = 0 }
    injobs && /^  [A-Za-z0-9_-]+:[[:space:]]*$/ {
      name = $1; sub(/:$/, "", name); print name
    }
  ' "$1"
}

# The body of one job: from its key to the next key at the same indentation.
job_block() {
  awk -v want="  $2:" '
    $0 == want         { injob = 1; print; next }
    injob && /^  [^ ]/ { injob = 0 }
    injob              { print }
  ' "$1"
}

@test "every job has a timeout-minutes" {
  # GitHub's default is 360 minutes, so a job with no timeout does not "die
  # eventually" -- it holds a runner for six hours. A job here starts an
  # ssh-agent that outlives the shell that started it, which is how a 34-minute
  # hang happened, and the fix at the time was applied only to the job that had
  # been bitten. `lint` next door did the same thing and had nothing (#350).
  #
  # Asserted for every job rather than for that one, because the next job added
  # is the one nobody will think about.
  shopt -s nullglob
  local missing="" workflow job
  for workflow in "$REPO"/.github/workflows/*.yml; do
    while IFS= read -r job; do
      job_block "$workflow" "$job" | grep -qE '^    timeout-minutes:[[:space:]]*[0-9]+' ||
        missing+=" $(basename "$workflow"):$job"
    done < <(job_names "$workflow")
  done

  [ -z "$missing" ] || {
    echo "jobs with no timeout-minutes:$missing"
    false
  }
}

@test "there is at least one workflow to check" {
  # The globs below iterate nothing if the directory moves, and a loop that
  # runs zero times passes every assertion in it.
  shopt -s nullglob
  local workflows=("$REPO"/.github/workflows/*.yml)
  [ "${#workflows[@]}" -gt 0 ] || {
    echo "no workflows found under $REPO/.github/workflows"
    false
  }
}

@test "no workflow runs twice for the same commit on a pull request" {
  shopt -s nullglob
  local offenders=""
  local wf block name

  for wf in "$REPO"/.github/workflows/*.yml; do
    name="$(basename "$wf")"
    block="$(on_block "$wf")"

    grep -q 'pull_request' <<<"$block" || continue
    grep -q 'push' <<<"$block" || continue

    # Both events fire. The push has to be limited to specific branches, or
    # every PR commit gets two sets of jobs.
    grep -q 'branches:' <<<"$(push_subsection "$wf")" ||
      offenders+=" $name"
  done

  [ -z "$offenders" ] || {
    echo "workflows triggering on both an unrestricted push and pull_request:$offenders"
    echo "each PR commit runs every job twice; restrict push to the default branch"
    false
  }
}

@test "the default branch is still covered after a merge" {
  # The flip side of the fix above: narrowing the push trigger too far would
  # leave master with no CI at all, and nothing else would notice.
  shopt -s nullglob
  local missing=""
  local wf name

  for wf in "$REPO"/.github/workflows/*.yml; do
    name="$(basename "$wf")"
    grep -q 'push' <<<"$(on_block "$wf")" || continue
    grep -q 'master' <<<"$(push_subsection "$wf")" || missing+=" $name"
  done

  [ -z "$missing" ] || {
    echo "workflows whose push trigger excludes the default branch:$missing"
    false
  }
}

@test "the concurrency comment does not claim to deduplicate the two events" {
  # The reason this defect survived: both workflows carried a comment saying
  # the concurrency block stopped the duplicate runs. A wrong comment is worse
  # than none, because it answers the question before anyone asks it.
  shopt -s nullglob
  local wf
  for wf in "$REPO"/.github/workflows/*.yml; do
    grep -q 'starts two identical sets of runs' "$wf" && {
      echo "$(basename "$wf") still claims concurrency prevents the duplicate runs"
      false
    }
  done
  true
}
