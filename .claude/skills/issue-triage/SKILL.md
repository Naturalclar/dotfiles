---
name: issue-triage
description: List the open GitHub issues on a repository and put them in the order they should be worked on, with a one-line reason each — scored by Jev when it is available, by judgement when it is not. Use when the user says "issueの優先度をつけて", "どれから着手すべき", "open な issue を一覧して", "what should I work on next", "triage the issues", or asks which of several issues to start with.
---

# issue-triage

Turn a list of open issues into an order of work, with a reason attached to each
position. The deliverable is a decision aid, not an inventory: anyone can run
`gh issue list`.

The failure mode is a table where everything is important. If three issues are
"high", the ranking has told the reader nothing they did not already know.
Ordering means committing — something has to be last.

The ranking rests on a handful of shallow judgements per issue: is it broken or
proposed, does it fail silently, is it on a hot path, is it cheap. Those are
what Jev is for (see the `jev` skill), and when it can be asked, it is: the
scores are calibrated and repeatable, where a reading is neither. When it
cannot, the same judgements are made by reading, and the report says so.

## Steps

1. **Fetch what is open.**

   ```bash
   gh issue list --state open --limit 50 \
     --json number,title,labels,createdAt,updatedAt,body
   ```

   Or the GitHub MCP tools where `gh` is not available. If nothing is open, say
   so and stop; do not pad the list with ideas of your own.

2. **Decide whether Jev is asked.** Three things have to hold, in this order:

   ```sh
   command -v jev >/dev/null && [ -n "$JEV_API_KEY" ] && echo usable || echo not-usable
   gh repo view --json isPrivate -q .isPrivate
   ```

   - `jev` is on `PATH` and `JEV_API_KEY` is set. Never print the key.
   - **The issue text may leave the machine.** Jev is an external API and the
     whole body goes to it. A public repository's issues are already public;
     for a private one, ask the user before sending anything, and if they
     decline, go on without Jev. This skill runs on work repositories too, so
     that question is not skipped.

   Either way, say which it was in the report's first line. **Without Jev, do
   not write numbers that look like Jev's.** An uncalibrated 0.9 written by
   hand is exactly what the user was trying to avoid.

3. **Read each one only as far as ranking requires.** For every issue, answer:

   - Does it carry a reproduction, or would work start with "make it happen
     first"?
   - Is it one PR, or is it a discussion wearing an issue's clothes?
   - Is anything else waiting on it?
   - **Is it stuck on a decision only the user can make?** Those are not
     implementable work and must not be ranked among it.

   On a repository with dozens of issues, read the plausible top ten properly
   and say which ones you skimmed. A ranking of ten you understood beats a
   ranking of fifty you did not.

4. **Check the top candidates still reproduce.** Issues go stale — the bug gets
   fixed in passing, the file moves, the dependency changes. If the issue names
   a command, run it. Anything that no longer reproduces goes in the
   close-candidates list, and **you do not close it** — that is the user's call
   and they may know why it is still open.

   This is never Jev's question. Whether a problem still reproduces is not in
   the text, and a "may already be fixed" statement scored 0.06–0.13 on every
   issue tried, fixed or not. Run the command.

