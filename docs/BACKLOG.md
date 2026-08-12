# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-08-12 (item 1 BUILT and owner-QA'd — GA has duration bars on 12.1; item 4
closed to its evidence-backed half; 12.1 went live and all four TOCs were bumped)

---

## Open items

### 1 · Finish GA's bar coverage — Corruption + UA, and confirm the UI route
**Repo:** `~/GloomsAuras` · **Size:** small · **Evidence:** `UNTESTED` (code written, never run)

The duration engine is **built and owner-QA'd** — Agony and Haunt drain correctly on 12.1 with
stack counts, and the whole Bar section exists in the Auras tab. What is left is coverage:

- **Corruption and Unstable Affliction have no bars at all.** They are texture displays.
- **The last change of the session was never tested.** `CDM:DisplaySpellID` now resolves a
  display's spell from its first TRIGGER when there is no `cfg.spellID`, which is the shape of
  every display built in the Auras tab. It is wired into five call sites (`AuraDuration:Attach`,
  `CandidateSpellIDs`, `BarSource`, `BarStackValue`, the `cd_dur` feed). **Before this, a bar
  created in the UI could never get a duration** — `/ga bar <spellID>` was the only working route,
  and the owner has said he will never use a command.

**The test:** + New Aura → Bar Aura → set its Aura Trigger to Corruption → cast it. The bar should
fill and drain with no slash command anywhere. Then the same for UA.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md` (the 2026-08-12 block) · [FINDINGS.md](FINDINGS.md) §1

---

### 2 · The rest of the 12.1 exposure sweep — now on LIVE
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

**12.1 went live 2026-08-11.** Everything below was written against the PTR.

- **Real instanced content** — dungeon / M+ / raid. Every test so far, across three sessions, has
  been open-world on a training dummy. Aura secrecy covers encounters, M+ and PvP, not just combat,
  and nobody has tested whether `AddAuraSlot` behaves the same under encounter secrecy.
- **GB's skinning hooks** — the *layout* hooks are proven alive (all 40, measured 2026-07-26). The
  skinning side is still untested.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).
- ~~Stacks under secrecy~~ — **SOLVED 2026-08-12.** See FINDINGS §1.

⚠ **The old "check the PTR addon list, it has drifted" warning is RETIRED.** FINDINGS §4 records
the truth: EllesmereUI **is** the owner's UI, the one colliding module has been off since July, and
telling him to disable things is how a session wastes his evening. Read §4 before touching the client.

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

### 3 · GA's `/ga probe` leaks frames on charge spells
**Repo:** `~/GloomsAuras` · **Size:** one small fix · **Evidence:** `TESTED`

`CDM.lua`'s charge-spell probe creates two fresh `CooldownFrameTemplate` frames per capture with no
`SetSize`/`SetDrawEdge`/`SetDrawBling`, so each click paints a screen-wide gold wedge and parks two
more frames. `_ProbeShadows` already pools correctly — copy it.

⚠ **The owner has explicitly deprioritised this** (2026-08-12): it is a dev diagnostic, it cannot
bite a Warlock, and he does not want to hear about it unless it affects normal play. Fix it silently
if you are in the file; do not raise it.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md`

---

### 4 · Why does `ApplyConfig` run so hot?
**Repo:** `~/GloomsAuras` · **Size:** unknown, probably small · **Evidence:** `OBSERVED`

`AuraDuration:ApplyStyle` was seen firing **dozens of times for a single user action**, and 600
deferrals accumulated in one short combat. A redundant-push guard now absorbs it, but the guard
treats the symptom — the underlying question of why `ApplyConfig`/`UpdateBar` re-run that often was
never established. Worth knowing before anything else expensive is hung off that path.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md`

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **GA duration bars on 12.1** — **BUILT and owner-QA'd 2026-08-12** via `AuraContainer`. Mechanism
  and traps in FINDINGS §1 and `~/GloomsAuras/docs/HANDOFF.md`. Do not redesign it.
- **The Tracked-Bar mirror** (`BarMirrorValues`, `StartMirror`/`StopMirror`) — **DELETED 2026-08-12.**
  It worked but needed a per-aura Blizzard config step. **Do not rebuild it**; FINDINGS §1.
- **A display not returning after a mid-combat `/reload`** — **CLOSED, not fixable through the
  presence mirror.** `TESTED` over 52 passes: the CDM never binds an already-applied aura to its
  item frame after a reload. Three fixes were attempted and all three failed. FINDINGS §1.
- **`GetValidAlertTypes` as a general "can this trigger fire?" oracle** — **NO.** It reports Agony
  as unable to do apply/remove, which is false. Only its *pandemic* column matches observation.
  FINDINGS §10.
- **How ArcUI does DoT timers** — **SOLVED**, FINDINGS §1. Do not reverse-engineer it again.
- **Combat-log / self-timed duration bars** — **do not build.** FINDINGS §1, option 2.
- **"GA is broken in combat on 12.1" / "the Warlock profile is broken"** — **FALSE**, FINDINGS §1.
- **`GetPlayerAuraBySpellID` as the deciding test** — **tested, returns `nil`**; player-only.
- **The damage-meter Lua error storm** — **NOT OUR BUG** (FINDINGS §9). Do not re-diagnose.
- **Quick Keybind Mode "blocked by GB's skin"** — **CLOSED, not a GB bug** (FINDINGS §8).
- **GB's per-action icon overrides (`GB.Icons`)** — **SHIPPED and owner-QA'd.** No config UI wanted.
  **Do not build tooling to find icon art.** ⚠ `IconsHD/` is git-ignored and `IconsManifest.lua`
  ships EMPTY — the mechanism ships, the owner's art does not. **Never commit a populated manifest.**
- **GB's icon zoom applying to every preset** — **FIXED and owner-QA'd 2026-07-26.**
- **MM Hunter auras on 12.1** — **TESTED and SAFE** (FINDINGS §7). Do not re-test.
- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner.**
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**; do not re-flag.
- **Distribution to friends/guild** — not ready; the owner will say when.
- **The false `SetFont` guard** — FIXED (FINDINGS §5). **`ForceTaint_Strong`** — CLOSED (§6).
- **The user's own media shipping in the addon** — FIXED and purged. **Never re-track them.**
- **General Sans's redistribution terms** — **CLOSED by the owner**; attribution ships.
- **The colour picker** — **FULLY owner-QA'd.** IN USE holds the USER's colours; it is not modal.
