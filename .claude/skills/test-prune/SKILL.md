---
name: test-prune
description: Read every test in a codebase and list the ones that should be deleted or merged — copies of the implementation, mocks checking themselves, re-tests of a type system or library, duplicates, tests welded to internals, and case explosions — each judged by the one question "what realistic defect ships if this is gone?". Use when the user says "不要なテストを洗い出して", "削れるテストをリストアップして", "テストを減らしたい", "テストを整理して", "prune the tests", "which tests can be deleted", "audit the test suite for dead weight", or when a suite has become slow, flaky, or expensive to change.
---

# test-prune

Every test costs something on every run and on every refactor: seconds of wall
clock, a chance of flaking, and an edit whenever the code under it moves. It
pays that back only by catching a defect that would otherwise ship. A test that
cannot catch one is not free insurance. It is a tax with a green tick on it.

So read the whole suite and ask one question of each test:

> **If this test were deleted, what realistic defect would reach users
> without any other test noticing?**

If the honest answer is "none", or "one that `<other test>` already catches",
the test goes on the list. "Just in case" is not an answer. Neither is the
coverage number, and neither is the test count.

## Method

1. **Inventory first.** Count the test files and the cases in them, and note
   how long the suite takes and which tests are retried or marked flaky. Pull
   the numbers from CI or a local run rather than guessing. This is the cost
   side of every judgement below. For how often a test gets edited, count
   commits per file (`git log --oneline -- <file> | wc -l`) and reach for
   `git log -L` on a test's line range only for the candidates; `git log -S`
   with the test's name finds the commit that added it and nothing else.

2. **Read every test, not a sample.** Duplication is a relationship between
   files, and you cannot see it one file at a time. For each test, read the
   code it exercises too. You are checking what the assertion actually pins.

3. **Answer the question for each test, in one line.** Write the defect it
   would let through, concretely: not "regressions in the parser" but "a
   trailing comma making `parse` return an empty list". If you cannot name
   one, that is the finding.

4. **Then weigh it.** A test with a real answer can still be worth cutting
   when what it costs outweighs what it guards: a ten-second integration test
   that pins a defect a unit test also pins, or a flaky test whose retries
   have taught everyone to ignore the suite. Compare, and say which side won.

5. **Check history before condemning.** `git log -S` or `blame` on the test:
   one that was added with a bug fix pins a defect that actually happened,
   and its answer to the question is that bug. Keep it unless a better test
   now covers the same thing, and say which.

6. **Report.** Every candidate with its verdict and its answer, then the
   tests you considered and kept, so the reader can see the sweep was
   complete rather than a skim of the suspicious-looking names.

One answer that counts, and is easy to miss: **"it keeps this file's other
tests from passing vacuously."** A test that a glob matched something, or
that an extractor found any entries at all, looks like a duplicate of every
other test that iterates the same glob. It is not. Without it the file's own
loops iterate zero times and go green. Keep it in the file whose loops it
guards, even when another file has the same check.

## What to cut

### 1. Copies of the implementation

The assertion repeats the code's own arithmetic or logic, so the test and the
implementation are wrong together and right together. A giveaway: the expected
value is *computed* in the test, by the same steps the code uses, rather than
stated. Another: the test can only be made to fail by breaking the code *and*
the test.

Cut it, or replace the computed expectation with a literal the author worked
out by hand. Only the second version can disagree with the code.

### 2. Mocks verifying themselves

The test stubs a collaborator to return X, then asserts the code received X;
or asserts the mock was called with the arguments the test itself passed in.
The only thing under test is the mocking library.

Cut, unless the assertion is about a *translation* the code performs between
input and the collaborator's call. Asserting `client.send` was called with the
serialised form of the input pins something. Asserting it was called at all
usually does not.

### 3. Re-testing the type system or a library

A test that a field is a string in a typed language, that a well-known library
parses valid JSON, that a framework's validator rejects what its docs say it
rejects, that an enum has the members the enum declares. The compiler, or the
library's own suite, already holds that line.

The exception is a test that pins *your* use of a library at a version
boundary you have been bitten by. Say which version and why, or cut it.

### 4. Duplicates

Two tests fail on the same defect. This includes the same behaviour asserted
at two layers, the "happy path" test repeated with a different fixture that
exercises no different branch, and the integration test whose only assertion
is one a unit test already makes.

Keep the one closest to the contract users depend on, and the cheaper one
when they are equally close. Say which to keep, by name, and why.

### 5. Welded to the internals

Tests of private functions, of call order, of the exact shape of an internal
data structure, snapshots of anything not user-visible. These fail on every
refactor that changes nothing observable, so they are edited on every refactor
and quickly stop asserting anything anyone thought about.

Cut them, or rewrite the assertion against the observable outcome. A test that
fails only when behaviour changes is the one that survives a refactor and is
still worth reading afterwards.

### 6. Case explosions

Twelve inputs through the same branch. A parametrised test whose rows differ
only in values the code never inspects. Every combination of two flags when
the flags do not interact.

Keep the boundaries and one representative of each branch. The others answer
the question with "the same defect the representative catches".

## What to keep

The point is not a smaller suite. It is a suite where every test has an
answer. So be as careful about keeping as about cutting, and expect these to
survive:

- A test that pins a bug that shipped. Its answer is the bug.
- The only test of a contract other code or other people depend on.
- Tests at a boundary the type system cannot see across: a process, a shell,
  a file format, another OS, a tool that may or may not be installed.
- Tests whose failure message names the defect. They are cheap to keep and
  cheap to read when they fire.
- A test that looks like a duplicate but exercises a different branch. Check
  the path, not the name.
- The guard that stops a loop from passing on nothing, as above.

## Report

One row per candidate:

```
test/parser.bats:41  "parse handles a nested list"
  verdict   merge into "parse handles a list" (same branch, deeper fixture)
  kind      duplicate
  if gone   nothing new: a broken list path fails the other test first
  cost      0.8s, edited in 4 of the last 6 parser changes
```

Sort by what is saved, not by how sure you are: the slow and flaky candidates
first, then the ones edited most often, then the rest. When nothing is slow
or flaky, say so in one line at the top and order by edit frequency, so the
reader does not wonder whether you looked. Give the totals at the end: cases
before and after, and the run time if you measured it.

Then the tests you weighed and kept, with the defect that kept them. Tests
that share one answer share one line ("the four `killport` branches: no
args, non-numeric, no listener, kill"); everything else gets its own. A
reader should be able to disagree with a specific judgement, which means
every judgement has to be on the page.

Finish with **Observed while reading**: what you saw that is not a prune
candidate but bears on the suite. Tests red on the maintainer's own OS, a
fixture that leaks the parent shell's environment, a test currently failing
for a real reason nobody has acted on. These are the "everyone ignores the
suite" signals from step 4, and they belong on the page even though the
answer to the question is not "cut".

## Do not

- Delete or merge anything as you go. The deliverable is the list; the cuts
  are the user's decision, and some of them will be argued.
- Keep a test to protect a coverage percentage or a case count. A drop in
  coverage is the expected result of this work, not a finding against it.
- Cut a test because it is *similar* to another. Read both paths; similar
  names cover different branches more often than you would think.
- Propose a rewrite of the suite. That is a different task. Here a test is
  kept, cut, merged, or has its assertion narrowed, and nothing more.
- Skip the "kept" list. A report that is all cuts reads as a skim, and the
  reader cannot tell what was actually examined.
- Pad the report with tests whose answer is a real defect. Listing a good
  test as a "maybe" costs the reader more than it saves.
