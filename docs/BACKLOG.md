# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-26 (evening — after the PII scrub and the SetFont fix)

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

### 4 · General Sans's redistribution terms were never verified
**Repo:** all four that ship fonts · **Size:** ~15 minutes, reading · **Evidence:** `UNTESTED`

The suite bundles **Khand** (SIL OFL 1.1 — `Media/fonts/OFL.txt` now ships alongside it, which is
what the OFL requires) and **General Sans** (Indian Type Foundry / Fontshare). The credit
requirement embedded in the General Sans files is satisfied by `Media/fonts/FONT-LICENSES.md`.

**What is NOT established: whether the Fontshare licence permits redistributing the .ttf files
inside a product zip at all**, as opposed to using the typeface. `https://fontshare.com/terms` is
JS-rendered and could not be retrieved by any tool available in-session, so nobody has read it.
Both fonts are free and this is very likely fine — but "likely" is not "read it."

**Read first:** `~/GloomsHub/Media/fonts/FONT-LICENSES.md` · the embedded terms are recoverable
from any bundled `.ttf` via its `name` table (IDs 13 and 14).

---

## Not open — recorded so nobody re-raises them

- **GB's bar-position bug** — SOLVED and shipped 2026-07-26 (`afd0957`). Was never a 12.1 issue.
- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner**, do not re-propose.
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**, do not re-flag or propose a fix.
- **Overlays logo placement inside the tab** — closed at Phase E gate B; a mark + wordmark in the
  rail, not a splash.
- **Distribution to friends/guild** — the owner considers the suite still in active development and
  is not ready. Don't push it.
- **"A missing font kills the whole GA display"** — FIXED and QA'd 2026-07-26. Record in
  [ARCHIVE.md](ARCHIVE.md); the traps it left behind are FINDINGS §2 and LESSONS.
- **The false `SetFont` guard in the Hub and GB** — FIXED and owner-QA'd 2026-07-26. It was NOT the
  tidy-up this list claimed; see FINDINGS §5's `KILLED` list for why that reasoning was wrong.
- **The `ForceTaint_Strong` on a dead font path** — CLOSED 2026-07-26, no action. Tested through
  GB's skin path across 116 buttons in combat; no symptom. FINDINGS §6. **Do not re-raise without
  a real symptom.**
- **The user's own media shipping inside the addon** — FIXED 2026-07-26. `Fonts/`, `Textures/` and
  `Graphics/` are gitignored drop-in directories and were purged from all history. Do not re-add
  them; `.pkgmeta` explains why at length.
