---
name: jev
description: Ask Jev, TypeSafe AI's decision-only model, narrow typed questions — true/false (noul), choose one (choice), or score — and get calibrated confidence back instead of prose. Use when the user says "Jevで判定して", "Jevに聞いて", "Jevを呼んで", "ask Jev", "call Jev", or when a task needs many shallow decide/classify/route/score calls whose confidence should gate what happens next. Requires JEV_API_KEY in the environment; when it is missing, say so explicitly instead of answering in Jev's place.
---

# jev

Jev takes a **state** (text) and **named, typed questions**, and answers each in
a fixed shape. It writes no prose. What it offers over asking a general model is
that the confidence is calibrated: a 0.83 means about 83%, so a threshold can
decide what happens next.

Call it through the `jev` tool in `.scripts/` (on `PATH` via this dotfiles
repository). Do not rebuild the HTTP request by hand; the tool is the one place
it is built.

## 1. Check the key first

```sh
[ -n "$JEV_API_KEY" ] && echo set || echo missing
```

Never print the value itself.

**When it is missing, stop and say so.** In the reply, state plainly that
`JEV_API_KEY` is not set in this environment and that Jev was **not** called, and
where it is expected to come from (exported by
`~/.config/secrets/credentials.sh`, which `.zsh/80-late.zsh` sources). Then offer
the fallback — judging it yourself — as your own judgement, labelled as such. Do
not produce numbers that look like Jev's output: an uncalibrated 0.9 written by
you is exactly what the user wanted to avoid.

`jev` enforces the same thing: without the key it sends nothing, prints
`jev: JEV_API_KEY is not set, so Jev was not asked` on stderr, and exits 2.

## 2. Decide whether Jev fits

Jev is for **narrow, shallow judgements, many at a time**: decide, classify,
route, score. It is a poor fit — ask differently or do not use it — for:

- **writing** anything, or long multi-step reasoning;
- **counting, arithmetic, and date order or intervals** ("is this before the
  15th?"). Compute those in code and ask Jev only the part that needs judgement;
- **properties that are not in the text**, such as "was this written by AI".
  Measured on real notes this scored near chance and followed the topic, not
  the writing;
- a question comparing several independent things at once. Split it into one
  question per thing.

Japanese works, but the vendor says accuracy is lower than in English. When the
result matters, try a few known cases before trusting a threshold.

**Mind what leaves the machine.** The state is sent to an external API. Do not
send work code, company issue text, credentials, or anything the user has not
cleared for that. When unsure, ask before sending.

## 3. Write the questions

Write each question as a **literal statement about the state**, the way a
careful reader would check it — not an instruction or a double negative:

- good: `この日記は「健康診断の予約を取る」が済んだことを述べている`
- weak: `健康診断の予約の件について何か言えるか`

Phrasing moves scores a lot. A dated plan asked "was X done" with the date and
time attached scored 0.04 against a diary saying it happened; asked without the
date as "went to / took part in X", 0.46–0.91.

**Put every question in one call.** The state is read once for all of them, so
many questions cost little more than one. Name questions so the answer maps back
to your data (`q0`, `task-slug`, …).

## 4. Call it

Noul — how true a statement is, 0..1:

```sh
jev --state "スーパーでソーセージと食パンを買った。" \
  --noul grocery="この日記は「買い物: ソーセージ、食パン」が済んだことを述べている" \
  --noul kenshin="この日記は「健康診断の予約を取る」が済んだことを述べている"
```

```json
{"grocery": {"type": "noul", "noul": 0.98}, "kenshin": {"type": "noul", "noul": 0.01}}
```

Long state: `--state-file note.md`, or `--state-file -` to read stdin.

Choice and score questions go in `--questions` as a JSON object and are sent
as given; their answers carry `confidence` and `probabilities` as well. Check
the current field names in the TypeSafe docs before writing one — they have not
been exercised from here yet, and `--dry-run` shows the exact body that would be
sent without needing the key:

```sh
jev --state-file - --questions '{"route": {"type": "choice", ...}}' --dry-run < input.txt
```

stdout is the `answers` object, one key per question name, so it pipes into
`jq`. Exit 0 means Jev answered; 2 means it was not asked or the call failed
(the reason is on stderr); 1 is a usage error.

## 5. Use the answers

- **Gate with a threshold, and pick the threshold from what a miss costs.** When
  the output only narrows what you then confirm with the user, lean low — a
  missed candidate is worse than an extra one. When it triggers an action
  without a person, lean high.
- **Use confidence to split "act" from "ask".** Confident answers proceed;
  middling ones go to the user.
- **Jev narrows; it does not decide on its own** for anything the user would
  otherwise have confirmed. Keep the existing confirmation step.

Report what was asked, the scores, and the threshold applied. On exit 2, report
that Jev was not used and why, in those words.

Background and measurements: `brainstorm/dev/jev.md` in the kanban repository.
