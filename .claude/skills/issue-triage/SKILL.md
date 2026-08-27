---
name: issue-triage
description: List the open GitHub issues on a repository and put them in the order they should be worked on, with a one-line reason each. Use when the user says "issueの優先度をつけて", "どれから着手すべき", "open な issue を一覧して", "what should I work on next", "triage the issues", or asks which of several issues to start with.
---

# issue-triage

Turn a list of open issues into an order of work, with a reason attached to each
position. The deliverable is a decision aid, not an inventory: anyone can run
`gh issue list`.

The failure mode is a table where everything is important. If three issues are
"high", the ranking has told the reader nothing they did not already know.
Ordering means committing — something has to be last.

## Steps

1. **Fetch what is open.**

   ```bash
   gh issue list --state open --limit 50 \
     --json number,title,labels,createdAt,updatedAt,body
   ```

   Or the GitHub MCP tools where `gh` is not available. If nothing is open, say
   so and stop; do not pad the list with ideas of your own.

2. **Read each one only as far as ranking requires.** For every issue, answer:

   - Does it carry a reproduction, or would work start with "make it happen
     first"?
   - Is it one PR, or is it a discussion wearing an issue's clothes?
   - Is anything else waiting on it?
   - **Is it stuck on a decision only the user can make?** Those are not
     implementable work and must not be ranked among it.

   On a repository with dozens of issues, read the plausible top ten properly
   and say which ones you skimmed. A ranking of ten you understood beats a
   ranking of fifty you did not.

3. **Check the top candidates still reproduce.** Issues go stale — the bug gets
   fixed in passing, the file moves, the dependency changes. If the issue names
   a command, run it. Anything that no longer reproduces goes in the
   close-candidates list, and **you do not close it** — that is the user's call
   and they may know why it is still open.

4. **Rank.** In descending weight:

   | Axis | What to look at |
   | --- | --- |
   | Kind of wrong | silently produces a wrong result > noisy but visible > cosmetic |
   | Frequency | shell startup, hooks, CI — paths that run constantly — versus a rarely-taken branch |
   | Blocking | is other work or another issue waiting on it |
   | Cost | a few lines, or a design decision |
   | Freshness | does it still reproduce at all |

   A cheap fix on a hot path outranks an expensive fix on a cold one, even when
   the expensive one is more interesting.

5. **Report in four parts**, and keep it to one screen:

   - **Work order** — numbered, with issue number, title, and one line saying
     *why here*. Not a summary of the issue: the reason for the position.
   - **Quick wins** — the ones that close in a few lines. Say which could
     sensibly share a single PR.
   - **Needs a decision** — one sentence each on *what to decide*, phrased as a
     question. These block on the user, not on effort.
   - **Close candidates** — no longer reproduce, with what you ran to find out.

## What makes a good reason line

Say what moves it up or down, not what the issue is about.

- Good: "every shell start on Linux; two lines to fix"
- Good: "blocks 312 — the test it needs does not exist yet"
- Bad: "important bug in the shell config" (that is a summary, and a grade)
- Bad: "high priority" (a label is not a reason)

If two issues genuinely tie, say so and pick one anyway, on cost.

## Do not

- Pad the ranking. Not everything is urgent; something is last.
- Close, label, comment on, or edit issues. **Read-only unless asked.**
- File new issues — that is `repo-survey`'s job. Something you notice while
  triaging gets mentioned in chat, not filed mid-task.
- Start the work. Ranking is the deliverable; the user picks what to begin.
- Rank an issue you did not read.
- Treat an issue's claims as fact when checking is cheap. A body written months
  ago describes the repository as it was.

## Constraints

- Every repository ranks differently. A dotfiles repo weighs "runs on every
  shell start" heavily; a library weighs "breaks a public API" heavily. Take the
  weighting from what the project is, and say which weighting you used when it
  is not obvious.
- Say when the list is thin or the issues are all small. "Three small ones, any
  order, here is the cheapest first" is a legitimate result.
