# AGENTS.md

**The guidance for this repository lives in [`CLAUDE.md`](CLAUDE.md). Read that
file before making changes — it applies to every coding agent, not just Claude
Code.**

It covers the make targets, what CI checks, how `.zshrc` and `.zsh/*.zsh` are
arranged, which tools the config assumes, and the code style to match.

This file used to carry its own copy of all of that, and the copy went stale:
it still described `.zshrc` as the main config months after it became a loader,
and still sent Windows setup through `bootstrap.ps1` after `install.ps1` became
the entry point. Two files promising to mirror each other drift the moment one
is edited alone, so this one deliberately holds nothing to drift — if you came
here for the details, they are one file over.
