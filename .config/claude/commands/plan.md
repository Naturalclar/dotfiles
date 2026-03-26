Create a plan document for the task described by the user.

1. Ask the user what they want to plan.
2. Create a markdown file at `docs/plan/YYYY-MM-DD-<slug>.md` in the current working repository, where:
   - `YYYY-MM-DD` is today's date
   - `<slug>` is a short kebab-case summary of the plan topic (e.g. `2025-03-05-migrate-to-pnpm.md`)
3. The file should have this structure:

```markdown
# <Plan Title>

Date: YYYY-MM-DD

## Goal

<What we want to achieve>

## Background

<Context and motivation>

## Steps

- [ ] Step 1
- [ ] Step 2
- ...

## Notes

<Any additional considerations>
```

4. Fill in the sections based on the user's description, asking clarifying questions if needed.
5. If the `docs/plan/` directory does not exist, create it first.