---
name: handoff-ritual
description: Close out a Gloom Suite session cleanly. Invoke whenever the owner says "do the handoff ritual", "handoff ritual and release", "let's close out", or otherwise signals the session is ending. Updates every suite document that needs it, commits and pushes each repo touched, and optionally cuts releases. Also invoke before starting an unrelated new task in a long session.
---

# The handoff ritual

**The owner should never have to know which documents exist or what needs updating. That is the
entire point of this checklist.** He says the phrase; you do all of it.

**"Do the handoff ritual"** → steps 1–8.
**"Do the handoff ritual and release"** → steps 1–8, then step 9.

Run every step. Skipping one silently is how the next session starts confused. If a step genuinely
doesn't apply, say so in the final report rather than omitting it.

---

## 1 · Take stock

```bash
for d in ~/GloomsHub ~/GloomsBars ~/GloomsAuras ~/GloomsOverlays; do
  echo "=== $d ($(git -C $d rev-parse --abbrev-ref HEAD)) ==="; git -C $d status --short
done
```

Write down, for yourself: **what actually changed this session, what was proved, what was
disproved, and what is left unfinished.** Everything below is bookkeeping against that list.

⚠ Branches differ: Hub and Overlays are on `master`, Bars and Auras on `main`. Don't assume.

---

## 2 · `docs/BACKLOG.md` — the file the next session opens with

- **Close what closed.** Delete the item from the open list and move its record to `ARCHIVE.md`. Do
  not leave a struck-through corpse in the backlog; that is how it grew to 573 lines last time.
- **Add what survived unfinished** — with its repo, a size estimate, an evidence tag, and a
  **"Read first"** list naming the exact files the next session needs. The reading list is what
  makes deferred context-loading work; an entry without one is broken.
- **Add anything he decided against** to the "Not open" section, so nobody re-raises it.
- Update **Last updated**.
- **Size check: if the open list passes ~80 lines, something belongs in the archive.**

---

## 3 · `docs/FINDINGS.md` — diagnosis, with evidence

- Every new claim gets a tag: **`TESTED`** (say how, when, on what) · **`OBSERVED`** (symptom seen,
  cause unproven) · **`SUSPECTED`** (reasoning only) · **`KILLED`**.
- **Anything disproved this session gets struck through by name and moved to that finding's
  `KILLED` list. Never delete it** — a silently removed theory gets re-derived by the next session.
- **Upgrade tags that earned it.** If a `SUSPECTED` claim was proven this session, say so and state
  the test. This is the step that stops confidence laundering.
- A finding that is fully solved and shipped stays here only for its `KILLED` list; everything else
  about it moves to `ARCHIVE.md`.

---

## 4 · `docs/SUITE-STATE.md` — settled facts only

Update **only if settled state actually moved** — a phase closed, a locked decision was made, a
version shipped, something physical changed on disk.

- **Do not append a "before that…" clause.** Rewrite the affected line. The previous version of this
  file accumulated a 35-line paragraph of stacked history that nobody re-read, which is precisely
  why nothing in it was ever corrected.
- Anything closed moves to `ARCHIVE.md`.
- **Size check: if it passes ~180 lines, archive something.**

---

## 5 · `docs/LESSONS.md` — durable traps

Add anything that cost real time and **will cost it again**. Write it generally enough to apply next
time. If a lesson stopped being true, delete it — a stale warning is worse than none.

Not every session produces one. Don't manufacture entries.

---

## 6 · `docs/CONTRACTS.md` — only if a shared contract moved

If `LibGloomSkin`, the tab API or the resolver changed: update CONTRACTS **and every consumer, in
this same session.** Check that any consumer calling a newer widget had its `SKIN_NEEDS` bumped in
the same commit — forgetting is the only way to defeat the version gate.

---

## 7 · The owning repo's own docs

If the work was Bars', Auras' or Overlays', update **that repo's** `docs/HANDOFF.md` with the detail
— the tool-specific reasoning, frozen decisions and gotchas live there, not here.

**Point, never copy.** Suite-wide facts (release state, phase status, contracts) live only in the
Hub. A restated fact goes stale: release state was once copied into three sibling docs and all three
were wrong within a day.

---

## 8 · Commit and push

**This is authorized standing — the ritual phrase IS the ask. Do not stop to confirm.**

Commit **each repo separately**, with a message describing what changed in that repo.

⚠ **PRIVACY, before every commit:** no real name, no personal GitHub handle, in content or in the
message. Git identity must be `Gloom <gloom@handofdevastation.invalid>` — never override per-repo,
and never use a `…@users.noreply.github.com` address (it embeds the handle).

```bash
git -C <repo> add -A && git -C <repo> commit -m "<message>" && git -C <repo> push
```

Then **report back in plain language**: what changed, in which repos, what was pushed, and what the
next session will find waiting. He is not a developer — no jargon dump, no file listing without
explanation.

---

## 9 · The release cut — only on "and release"

Release **only the addons that actually changed**. Versions drift by design; do not "fix" the others.

1. **Confirm what changed** since each repo's last tag: `git -C <repo> log <lasttag>..HEAD --oneline`.
2. **Bump `SKIN_NEEDS` first** if the tool started calling a newer `LibGloomSkin` widget, and make
   sure that landed in the same commit as the call.
3. Tag and push: `git -C <repo> tag vX.Y.Z && git -C <repo> push origin vX.Y.Z`.
4. **Confirm the workflow actually ran.** A tag pushed too close to a branch push can land before
   the workflow registers and silently trigger nothing:
   `gh api repos/GloomSuite/<repo>/actions/runs --jq '.workflow_runs[0] | {name, status, conclusion}'`
5. **Verify `latest` ANONYMOUSLY** — it is what WoWup installs, and it breaks if releases land out
   of order. That endpoint caches, so re-read a stale answer before chasing it:
   `curl -s https://api.github.com/repos/GloomSuite/<repo>/releases/latest | grep tag_name`
   Fix with `gh api -X PATCH repos/GloomSuite/<repo>/releases/<id> -f make_latest=true`.
6. Update the version in `SUITE-STATE.md` and tell him which addons moved and which deliberately
   did not.

---

## What this ritual is guarding against

The 2026-07-26 near-miss: a finding was recorded confidently, was wrong, and was never revisited
when the evidence changed. A session came within one step of building a fix for a bug that did not
exist. **Steps 2 and 3 are the ones that prevent a repeat** — closing what closed, and marking down
what was disproved. Do not treat them as paperwork.
