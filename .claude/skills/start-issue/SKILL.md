---
name: start-issue
description: Before implementing an existing GitHub issue, re-check that it is still open, still accurate, and nobody else is already on it. Use when the user says "#NNN に着手して", "NNN対応して", "NNNやって", "start on issue NNN", or "implement #NNN" — run this before reading or writing any code. Not for filing new issues or answering questions.
---

# start-issue

Run this before touching code for an existing issue. It answers one question:
**is this still worth starting?**

The state you remember is the state you last looked at, and other sessions
commit while you are not watching. In this repository a session began building a
`file-split-survey` skill that another session had already merged an hour
earlier; elsewhere a session implemented an issue end-to-end that had been closed
five days before. Both cost a full implementation.

## 0. Derive the repository and its default branch

Never hardcode either. A hardcoded owner/repo is the worst failure available
here: the duplicate search runs against the wrong repository, returns zero
results, and reports "no duplicates" **without erroring**.

```sh
git remote get-url origin |
  sed -E 's#^[^@]*@[^:/]+[:/]##; s#^[a-z]+://[^/]+/##; s#\.git$##'
# -> owner/repo   (handles git@, https://, ssh://, with or without .git)

default=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null |
            sed 's#^origin/##')
[ -n "$default" ] || default=$(git ls-remote --symref origin HEAD |
            sed -n 's#^ref: refs/heads/\([^\t]*\).*#\1#p')
# -> the default branch. symbolic-ref is unset in a fresh clone, so the
#    ls-remote fallback is not optional.
#
#    Test for emptiness rather than chaining with `||`: a pipeline exits with
#    the status of its last command, so `symbolic-ref | sed || fallback` takes
#    sed's exit 0 and never falls back -- it just yields an empty branch name,
#    and every command after it operates on `origin/`.
```

**Print both before using them.** If the derived repository is not the one the
user means, that has to be visible, not silent.

## 1. Sync, then rebuild the working branch

```sh
git fetch origin "$default"
git log --oneline -1 "origin/$default"    # what moved while you were away
git status --short                         # nothing uncommitted
git checkout -B "$branch" "origin/$default"
```

Before resetting, check the branch carries nothing unmerged:

```sh
git log --oneline "origin/$default..HEAD"   # empty -> safe to reset
```

Compare against the **default branch**, not against the branch's own remote ref.
After a squash merge the remote feature branch keeps the pre-merge commits, so a
comparison against it reports differences for work that is fully merged — a false
"stop, you have unmerged commits" every time.

If that list is not empty, stop and report it rather than resetting.

## 2. Read the issue as it is now

`mcp__github__issue_read` (method `get`):

- **`state: closed`** → do not start. Report it, and name the PR that closed it
  from `closed_by_pull_requests`.
- **`closed_by_pull_requests` holds an open PR** → someone is already on it.
  Report the PR instead of starting. The name says `closed_by`, but the field
  lists any PR that would close the issue, open ones included — checked against
  an open issue whose PR was still in review:

  ```json
  "closed_by_pull_requests": {"total_count": 1,
    "references": [{"number": 345, "state": "OPEN", ...}]}
  ```
- **Re-read the body.** It describes the repository as it was when written. Check
  the files, functions and line numbers it names still exist. Where it has
  drifted, adjust the plan and say so in the final report rather than
  implementing against a repository that no longer exists.

## 3. Check nobody else started

- `issue_read` (method `get_comments`) — look for a recent 🚧 marker. Treat one
  from the last day as someone working now; older, with no open PR, as
  abandoned.
- `mcp__github__search_pull_requests` with `repo:<derived>` `is:open` and the
  issue number, for a PR referencing it whose body says so.

Both of these are advisory. The real backstop is step 5.

## 4. Say you are starting

This is the one write in the set — every other survey skill here is read-only —
so it is worth being deliberate: comment only on a repository the user
maintains, and skip it when they have said not to.

```
🚧 このIssueに着手します。
```

A declaration is a signal, not a lock. Two sessions can pass this check within
seconds of each other.

## 5. Check again before opening the PR

Cheap, and it catches the case this skill exists for.

- If the work took a while, redo steps 1–2. Fetch, and look for your own issue
  number in the default branch's log.
- After creating the PR, read its `mergeable_state`. On `dirty`, run
  `git log HEAD..origin/<default>` **before** resolving anything: if a commit
  there already closed your issue, the fix is to close the PR, not to merge.

## Do not

- Hardcode an owner, a repository, or a branch name.
- Reset a branch that carries unmerged work.
- Start on a closed issue. If the user wants more on top of it, propose a new
  issue rather than reopening.
- Run this for a new issue, a question, or a change with no issue behind it.
- Treat the 🚧 comment as a lock, or leave one on a repository you are only
  visiting.
