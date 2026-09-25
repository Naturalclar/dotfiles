---
name: parity-check
description: Find concepts defined in more than one place — an alias in two shells, a keybinding in two configs, a constant in two languages, a procedure in two documents — check the copies still agree, and propose the test that keeps them agreeing. Use when the user says "二重定義を探して", "定義がズレていないか確認して", "パリティを確認して", "check these are in sync", "did these drift", or after adding a definition that already exists somewhere else. Reports coverage explicitly; a comparison that silently reaches only part of the definitions is the failure this exists to prevent.
---

# parity-check

Find the places where one concept is written down more than once, check the
copies still say the same thing, and leave behind a test that catches the next
drift. The deliverable is a list of pairs with a verdict each, an explicit
statement of what was **not** compared, and a proposed test.

## Why coverage is the whole job

In this repository the zsh/fish/PowerShell alias parity was patched five times:
the rule was agreed (#242), a check added (#266), then `ws` was found drifting
because fish defined it as a function and the check read only `alias` lines
(#275), then PowerShell was added but only its one-line functions (#288), then
`gco` and `gpull` were found drifting because multi-line functions were skipped
(#292).

Every round, the check passed. Each time, the gap was in **what the extractor
reached**, not in the comparison. A green run reads as "these agree" when it
means "the pairs I managed to parse agree", and nobody can tell the difference
from the outside.

So: a parity check that does not state its own reach is not finished.

## 1. Find the duplicated definitions

Look for the same concept expressed in more than one place:

- the same name in two languages or two configs — aliases, functions,
  keybindings, environment variables, constants, error codes, i18n keys;
- a value repeated across a boundary — a default in code and in a README, a
  version in a manifest and in a Dockerfile, a path in a script and in a test;
- a procedure written twice — setup steps in two documents, a workflow
  described in prose and implemented in CI.

Start from what the repository says about itself: a file that claims to mirror
another is a parity claim. So is "source of truth" in any document.

## 2. Establish what a pair is before comparing

Two definitions form a pair when they are meant to do the same thing for the
same caller. Same name is a hint, not proof.

- **Same name, different role** is not a pair. Do not force it.
- **Different name, same role** is a pair, and the one an extractor keyed on
  names will miss entirely.
- **A deliberate platform difference is a pair that correctly differs** —
  `open` against `explorer.exe` under WSL, a path that is `~/Library` on one
  system and `~/.config` on another. It is a recorded difference, not drift.

## 3. Compare what can be compared, by hand where it cannot

Some pairs are textually comparable after normalising quoting and whitespace.
Others are genuine rewrites in another syntax and can only be read.

Put every pair in one of three buckets and keep them separate:

| bucket | what it means |
| --- | --- |
| **compared** | machine-checked, and the check is in the proposed test |
| **hand-checked** | read by a person, recorded by name with the reason it cannot be compared |
| **not reached** | the extractor never saw it. This is the bucket that matters |

A hand-checked list is how a new unreadable pair is forced into someone's view
rather than passing silently. It is only worth having if it is checked for
entries that no longer exist (step 5).

## 4. Report coverage, in numbers

State: how many definitions exist on each side, how many pairs were formed, how
many were compared, hand-checked, and not reached. Name the ones not reached
and say why — a syntax the extractor does not parse, a generated file, a
definition built at runtime.

"All pairs agree" without these numbers is the sentence that let #275 and #292
happen. If the count of definitions cannot be established independently of the
extractor, say that too: it means coverage is unknown, not complete.

## 5. Check the exception list for stale entries

Every hand-checked entry is an exemption from the comparison. When the
definition it names is gone or has become comparable, the entry stops
documenting anything and starts excusing whatever next takes that name.

Assert that each one still refers to a pair that still exists and still cannot
be compared. This test is cheap and it is the reason an exception list can be
trusted at all.

## 6. Propose a test for the class, not the instance

A drift found by hand is one instance. The test to propose is the one that
would have caught **any** member of its class, including the pairs that exist
today and the ones added next month.

The test has three parts, and the first is the one usually left out:

1. **Assert the extractor's reach.** Count the definitions independently of the
   extractor — a plain grep, a known list, the file's own structure — and
   assert the extractor found that many. Without this, the next syntax the
   extractor cannot parse leaves the suite green.
2. **Assert the pairs agree**, naming the offenders in the failure message.
3. **Assert the exception list has no stale entries.**

Prove the test works by breaking the thing it covers, not by reading it: change
one copy and confirm the test fails, naming that copy. A parity test that
passes against a deliberate mismatch is worse than none, because it is evidence
of the wrong thing.

## Do not

- Decide that two copies **should** be merged, or which one is right. Report the
  difference; the choice of source of truth is the user's.
- Treat every difference as drift. A recorded platform difference is correct,
  and flagging it teaches people to ignore the check.
- Pair definitions because their names match.
- Report "in sync" when the extractor reached only some of them. Say what it
  reached.
