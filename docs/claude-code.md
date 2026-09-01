# Claude Code

Skills live in `.claude/skills/`, the location Claude Code reads project skills
from, so they are available to anyone working in this repository — and to a
cloud session, which clones the repository and never sees `~/.claude` on any
machine.

`make claude` is what carries them to the rest of your work: it links
`configs/claude/settings.json` to `~/.claude/settings.json` and every directory
under `.claude/skills/` into `~/.claude/skills/`, so the skills apply in other
repositories too. The skills are linked one at a time rather than as a whole
directory, so skills installed from anywhere else stay where they are. A skill
directory that already exists in `~/.claude/skills` as a real directory is
reported and skipped rather than overwritten.

Most of `.claude/` is Claude Code's own per-machine state, so `.gitignore`
ignores its contents and re-includes only `skills/`. That takes two lines —
`/.claude/*` then `!/.claude/skills/` — because git does not descend into an
excluded directory, which makes a negation under `/.claude/` silently do
nothing.

A third route, independent of this repository: uploading a skill to your
claude.ai account syncs it into `~/.claude/skills/synced/` for Cowork and cloud
sessions everywhere. Manage those from **Customize** in the desktop app sidebar
or the skills settings on claude.ai.

| Skill | Description |
| --- | --- |
| `tailscale-serve` | Expose a dev server on the machine you are SSH'd into to the rest of the tailnet with `tailscale serve`, so a browser on the machine you are sitting at can reach it. Pairs with `tssh`. |
| `repo-survey` | Read a repository for defects that can be reproduced, and file them as one-PR-sized GitHub issues. Repo-agnostic. |
| `file-split-survey` | Find oversized source files with mixed responsibilities, propose a concrete one-PR split, and optionally file the proposal as a GitHub issue. Repo-agnostic. |
| `issue-triage` | List the open issues and put them in the order they should be worked on, with a reason for each position. The other half of `repo-survey`. Repo-agnostic. |
| `verify-on-machine` | Write the checks a person must run where the agent cannot reach — Windows, GUI, hardware — each with its expected output. Repo-agnostic. |
| `break-check` | Prove a test fails when the behaviour it covers is broken, before claiming the regression is covered. Repo-agnostic. |
| `pr-status` | List the open pull requests and report what each is waiting on — CI, conflicts, review — with the next action. Repo-agnostic. |

A skill is a `SKILL.md` with YAML frontmatter; the `name` has to match its
directory and the `description` is what Claude Code matches against to decide
when to load it. `test/makefile.bats` checks both.

[Back to the README](../README.md).
