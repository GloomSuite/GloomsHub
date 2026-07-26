# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-26

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

### 4 · The same false `SetFont` guard is still in the Hub and GB
**Repo:** `~/GloomsHub` + `~/GloomsBars` · **Size:** small · **Evidence:** guard `TESTED` wrong,
exposure `SUSPECTED` low

GA's fix left the identical `if not fs:SetFont(...)` guard in `~/GloomsHub/Skin.lua:70`
(**`UI.setFont`, the shared toolkit**) and `~/GloomsBars/Config.lua:190`/`:220`.

**Probably NOT urgent — establish this before treating it as a bug.** GB and the Hub resolve fonts
by **LSM name** with a bundled fallback, so a missing addon yields a *valid* path; GA was exposed
only because it stores the raw **path**. Check whether any caller can hand `UI.setFont` a saved
path at all. Also unchecked: **GA's three `.ogg` sound paths** into `ArcUI`/`EnhanceQoL`.
**Read first:** [FINDINGS.md](FINDINGS.md) §5 · `~/GloomsHub/Skin.lua` around line 70

---

### 5 · A missing font asset force-taints the execution path
**Repo:** unknown — diagnosis first · **Size:** unknown · **Evidence:** `OBSERVED` (2026-07-26)

`SetFont` on a dead path printed `Lua Taint: *** ForceTaint_Strong ***` alongside the error.
**`pcall` catches the error but not the taint**, so GA's fix leaves this open. No consequence has
been demonstrated — it matters only because the suite leans hard on taint behavior elsewhere.
**Do not write a fix until a real symptom exists.**
**Read first:** [FINDINGS.md](FINDINGS.md) §6

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
