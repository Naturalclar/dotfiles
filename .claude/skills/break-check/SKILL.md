---
name: break-check
description: Prove a test actually fails when the behaviour it covers is broken, by deliberately breaking that behaviour and watching it fail. Use after writing or changing a test, when the user says "テストが効いているか確認して", "壊して確認して", "prove the test catches it", "verify this test fails without the fix", or before claiming a regression is covered.
---

# break-check

A test that passes whether or not the code is right has told you nothing. After
writing one, break the behaviour it covers and watch it fail. Only then is the
regression actually covered.

This is cheap — seconds per test — and it is the step that finds tests which
assert nothing. Skipping it is how a suite grows green and hollow at the same
time.

## Method

1. **Start green.** Run the test and see it pass. Note whether it *ran*: a test
   reported as skipped is not passing, and a skip is the most common way a check
   turns hollow without anyone noticing.

2. **Save a copy of every file you are about to edit**, somewhere outside the
   repository. Restore from that copy afterwards — **not** with
   `git checkout -- <file>`, which throws away uncommitted work in that file
   along with the break. That mistake costs whatever else you had in there.

3. **Break the thing the test names, and only that.** One break per claim. The
   edit should look like something a future change would plausibly do — remove a
   guard, drop a line, flip a comparison, revert to the previous approach — not
   a nonsense edit that no one would make.

4. **Run that test alone** and read the failure. Two things matter:
   - it fails, and
   - **the message says what went wrong**. A failure that only prints
     `` `false' failed `` leaves the next reader guessing; add the detail to the
     assertion while you are here.

5. **Restore from the copy, run again, confirm green.** Never leave a break
   behind, and never trust that you restored correctly without re-running.

6. **Report the matrix** — the break and its result, one row each. That is the
   evidence the coverage is real, and it belongs in the commit message or PR
   body.

## What the results mean

| What happened | What it means |
| --- | --- |
| Fails, with a message naming the problem | The coverage is real. Done. |
| **Passes anyway** | The test asserts nothing about this behaviour. Rewrite it or drop it — a hollow test is worse than none, because it buys false confidence. |
| **Skips instead of failing** | A skip condition is keyed on the thing you just broke, so removing the behaviour removes the check with it. Key the skip on something independent. |
| Fails for an unrelated reason | The harness broke, not the behaviour. An exit 127 usually means the test could not launch the thing it was testing at all — that proves nothing; fix the harness and repeat. |
| Only a *combination* of breaks fails it | The test pins the observable contract rather than the mechanism. That is often fine, but say so — do not claim the single break is covered when it is not. |

The middle three are the point of doing this at all. Each of them looks
identical to a healthy test until you try.

## Choosing the break

Aim at the claim in the test's own name.

- "no macOS-only path is exported on Linux" → put the export back outside the
  OS branch.
- "unlink removes the links it created" → delete those lines from the target.
- "every skill is listed in the table" → remove one row.
- "the timer lives in the loader" → move it back into a module.

If you cannot think of a realistic edit that should fail the test, that is
itself the finding: the test may be describing the implementation rather than a
behaviour anyone could break.

## Do not

- Skip it because the test "obviously" works. The three hollow tests that turned
  up in this repository all looked obviously fine.
- Edit the test to make it fail. Breaking the *code* is the experiment;
  breaking the test proves only that the file is editable.
- Commit with a break in place, or report a matrix you did not run.
- Treat the matrix as a substitute for the test being worth having. A break
  check proves a test bites; it does not prove it bites on anything that
  matters.

## Constraints

- Where breaking is genuinely expensive — it needs hardware, a paid service, a
  destructive migration — say so plainly instead of skipping quietly, and
  describe the break you would have made.
- Keep the loop to the single test or its suite. Running everything for each
  break turns a seconds-long check into a chore, and a chore gets skipped.
