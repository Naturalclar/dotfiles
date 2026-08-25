---
name: repo-survey
description: Survey any repository for concrete, reproducible defects and file them as GitHub issues, one per finding. Use when the user says "リポジトリの改善点を提案して", "改善点を洗い出してissue化して", "look for improvements in this repo", "find problems and open issues", or asks for a health pass over a repo they own.
---

# repo-survey

Read a repository looking for things that are **wrong**, prove each one, and file
it as an issue someone can pick up and close in a single PR.

The failure mode of this task is a list of tasteful suggestions — "add more
tests", "consider extracting this", "the README could be clearer". Those are
opinions, and they age into stale issues nobody closes. What earns an issue is a
defect you reproduced.

## The bar

File it only if all four hold:

1. **It is wrong**, not merely different from how you would write it. A wrong
   path, an unread variable, a rule matching nothing, a documented command that
   fails.
2. **You reproduced it**, and can paste the command and its real output.
3. **One PR closes it.** A finding that needs three unrelated edits is three
   findings, or it is a discussion, not an issue.
4. **The fix does not need a decision you cannot make.** "Should this repo drop
   Python 2 support?" is a question for the user, asked in chat, not an issue
   filed on their behalf.

If a finding fails (2) — it looks wrong but you cannot make it happen — keep
digging or drop it. An unverified issue costs the reader more than it saves.

## Where the findings actually are

Ordered by how often this turns up something real. Read the repo's own
`README` / `CLAUDE.md` / `AGENTS.md` first, and `git log --oneline -30` for
where the project has been moving lately.

- **Code that runs on every invocation.** Shell rc files, CI bootstrap, app
  entrypoints, hooks. Anything here that writes to stdout, spawns a process, or
  sources a file without checking it exists is a defect that fires thousands of
  times. Run the entrypoint and *look at the output*, both streams:
  ```bash
  <entrypoint> >/tmp/out 2>/tmp/err; wc -l /tmp/out /tmp/err
  ```
- **Machine-specific assumptions.** Grep for absolute paths and platform
  defaults: `/Users/`, `/home/`, `/opt/homebrew`, `C:\`, a hardcoded username,
  an architecture-specific binary path. Each one is a file that works only where
  it was written.
- **Silent no-ops.** Config that matches nothing (exact-match rules with a typo),
  a variable exported and never read, a step that skips instead of failing, a
  glob that no longer matches. These never announce themselves. Grep the codebase
  for each configured name to confirm something consumes it.
- **The installer versus the documentation.** Run down what the setup script
  actually does against what the docs say it does. A step the docs promise and
  the script omits shows up weeks later as "why doesn't this work on this
  machine".
- **CI versus the local instructions.** Tools CI installs by hand but the
  project's manifest (`Brewfile`, `package.json`, `pyproject.toml`) omits; tests
  that exist in the tree but no job runs; a job listing files individually where
  a glob would pick up new ones.
- **Two sources of truth.** The same content in two files, two shells, two
  configs. One of them is already out of date — check, do not assume.
- **Docs that make claims.** Treat every command in a README as a test case and
  run it. Treat every path named in prose as an assertion and check it exists.

## Method

1. **Survey broadly before going deep.** Inventory the tree, read the entry
   points, skim CI. Collect candidates; do not start writing yet.
2. **Reproduce each candidate.** Run it. Capture the output verbatim — that
   output becomes the issue body. Working in a throwaway `$HOME`, a temp dir, or
   a container is often what makes a "works on my machine" bug visible.
3. **Check for duplicates** before filing, including closed ones:
   ```bash
   gh issue list --state all --search "<keyword>"
   ```
4. **Rank** by: does it silently produce wrong behavior, how often the path runs,
   how cheap the fix is. File the top few — around five to eight is a batch
   someone will actually work through. Say what you dropped and why.
5. **File one issue per finding**, in the language the repo's existing issues use.
6. **Report the list back** with numbers and one line each, so the user can pick
   what to start on.

## Issue format

Keep it short enough to read in one screen. Four parts:

- **What happens** — the reproduction, with the real command and real output in a
  code block.
- **Why it matters** — the consequence, concretely. Not "this is bad practice"
  but "every shell that starts on Linux leaves an ssh-agent process behind, and a
  key added in one terminal is invisible in the next".
- **Proposal** — the shape of the fix, with a code sketch when it is short.
  Leave room for the implementer to disagree; do not write the whole patch.
- **How to check it** — the command that will show the fix worked. This is what
  makes the issue closeable by someone who is not you.

Add what you deliberately left out of scope, when a reader would otherwise
wonder — a Windows counterpart, a second shell, a related-but-separate bug.

Where the project has a test suite, say which test would have caught it. A
finding that can be turned into a check that prevents the whole *class* of
regression is worth more than the single fix; note that in the proposal.

## Do not file

- Style, formatting, or naming preferences.
- "Add tests" with no specific untested behavior named.
- Refactors justified by taste rather than a bug, a duplication, or a
  demonstrated cost.
- Dependency or version bumps with no failure behind them.
- Anything you would have to speculate about to describe.
- A meta-issue about doing this survey.

## Constraints

- **Filing is a write to someone else's project.** Confirm before creating the
  first issue unless the user asked for issues in this turn, and never file on a
  repository the user does not own or maintain.
- Do not fix anything while surveying. Finding, filing and fixing in one pass
  produces a branch nobody can review; the user chooses what gets worked on.
- Report honestly if a pass turns up little. A short list of real defects beats a
  padded one, and "this area is in good shape" is a useful result.
