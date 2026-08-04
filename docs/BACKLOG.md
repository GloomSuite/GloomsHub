# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-08-03 (item 1 ANSWERED and rewritten as an implementation job — the route is
`AuraContainer`; item 3 half-fixed; one small item added)

---

## Open items

### 1 · Give GA duration bars back on 12.1, via `AuraContainer` ★ the big one — now a BUILD job
**Repo:** `~/GloomsAuras` · **Size:** real but bounded, with a working reference to copy
**Evidence:** `TESTED` 2026-08-03 — the route is proven working; GA just doesn't use it yet

**The investigation is OVER. Do not re-open it.** 2026-08-03 established, on screen and by probe:
presence displays already work; the aura *data* APIs are dead; and **Blizzard's `AuraContainer` is
the sanctioned route that makes durations work anyway** — proven by ArcUI doing exactly this on the
owner's own client with zero aura reads.

**The job:** add an XML button template to GA (it ships none today), create one `AuraContainer` per
unit **out of combat**, add a spell-ID-filtered slot per tracked aura, and inside `initializeFrame`
— and nowhere else — call `SetDurationBar` / `SetDurationText` on regions the **button** owns, then
anchor it over GA's own display.

⚠ **FINDINGS §1's ANSWERED block has the full mechanism, the exact API sequence and the traps.
Read it first; it is the deliverable of a whole session and re-deriving it would be expensive.**

**Also decide:** whether to keep the Tracked-Bar mirror built on 2026-08-03 (`CDM:BarMirrorValues`
+ `Displays.lua` StartMirror). It **works** but needs a per-aura Blizzard config step, so it is
strictly worse than `AuraContainer`. Keep as fallback or bin it — the owner has not been asked.

**Read first:** [FINDINGS.md](FINDINGS.md) §1 (the ANSWERED block, then the `KILLED` list) ·
[FINDINGS.md](FINDINGS.md) §10 (the alert events) · `~/GloomsAuras/CLAUDE.md` ·
`~/GloomsAuras/docs/HANDOFF.md` · reference implementation:
`_ptr_/Interface/AddOns/ArcUI/Bars/ArcUI_BarDuration.lua` **and its `.xml`**

---

### 2 · The rest of the 12.1 exposure sweep
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

- **GB's skinning hooks** — the *layout* hooks are proven alive (all 40, measured 2026-07-26). The
  skinning side is still untested by the sweep itself.
- **Real instanced content** — dungeon / M+ / raid. All testing so far has been open-world on a
  dummy, in both the 07-26 and 08-03 sessions.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).
- **Stacks under secrecy** — untested via `AuraContainer`; the old read path is dead like durations.

⚠ **The old "check the PTR addon list, it has drifted" warning is RETIRED.** FINDINGS §4 now records
the truth: EllesmereUI **is** the owner's UI, the one colliding module has been off since July, and
telling him to disable things is how a session wastes his evening. Read §4 before touching the client.

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

### 3 · GA's `/ga probe` still leaks frames on charge spells
**Repo:** `~/GloomsAuras` · **Size:** one small fix · **Evidence:** `TESTED`

Half of this item was fixed 2026-08-03: **`spec=?` in the header is done** (it now falls back to the
spec ID when 12.1 returns an empty name). **Still open:** `CDM.lua`'s charge-spell probe creates two
fresh `CooldownFrameTemplate` frames per capture with no `SetSize`/`SetDrawEdge`/`SetDrawBling`, so
each click paints a screen-wide gold wedge and parks two more frames. `_ProbeShadows` already pools
correctly — copy it. Harmless on a Warlock (no charge spells); it bites on charge classes.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md`

---

### 4 · Warn when a sound trigger can never fire
**Repo:** `~/GloomsAuras` · **Size:** small · **Evidence:** `TESTED` (the failing case is real)

The owner's Unstable Affliction display has a sound set to `pandemic`, and **UA emits no
`PandemicTime` event at all** (it stacks, so it has no refresh window). The sound can never play and
nothing says so. `CDM.lua:1268`'s `alertsFor()` already reads `GetValidAlertTypes`, so the Auras tab
could grey out or flag an impossible trigger. **His UA sound is still mis-wired — his call whether
to move it to apply/remove.**

**Read first:** [FINDINGS.md](FINDINGS.md) §10

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **How ArcUI does DoT timers** — **SOLVED 2026-08-03, written up in FINDINGS §1.** It uses
  `AuraContainer`. **Do not reverse-engineer it again**; three wrong theories were produced and
  discarded on the way, and they are struck by name in §1's `KILLED` list.
- **Combat-log / self-timed duration bars** — **do not build.** It was the fallback for a wall that
  turned out not to exist, and it drifts on pandemic refreshes and haste. FINDINGS §1, option 2.
- **"GA is broken in combat on 12.1" / "the Warlock profile is broken"** — **FALSE**, struck in
  FINDINGS §1. Presence displays work end to end. Do not repeat it.
- **`GetPlayerAuraBySpellID` as the deciding test** — **tested, returns `nil`**, and it is
  player-only so it could never have served target DoTs. FINDINGS §1.
- **The damage-meter Lua error storm** — **NOT OUR BUG** (FINDINGS §9). Blizzard's own meter under
  any addon taint. Owner is filing it. Do not re-diagnose.
- **Quick Keybind Mode "blocked by GB's skin"** — **CLOSED, not a GB bug** (FINDINGS §8). Don't
  re-raise without a fresh reproducible symptom, and measure with `GetMouseFoci()`, never `/fstack`.
- **GB's per-action icon overrides (`GB.Icons`)** — **SHIPPED and owner-QA'd.** No config UI wanted;
  the folder watcher is written but deliberately not installed. **Do not build tooling to find icon
  art** — Wowhead is faster, and a script for it was written and deleted the same day.
- **GB's icon zoom applying to every preset** — **FIXED and owner-QA'd 2026-07-26.**
- **MM Hunter auras on 12.1** — **TESTED and SAFE** (FINDINGS §7). Do not re-test.
- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner.**
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**; do not re-flag.
- **Distribution to friends/guild** — not ready; the owner will say when.
- **The false `SetFont` guard** — FIXED (FINDINGS §5). **`ForceTaint_Strong`** — CLOSED (§6).
- **The user's own media shipping in the addon** — FIXED and purged. **Never re-track them.**
- **General Sans's redistribution terms** — **CLOSED by the owner**; attribution ships.
- **The colour picker** — **FULLY owner-QA'd.** IN USE holds the USER's colours; it is not modal.
