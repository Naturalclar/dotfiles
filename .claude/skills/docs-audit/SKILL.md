---
name: docs-audit
description: Treat the documentation as a test suite — run the commands it gives, resolve the paths and links it names, and check its claims against the code that implements them. Use when the user says "ドキュメントが実態と合っているか確認して", "READMEの手順を検証して", "audit the docs", "does the README still work", or after a change that moves files the docs describe.
---

# docs-audit

Documentation rots quietly. Every command in a README is a test case nobody
runs, every path in prose is an assertion nobody checks, and a claim about what
a script does is only true until the script changes.

Run them.

## Scope: what the tests already cover

Find out before starting. A repository with a docs test suite has already
mechanised part of this, and repeating it wastes the pass. Here, for example,
`test/docs.bats` covers paths, fences, trapped headings, and the skill and
script tables — so the audit is for what testing has not reached:

- **commands actually running**
- **claims about behaviour matching the implementation**
- **markdown links resolving**

Report which checks you skipped as already-tested, so the reader can tell a
clean audit from a shallow one.

## Running the commands

Classify every command before running any. The classification is the safety
mechanism, so do it explicitly rather than by feel.

| Class | Examples | Action |
| --- | --- | --- |
| Read-only | `ls`, `git log`, `--help`, `--version`, `--dry-run` | run it |
| Writes, but confinable | `make`, a setup script, anything that writes under `$HOME` | run with `HOME=$(mktemp -d)`, or in a throwaway clone |
| Destructive or external | `rm`, `sudo`, `chsh`, `defaults write`, package installs, `git push`, `curl \| sh` | **do not run**; report as not run |
| Needs what you lack | another OS, hardware, a private host, an account | do not run; say which |

Two rules that matter more than the table:

- **Never run a command that changes the user's machine to prove a document
  correct.** A README that says `rm -rf ~/.config/foo` gets read, not executed.
- **Say what you did not run and why.** "12 commands, 7 run, 5 skipped
  (destructive)" is the honest shape. An audit that silently skips the
  interesting half looks identical to one that passed.

## Checking the claims

The claims are where the real rot is, and no linter finds them. Take each
sentence that asserts behaviour and go read the thing it describes:

- "`install.sh` symlinks dotfiles, `.config` and the Claude config" → open
  `install.sh` and list what it actually calls. A step the docs promise and the
  script omits is invisible until a new machine is set up.
- "bound to `F4` in tmux" → grep the config for that binding.
- "linked into `~/.claude/skills`" → find the code that does the linking.
- "runs on every push" → read the workflow's triggers.

State each mismatch as *doc says X, code does Y*, with the file and line for
both.

## Rendering

Some defects exist only after rendering, and are invisible in the source:

- a fence that never closes, or one opened with more backticks than the line
  meant to close it — everything after it becomes code
- consecutive prose lines, which markdown joins into one paragraph: a list of
  keybindings written as nine plain lines renders as one run-on sentence
- ASCII art outside a fence, where runs of spaces collapse

Where the platform renders differently from a local viewer, check the rendered
page rather than guessing.

## Links

Resolve every relative link and every anchor. A moved file leaves a link that
looks fine in the source and 404s for the reader.

## Report

Four groups, in this order:

- **Mismatches** — doc says X, code does Y. The findings.
- **Ran** — command, and whether it behaved as documented.
- **Not run** — with the reason: destructive, needs another machine, needs an
  account.
- **Already covered by tests** — so a thin pass cannot pass for a thorough one.

Then say which findings could become tests. A mismatch that a check would have
caught is worth more as a check than as a fix, and this is exactly the kind of
thing that mechanises well.

## Do not

- Run anything destructive, on the user's machine, to verify a document.
- Rewrite the documentation as you go. Report and let the user decide — the
  wrong fix is often "the docs were right and the code drifted".
- Comment on wording, tone, or structure. That is taste, and it ages badly.
- Report "the README looks fine" without saying what you executed.
