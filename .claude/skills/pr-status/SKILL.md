---
name: pr-status
description: List the open pull requests on a repository and report what each one is actually waiting on — CI, conflicts, review, or nobody — with the next action for each. Use when the user says "今上がってるPRの状態を教えて", "PRの状況", "open な PR を確認して", "check my PRs", "what is blocking these PRs", or asks why a PR is not merging.
---

# pr-status

For each open pull request, name the one thing keeping it from merging, and the
next action that would move it. The list is the easy half; the state of each PR
is the deliverable.

The failure mode is a status board where every row says "CI red" or "needs
attention". That is the question restated, not answered. A row is finished when
it says what to do next.

## Steps

1. **Fetch what is open.**

   ```bash
   gh pr list --state open --json number,title,isDraft,mergeable,reviewDecision,headRefName,updatedAt
   ```

   Or the GitHub MCP tools where `gh` is not installed — cloud sessions have no
   `gh`. If nothing is open, say so and stop.

2. **For each PR, find the one thing blocking it.** In the order that decides
   the answer fastest:

   - **CI** — the conclusion of *every* check, not one run's worth (see below)
   - **Mergeability** — conflicts, or behind the base branch
   - **Review** — changes requested, or comments nobody answered
   - **Draft** — blocked on its own author by definition
   - **Age** — last update, and whether a later PR has overtaken it

3. **When CI is red, read what failed.** Stopping at "CI red" hands back the
   question. Pull the failing job's log tail (`gh run view --log-failed`, or the
   MCP job-log tool) and place it:

   | Class | How to tell | Next action |
   | --- | --- | --- |
   | This PR broke it | base is green | fix it |
   | Already broken | base fails the same way | not this PR's problem; worth its own issue |
   | Environment-dependent | passes locally, fails on the runner, or the reverse — locale, a tool the image lacks, a variable the runner sets | make the test independent of it |
   | Hung, not failed | one job still `in_progress` long after its siblings finished | it is stuck, not slow — usually an orphan process holding the step's pipe open |

   The last two are the ones that get misread. **Slow and stuck look identical
   in a status field**; the tell is the gap between that job's runtime and its
   siblings'. A job at ten minutes while the rest finished in thirty seconds is
   not slow.

   A failure that reproduces on the base branch is not this PR's to fix. Say so
   in the row rather than parking the PR.

4. **Report, grouped by whose move it is.** One line per PR: number, title,
   state, next action.

   - **Ready to merge** — checks green, no conflict, no outstanding review
   - **Your move** — red CI, conflict, an unanswered comment; each with the one
     action that unblocks it
   - **Their move** — waiting on a reviewer or on something outside the repo
   - **Drifting** — stale, superseded, or a draft nobody is working on; say if
     closing looks right, and let the user decide

## Do not judge "green" from one run

Many repositories fire the same workflow for both `push` and `pull_request`, so
a single PR carries two sets of the same jobs. The consequence is easy to miss:
**the same job can be green in one run and red in the other on the same commit**
— a flaky test, a cancelled run, a timeout. Judge on the conclusions of all
checks, and when two runs of one job disagree, say so rather than picking the
convenient one.

Equally: a check still queued is not a pass. "15 of 16 green, one still running"
is the honest answer, and often the interesting one.

## Do not

- Merge, close, push, or comment. **Read-only unless asked.**
- Fix anything. Reporting the state is the job; the user decides what to touch.
- Stop at "CI red" — a row without a cause is unfinished.
- Call a PR ready when a check is still running.
- Pad the report. If four of five PRs need nothing, the useful output is one
  line about the fifth.

## Constraints

- Report what you checked. "Read the failing bats job" and "saw the check name"
  are different levels of confidence, and the reader cannot tell them apart
  unless you say.
- Where a PR belongs to someone else, keep to the state and drop the advice
  about how to fix their code.
