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
            sed -n 's#^ref: refs/heads/\([^[:space:]]*\).*#\1#p')
# -> the default branch. symbolic-ref is unset in a fresh clone, so the
#    ls-remote fallback is not optional.
#
#    [:space:], not \t: BSD sed (macOS) does not read \t inside brackets as a
#    tab, so [^\t] let the tab and the trailing "HEAD" through and $default came
#    out as "main<TAB>HEAD". GNU sed does read it, which is why Linux never
#    showed the bug.
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
# The branch you are about to (re)build. The check and the reset below both use
# this one variable, so they cannot look at different refs.
branch=<branch>

# An explicit refspec, so origin/<default> exists even where remote.origin.fetch
# is unset — a bare clone with worktrees, as ghq makes. There a plain
# `git fetch origin main` updates FETCH_HEAD only, and every origin/<default>
# below fails. Keep the braces: zsh reads "$default:r..." as a :r modifier.
git fetch origin "+${default}:refs/remotes/origin/${default}"
git log --oneline -1 "origin/${default}"    # what moved while you were away
git status --short                           # nothing uncommitted

if git rev-parse --verify --quiet "refs/heads/${branch}" >/dev/null; then
  t=$(git merge-tree --write-tree "origin/${default}" "refs/heads/${branch}" | head -1)
  if [ -n "$t" ] && [ "$t" = "$(git rev-parse "origin/${default}^{tree}")" ]; then
    git checkout -B "${branch}" "origin/${default}"
  else
    echo "stop: ${branch} holds changes that are not in origin/${default}"
  fi
else
  git checkout -B "${branch}" "origin/${default}"   # a new branch: nothing to lose
fi
```

If it prints `stop`, report it rather than resetting. The check and the reset
share one `if`, so running the block as written cannot reset first.

It gets three things right that `git log origin/<default>..HEAD` does not, and
each one it got wrong lost or blocked real work:

- **It looks at the branch being reset, not at HEAD.** `checkout -B <branch>`
  resets `<branch>`. Checking HEAD while standing on another branch answers for
  the wrong one, says "safe", and `<branch>`'s unmerged commits are gone.
- **A branch that does not exist yet is safe.** Starting fresh is the common
  case and loses nothing. `merge-tree` errors on a missing ref, which would read
  as "stop" every time, so existence is tested first.
- **It compares trees, not commit lists.** After a squash merge the branch's own
  commits never reach the default branch, so `git log origin/<default>..<branch>`
  lists them even when the work is fully merged — indistinguishable from work
  that is not. `merge-tree --write-tree` asks whether merging the branch would
  change the default branch at all: squash-merged, no change, safe (until the
  default branch edits those lines again — see below); unmerged, a change, stop.
  Merge-commit and rebase workflows come out right too.

It falls on the stopping side — never the losing side — in two cases:

- **The default branch has since changed the lines the branch touched**,
  whether by reverting them or just editing them again. Merging the old branch
  back would then conflict or undo that edit, so the tree changes and the check
  says stop, even though the branch's work was merged once. This is not rare: a
  branch left lying around after its squash merge starts stopping as soon as
  anyone edits the same lines.
- **git older than 2.38** has no `--write-tree`, so `t` comes back empty.

To tell the first case apart, check that **the head of the branch's merged PR is
the local tip**. If it is, everything on the branch reached the default branch
through that PR, and resetting is safe. A merged PR alone is not enough: commits
made locally after the merge move the tip, and those are what a reset would lose.

```sh
head=$(gh pr list --head "${branch}" --state merged --json headRefOid -q '.[0].headRefOid')
[ -n "$head" ] && [ "$head" = "$(git rev-parse "refs/heads/${branch}")" ] &&
  git checkout -B "${branch}" "origin/${default}"
```

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