5. **Rank.** In descending weight:

   | Axis | What to look at |
   | --- | --- |
   | Kind of wrong | silently produces a wrong result > noisy but visible > cosmetic |
   | Frequency | shell startup, hooks, CI — paths that run constantly — versus a rarely-taken branch |
   | Blocking | is other work or another issue waiting on it |
   | Cost | a few lines, or a design decision |
   | Freshness | does it still reproduce at all |

   A cheap fix on a hot path outranks an expensive fix on a cold one, even when
   the expensive one is more interesting.

   **With Jev**, the first four axes are scored, one call per issue with every
   question in it. Write the issue's title and body to a file and run:

   ```sh
   jev --state-file "$issue" \
     --noul bug="This issue reports something that is currently broken, not a feature request or a proposal" \
     --noul unnoticed="When this problem happens, nothing is printed and no command fails, so it goes unnoticed" \
     --noul hot="The affected code runs on every shell start, in a hook, or in CI" \
     --noul blocking="Other issues or other work are waiting on this one" \
     --noul fewlines="The fix described in this issue changes only a few lines" \
     --noul needsdesign="Fixing this requires a design decision or a discussion before any code is written"
   ```

   Keep the statements as written; phrasing moves these scores a lot (the
   table below is what earned them). `hot` is worded for a dotfiles
   repository — for a library, replace it with the equivalent hot path ("a
   public API", "the request path") and say so.

   Jev narrows; it does not order. The scores are the evidence for each
   position, and the order and the reason line are still yours: two issues
   that depend on each other, or that tie, are things a per-issue score does
   not see. Use the scores like this, and keep the thresholds low — a missed
   candidate costs more than an extra one, because the user confirms the list:

   | Score | Use |
   | --- | --- |
   | `needsdesign` ≥ 0.6 | candidate for **Needs a decision**; read it and phrase the question |
   | `fewlines` ≥ 0.75 and `needsdesign` < 0.4 | candidate for **Quick wins** |
   | `bug` < 0.3 | a proposal or feature, ranked on `blocking` and cost, not on `unnoticed` |
   | anything 0.4–0.6 | Jev was unsure; say so in the reason line rather than rounding it |

   Measured on this repository's own issues, 2026-09-30, `jev-latest`
   (closed issues with known answers, plus one open proposal):

   | Issue | bug | unnoticed | hot | blocking | fewlines | needsdesign | Known answer |
   | --- | --- | --- | --- | --- | --- | --- | --- |
   | #354 Codex config (open proposal, waits on the user) | 0.13 | 0.53 | 0.23 | 0.58 | 0.10 | 0.80 | proposal, blocks stage 2, needs a decision |
   | #301 number printed on every shell start | 0.80 | 0.03 | 0.91 | 0.18 | 0.67 | 0.49 | visible, hot, one line |
   | #302 asdf sourced without a guard | 0.92 | 0.02 | 0.91 | 0.22 | 0.91 | 0.11 | visible, hot, a guard |
   | #304 `$DOTFILES` hardcoded to `/Users` | 0.87 | 0.08 | 0.82 | 0.22 | 0.85 | 0.27 | hot, a few lines |
   | #349 `concurrency` does not dedupe CI runs | 0.95 | 0.12 | 0.90 | 0.25 | 0.78 | 0.52 | CI, small change with a trade-off |
   | #350 lint job has no timeout | 0.94 | 0.55 | 0.92 | 0.21 | 0.84 | 0.16 | CI, one line |
   | #351 fish tests skip silently on a new mac | 0.87 | 0.46 | 0.68 | 0.27 | 0.39 | 0.42 | silent, test fix |

   What that run taught, so it is not re-learned: `bug` and `fewlines`
   separate cleanly; `unnoticed` is the weakest, sitting near 0.5 on the two
   silent cases (#350, #351) while putting the noisy ones (#301, #302) near
   0 — trust its lows more than its highs. The first wording tried,
   "produces a wrong result without any visible error", gave the *proposal*
   0.75; splitting it into `bug` and `unnoticed` fixed that. The same six
   statements in Japanese gave the same shape with less separation (`bug`
   0.70–0.90 instead of 0.80–0.95, `needsdesign` higher across the board), so
   the statements stay in English even when the issues are not.

6. **Report in four parts**, and keep it to one screen:

   - **First line** — `Jev jev-latest, N issues` or `Jev not asked: <reason>`
     (no key, no `jev`, private repository and not cleared). One line, so a
     reader knows which kind of ranking this is before reading it.
   - **Work order** — numbered, with issue number, title, and one line saying
     *why here*. Not a summary of the issue: the reason for the position. With
     Jev, the scores that put it there go on the same row:

     ```
     1. #350 lint job has no timeout   bug .94 / hot .92 / fewlines .84 / needsdesign .16
        — the job that spawns the agent, one line, nothing waits on it but it hangs CI
     ```
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
- Ask Jev to compare issues ("which of these first"). One statement about one
  issue per question; comparing several things at once is what the `jev` skill
  says it does badly. The order is yours.
- Ask Jev whether an issue still reproduces, or make up scores when it was not
  asked.
- Send a private repository's issues to Jev without asking.

## Constraints

- Every repository ranks differently. A dotfiles repo weighs "runs on every
  shell start" heavily; a library weighs "breaks a public API" heavily. Take the
  weighting from what the project is, and say which weighting you used when it
  is not obvious.
- Say when the list is thin or the issues are all small. "Three small ones, any
  order, here is the cheapest first" is a legitimate result.
