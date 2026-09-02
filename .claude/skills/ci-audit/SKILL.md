---
name: ci-audit
description: Check that CI does what it says it does — that every test actually runs, that a hung job dies, that a green tick is not two runs of which one was red, and that the tools it installs by hand are in the project's manifest. Use when the user says "CIの設定を見直して", "CIが実際に何を実行しているか確認して", "audit the CI", "is CI actually running my tests", or after adding a test file or workflow job.
---

# ci-audit

CI failures announce themselves. CI *gaps* do not: a suite nobody runs, a job
with no timeout, a second run of the same commit that went red while the one you
looked at went green. Each of these looks exactly like success.

So audit the declaration against the behaviour. Read the workflows, then check
what they actually produced on a real commit.

## Method

Read every workflow file first, all of them, before checking anything. Half the
findings are relationships between two jobs, or between a job and a file
elsewhere in the repository, and you cannot see those one file at a time.

Then, for each check below: state what the configuration claims, then find the
evidence for what happens. **Evidence beats reading.** A workflow's own comment
is a claim like any other — one in this repository asserted that its
`concurrency` block stopped duplicate runs, and the duplicate runs were sitting
right there on the pull request.

## What to check

### 1. Tests that run nowhere

The worst defect available, because it is indistinguishable from passing.

- List the test files that exist. List what each job actually executes. Diff.
- **Any hand-written list of test files is the finding**, whether or not it is
  currently complete. Enumerating suites one step at a time meant a new
  `test/*.bats` here ran nowhere until someone remembered the step. Propose the
  glob, not the missing entry — fix the mechanism, not the instance.
- A glob needs a guard. `for f in test/*.bats` that matches nothing must fail
  loudly; silently iterating zero times is the same defect wearing a nicer hat.

### 2. Skips that look like passes

A skipped test reports success. Find every skip condition, then ask what makes
it true, and whether that thing is guaranteed on the runner **and** on a
developer's machine.

The pattern to look for: a suite that skips when a tool is absent, and a tool
that CI installs but the project's manifest does not. CI is green, the developer
is green, and neither of them ran the tests. Here, `fish-config.bats` skips
without `fish`; CI apt-installs `fish`; the `Brewfile` does not carry it — so a
fresh mac runs 12 tests that all quietly do nothing.

Prefer a skip keyed on something the test does not itself provide, and count the
skips in a real run rather than trusting the summary line.

### 3. Tools installed by hand

Anything a job installs for itself is something a new machine does not have.
Check each against the project's manifest — `Brewfile`, `package.json`,
`pyproject.toml`, a devcontainer, whatever the repo actually uses.

Check **every** installer, not the convenient one. A test here compared
`brew install` lines against the `Brewfile` and never looked at
`apt-get install`, which is where most of the tools were.

### 4. Hang resistance

A hung job is worse than a failing one: it burns the runner and reports nothing.
`timeout-minutes` is per-job and has no useful default.

- List the jobs **without** a timeout, not the ones with it.
- Then rank them by what they do. A job that sources shell config, starts a
  daemon, or runs a background process can inherit the runner's pipe and sit
  there long after the work finished. This repository lost 34 minutes that way,
  and today the job that runs `zsh -c "source ./.zshrc"` — the very thing that
  spawns the agent — is one of the four with no timeout, while the job that was
  actually bitten got one.

The finding is not "add timeouts everywhere". It is "these specific jobs can
hang and have nothing to stop them".

### 5. One commit, two runs

`on: [push, pull_request]` fires twice for a branch pushed to the same
repository. Two full sets of jobs, same names, same commit — and they can
disagree: a flaky test red in one set and green in the other leaves the pull
request showing both.

**A `concurrency` block does not necessarily fix this**, and assuming it does is
the trap. Grouping on `github.ref` puts the two events in *different* groups: a
push carries `refs/heads/<branch>`, the pull_request event carries
`refs/pull/<n>/merge`. Both survive. Verified here by counting the check runs on
a pull request — 8 jobs, 16 check runs, two runs of each.

So check it by counting, not by reading. If the duplication is real, the fixes
that work are narrowing the trigger (`push:` restricted to the default branch,
plus `pull_request:`) or keying the concurrency group on the head ref rather
than `github.ref`.

### 6. Drift

Cheaper checks, worth one pass each:

- action versions inconsistent between jobs or workflows (`checkout@v4` beside
  `checkout@v7`), and any unpinned `@main`
- a workflow whose `name:` describes something it outgrew — the file called
  "Check Zshrc syntax" that had grown to six jobs
- a step whose `name:` no longer matches its `run:`
- documentation that describes the CI: it is a claim about behaviour, and it
  rots exactly like the workflow comments do

### 7. Green on the runner only

Tests that pass in CI and fail on a laptop, or the reverse, are usually the
runner's environment leaking in:

- variables the runner sets itself — GitHub's Ubuntu images export
  `ANDROID_HOME`, which broke a test here that asserted it was unset
- locale: a runner's `LANG` is not a developer's
- preinstalled tools, absent elsewhere
- `$HOME` on a fresh runner has none of the dotfiles a real machine has

Where a test depends on any of these, say so and propose pinning it — clear the
variable with `env -u`, set the locale explicitly — rather than tracking the
runner.

## Report

One line per finding, in the form **declaration → reality**, with the file and
line for the declaration and the evidence for the reality:

```
lint.yml:8  says concurrency stops duplicate runs
            -> PR #346, one commit, 16 check runs: every job ran twice
```

Then the fix, preferring the structural one. Enumeration → glob. Hand install →
manifest. A convention nobody can forget beats a list somebody has to remember.

Sort by what can hide a failure, not by how easy each is to fix. A suite that
never runs outranks an inconsistent action version by a wide margin.

## Do not

- Rewrite the CI as you go. Report and let the user decide.
- Comment on job names, step order, or how the YAML is arranged. That is taste.
- Propose anything whose only benefit is speed. This is about what is broken or
  missed, and "make CI faster" is a different, larger conversation.
- Claim a duplicate run, a missing timeout, or a skipped suite without the
  evidence. Every one of these is checkable, so check it.
- Add a timeout to a job that cannot hang just to make the list uniform.
