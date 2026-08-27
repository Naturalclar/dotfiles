---
name: file-split-survey
description: Find oversized source files whose mixed responsibilities have a concrete, one-PR split, then propose or file GitHub issues for them. Use when the user says "行数の多いファイルを探して分割案をIssueにして", "大きすぎるファイルを分割したい", "find large files and propose splits", or "open refactoring issues for oversized files". Do not use for general defect discovery or a requested implementation.
---

# file-split-survey

Find files that are costly to change because unrelated responsibilities have
grown together, describe a safe split, and optionally file one GitHub issue per
file. Line count selects what to inspect; it is never the reason to refactor.

This is narrower than `repo-survey`: a candidate need not be broken, but the
maintenance cost and the proposed boundary must both be visible in the current
repository.

## Inventory

Read the repository's own instructions first. Use tracked text files as the
source of truth and rank them by physical lines. `git grep` avoids binary files
and does not descend into submodules unless explicitly asked:

```bash
git grep -Ilz -e '' | xargs -0 wc -l | sort -nr | head -30
```

Treat roughly 300 lines as worth a glance, 500 as a strong candidate, and 1,000
as something to inspect unless it is excluded. These are defaults, not gates:
respect a user-supplied threshold or directory, and account for the language and
the repository's normal file sizes.

Drop files people do not maintain by splitting them:

- generated code, build output, vendored code and submodules;
- lockfiles, source maps, minified files, snapshots and machine-written data;
- binaries and large declarative assets;
- migrations or fixtures whose order or identity is the point.

Report meaningful large files that were excluded and why. Do not silently let
them compete with source files.

## Find a real boundary

Inspect the plausible top candidates rather than every file over a threshold.
For each, map:

- functions, classes, types, exports and major sections;
- imports, callers and the public entry point;
- tests that exercise the file;
- recent changes with `git log --oneline -- <path>`;
- shared mutable state, initialization order and possible dependency cycles.

A candidate earns a proposal only when all of these hold:

1. It contains responsibilities with different reasons to change.
2. Each responsibility has a useful name and a concrete destination path.
3. One PR can perform the split without redesigning behavior.
4. Existing public imports, exports or execution order can be preserved.
5. Tests, lint or a build can show that the move did not change behavior.
6. No open or closed issue already covers the same file and boundary.

The strongest evidence is repeated edits to separate sections, unrelated
features sharing one review surface, or tests and callers already revealing the
module boundary. "This file has 600 lines" is not evidence.

Drop candidates whose split would create grab-bag `utils` modules, introduce
cycles, scatter one cohesive algorithm, or require a product or architecture
decision. Put decision-blocked candidates in the report as questions instead of
filing them.

## Write the split

Make the proposal concrete enough that another person can implement it without
rediscovering the boundary. Include a mapping such as:

| Current section | Destination | Responsibility |
| --- | --- | --- |
| parser functions and types | `parser.ts` | Turn input into the internal form |
| validation rules | `validator.ts` | Reject invalid internal values |
| public exports | `index.ts` | Preserve the existing import surface |

State:

- the current line count and the mixed responsibilities;
- the demonstrated cost of keeping them together;
- the files to create and the symbols to move;
- the API, state and ordering that must remain unchanged;
- cycle or migration risks;
- the exact tests, lint and build commands that prove completion.

Leave implementation details open where more than one equivalent move is safe.
Do not write the patch while surveying.

## Decide what to file

Rank qualified proposals by how often the file changes, how many unrelated
responsibilities it carries, the likelihood of conflicting edits, and the cost
of the split. A small, clear move ranks above an ambitious redesign.

File only the best few, normally three to five. One issue covers one source file
and one coherent split. If the work cannot close in one PR, narrow it or report
it as needing a decision.

Before filing, search open and closed issues using the path, basename and the
proposed module names:

```bash
gh issue list --state all --search '"<path-or-basename>"'
```

## Issue format

Keep the issue implementable and reviewable:

- **Current state** — path, line count, named responsibilities and evidence.
- **Why split it** — concrete maintenance or review cost, not a size judgment.
- **Proposed split** — destination paths and a symbol/section mapping.
- **Compatibility and risks** — exports, callers, state, order and cycles.
- **Done when** — commands and structural assertions that verify the move.

Use the language of the repository's existing issues. Mention related work that
is deliberately out of scope.

## Authorization and output

Creating an issue is an external write. If the user asked only for analysis,
return proposed issue drafts and ask before creating the first issue. If they
asked for issues in the current turn, that authorizes filing them on a
repository they own or maintain; it does not authorize code changes.

Return:

- the largest maintainable files inspected;
- issues created, with number and one-line split;
- large files excluded, with the reason;
- candidates not filed because they need a decision or lack a clean boundary.

Do not pad the result. A repository with no justified split should produce no
issues.
