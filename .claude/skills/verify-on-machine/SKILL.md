---
name: verify-on-machine
description: Write the checks a person has to run where you cannot reach — Windows, a GUI app, real hardware, another machine, a tailnet — each with its expected output and what to send back if it differs. Use when finishing a change you could not exercise yourself, or when the user says "実機で確認したい", "確認手順を出して", "how do I verify this", or asks what to check after pulling.
---

# verify-on-machine

When the change lands somewhere you cannot run it, the handover is the
deliverable. Write the checks so that one round settles it: what to run, what
good looks like, and what to send back when it does not match.

The failure mode is "確認してください" with no command, or a list of ten checks
that all restate the same thing. Both cost a round trip, and round trips are the
whole expense here.

## Steps

1. **Name the boundary first.** Say what you did verify and what you could not,
   in one line. "CI is green and the file parses" is not "it works" — CI never
   opened the window, played the sound, or joined the tailnet.

2. **List the activation step.** Nothing below matters if the change is not live.
   Reloading config, restarting the shell, re-linking (`make claude`), sourcing
   the rc file, or **reopening a window whose state was read at startup** —
   name it explicitly, because "I pulled and nothing changed" is usually this.

3. **Write each check as three parts.**

   - the command, copy-pasteable
   - the expected output, concretely
   - what a different result means, and the command whose output you need next

   ```
   komorebic reload-configuration
   # then, with the app open:
   komorebic visible-windows
   # expect a line with exe "UAD Console.exe"
   # if the name differs, that is why the rule did nothing -- send this output
   ```

4. **Aim the first check at whatever is most likely to be wrong.** Usually the
   assumption you could not test: an exact name, a path, a version. If that one
   passes, the rest usually follow.

5. **Watch the silent failures hardest.** Configuration that matches nothing
   produces no error, so nothing tells the user it failed:

   - exact-match rules with a wrong identifier
   - a variable exported to a path that does not exist
   - a hook calling a command the machine does not have
   - a keybinding shadowed by the terminal or the window manager

   For each of these, the check must confirm the thing *matched*, not merely
   that the command exited 0.

6. **Keep it to the checks that discriminate.** Three that can each fail
   differently beat ten that all pass together. Say plainly when a check is
   optional.

## Do not

- Report as done what you could not run. "Should work" is not a result; either
  give a check or say you could not verify it.
- Ask for checks CI already performs. Their machine is for what CI cannot see.
- Bundle unrelated checks into one step — a single "did it work?" covering three
  changes cannot tell you which one failed.
- Send them to look at something without saying what they are looking for.
- Re-guess after a failure report. Use the output they sent; if it is not
  enough, ask for exactly one more command.

## Constraints

- Prefer checks that only read. Where a check changes state — clearing a
  mapping, restarting a daemon, editing settings — say so and say how to undo
  it.
- On Windows and other shells, write the command in that shell's syntax rather
  than translating loosely.
- Where nothing can be checked without special hardware or an account you do not
  share, say that, and describe what would have been checked. An honest gap
  beats an unfalsifiable claim.
