# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-26 (evening — colour picker shipped AND fully QA'd; font-licence closed)

---

## Open items

### 1 · GA loses all aura detail in combat on 12.1 ★ the big one
**Repo:** `~/GloomsAuras` · **Size:** a migration, not a patch · **Evidence:** `TESTED` (2026-07-25)

In combat 12.1 returns aura instance IDs as SECRET, and every read call throws. GA keeps aura
*presence* but loses duration, stacks and expiry. Fails silently — BugSack stays clean while
nothing renders. Three escape routes were tested and all are closed.

**Deferred by the owner (2026-07-25): wait for 12.1 launch, then triage.** He is switching to
Hunter for Season 2 and the cooldown path is unaffected, so this does not block him. Do not
re-litigate the timing.

**Read first:** [FINDINGS.md](FINDINGS.md) §1 · `~/GloomsAuras/CLAUDE.md` ·
`~/GloomsAuras/docs/API-NOTES.md`
**Shape:** deep design work inside one tool — the one case that genuinely earns a session of its own.

---

### 2 · MM Hunter auras never tested on the PTR
**Repo:** test only, no code · **Size:** ~10 minutes in-client · **Evidence:** `UNTESTED`
**Deadline: before Season 2 opens (~2026-08-19).**

"Hunter still works" was proven for **SV only, with two auras**. Precise Shots and Spotter's Mark
may be buff-duration driven rather than cooldown driven — which would put them squarely on item 1's
broken path, on the spec the owner is actually playing.

**Read first:** [FINDINGS.md](FINDINGS.md) §1 and §4 (PTR setup + the profile trap)
**Note:** the PTR is set up and ready; re-testing costs nothing but a launch.

---

### 3 · The 12.1 exposure sweep is unfinished
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

Three gaps remain from the PTR pass:
- **GB's ~40 `hooksecurefunc` calls vs the Forbidden Aspects lockdown.** The *layout* hooks are
  now proven alive (all 40 installed and firing, measured 2026-07-26). The **skinning** hooks have
  never been exercised beyond a normal login.
- **Real instanced content** — dungeon / M+ / raid. All testing so far was open-world on a dummy.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner**; do not re-propose.
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**; do not re-flag.
- **Distribution to friends/guild** — not ready; the owner will say when. Don't push it.
- **The false `SetFont` guard** — FIXED, owner-QA'd 2026-07-26. It was NOT a tidy-up: FINDINGS §5's
  `KILLED` list has why that reasoning was wrong.
- **`ForceTaint_Strong` on a dead font path** — CLOSED, no action (FINDINGS §6). **Do not re-raise
  without a real symptom.**
- **The user's own media shipping in the addon** — FIXED 2026-07-26; `Fonts/`, `Textures/`,
  `Graphics/` are gitignored and purged from history. **Never re-track them** (`.pkgmeta` says why).
- **v1.2.0 release cut** — DONE, all four published, Hub zip verified clean. **A packaging failure
  on `repos.wowace.com` is an outage — re-run, don't debug.**
- **General Sans's redistribution terms** — **CLOSED by the owner 2026-07-26 without verifying
  the Fontshare terms.** The attribution the fonts themselves ask for ships in
  `Media/fonts/FONT-LICENSES.md`; that is where it rests. Do not re-raise it as a task.
- **The colour picker's palette holding the suite's own tokens** — **REJECTED by the owner
  2026-07-26.** It shipped that way first and was wrong: the row holds the colours the USER put on
  their own elements, never purple/orange/plate. Don't "helpfully" seed it with the design language.
- **Making the colour picker modal** to match the other dialogs — **NO.** It edits a live element;
  see SUITE-STATE's locked decisions.
- **The colour picker** — **FULLY owner-QA'd 2026-07-26, every path.** Opacity row, the panel
  growing downward, GA's cancel-back-to-unset, and closing the Suite window out from under it all
  passed. Nothing about it is outstanding.
