---
name: skill-prune
description: Read one SKILL.md and list the sentences whose removal would not change what the agent does — contradictions first, then repetition — keeping whatever the repository has decided to keep, and delete them only after approval. Use when the user says "skill-prune", "スキルを削る", "このスキル短くして", "消しても挙動が変わらない文を探して", "prune this skill", or names a skill to prune. Repo-agnostic.
---

# skill-prune

A skill is read in full every time it loads. A sentence that does not change
what the agent does still costs that read, and it dilutes the sentences that
do. So read the skill and ask one question of each sentence:

> **If this sentence were deleted, would the agent do anything differently?**

If not, it goes. The standard comes from
[Skills: writing for agents](https://www.aihero.dev/skills-writing-for-agents).

**One skill at a time.** With many skills it is tempting to sweep them all, and
the judgement gets sloppy. Start with the skills that were touched most
recently.

## Look for contradictions first

**Contradictions turn up before redundancy does.** They are layers left behind
by older versions of the skill:

- one section says "bullets, two sentences each", another says "prose, two or
  three paragraphs, not bullets"
- one line says "never tick the task", and a later step ticks it

**A sentence that is not followed is a sentence whose removal changes
nothing**, so the same question catches it. Report which side of the
contradiction the skill actually follows, and propose deleting the other.

## Steps

1. **Pick one skill.** If the user has not named one, ask.
2. **Read the whole file, and the repository's rules for skills.** Cutting
   from a part misses contradictions with a distant section. The rules are in
   `CLAUDE.md`, `AGENTS.md`, or a doc they point to: what every skill must
   keep, what is duplicated on purpose, and where skills are mirrored.
3. **Ask the question of each sentence.**
   - **A sentence that fails goes whole.** Do not trim its wording: half a
     sentence keeps the length and loses the meaning.
   - **When the same thing is said twice, one copy can go** — except for what
     the next section keeps.
4. **Report the candidates and get approval before deleting.** Give each a
   one-sentence reason. **If you cannot write the reason, it is not a
   candidate.**
5. **Mirror, if the repository mirrors skills.** When the same skill exists
   for another agent (for example `.agents/skills/<name>/SKILL.md` for Codex),
   apply the same deletions there and check the two files still differ only
   where the repository says they may (the agent's name, the tool names).
   Skip this step when there is no mirror.
6. **Check.** Run a skill that can be run safely once and see it behaves the
   same. Do not run a skill that merges, pushes, creates branches, writes
   outside the repository, touches another worktree, or restarts a process;
   for those, limit the change to removing contradictions.

## Do not delete

- **Anything the repository's rules say every skill keeps** — a fixed first
  line, a style marker under the H1, a required section. These are often there
  so drift can be detected, and deleting one removes the check, not noise.
- **Duplication the repository says is deliberate.** Some repositories copy a
  rule into every skill so each one stands alone. That conflicts with "a
  repeat is unverified", and the repository's decision wins.

But **do delete a copy of a value whose source is another file.** If the skill
says "read `goals.md`" and also quotes the number from it, the copy changes
nothing while it is right and lies once the file changes.

## Constraints

- Touch only the target `SKILL.md` and its mirror.
- **Do not rewrite.** Only delete. Improving the wording is separate work;
  mixing the two hides which change made the difference.
- Do not delete a sentence that has not been approved.
