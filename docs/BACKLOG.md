# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-08-15 (GB's profile model reworked after the owner found it confusing — New
now means the factory look, and a real bug was found and fixed: per-character profiles were never
loaded at login. New item 5 holds what is still unverified.)

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

### 5 · Finish verifying GB's profile rework
**Repo:** `~/GloomsBars` (+ Hub's `Skin.lua`) · **Size:** ten minutes of clicking · **Evidence:** `UNTESTED`

The 2026-08-15 rework is **shipped and partly owner-QA'd**. Confirmed in game: the rail layout, the
factory look on a new character's first login, and no data loss across a reload. What was NOT
exercised:

- **The New button itself.** It calls the same `GB:DefaultPreset()` that Gloomhill's login proved
  works, so this is likely fine — but nobody has clicked it. Expect circles.
- **Rename with the name unchanged** — should now be a silent no-op, not "already exists".
- **A name typed with a leading/trailing space** — should be trimmed (this is in the Hub's shared
  `nameDialog`, so it affects GA and Overlays too).
- **Delete** — should print which profile the character landed on.

⚠ **One open DESIGN question the owner has not answered:** he said a new profile should look "like
the default UI", and what it produces is **GB's** default — circles. Blizzard's stock buttons are
square. Circles were kept (round icons are the addon's whole point) and it is a one-line change in
`GB:DefaultPreset()` if he wants otherwise. **Ask; do not change it unprompted.**

**Read first:** `~/GloomsBars/docs/HANDOFF.md` (the 2026-08-15 block) · [FINDINGS.md](FINDINGS.md) §11

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **"GB's per-character profiles don't work / my alt looks wrong"** — **FIXED 2026-08-15**, FINDINGS
  §11. Login never loaded the bound profile. ⚠ The old bug already overwrote some saved presets;
  a character may look wrong ONCE after the fix, then stay stable. That is not a new bug.
- **GB profile New vs Copy** — **SETTLED 2026-08-15.** New = the factory look; Copy = a full
  duplicate of the active profile. GA and Overlays already worked this way; GB was the outlier and
  now matches. Do not "restore" New to snapshotting the current look.
- **GB's PRESET block being orange and at the bottom of the rail** — **the owner asked for it**
  (2026-08-15) so the two blocks stop reading as one control. Not a mistake, not a token drift.
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
- **Distribution to friends/guild** — not ready; the owner will say when.
- **The user's own media shipping in the addon** — FIXED and purged. **Never re-track them.**
- **The colour picker** — **FULLY owner-QA'd.** IN USE holds the USER's colours; it is not modal.
