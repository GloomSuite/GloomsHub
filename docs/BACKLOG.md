# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-20, evening (**a clearing session — twelve items closed.** GU went
PROFILE-BASED (item 14, owner-QA'd), `GloomSuite/GloomsUnitFrames` now EXISTS on GitHub, the
profile delete gate names the characters on a profile (Hub MINOR 10, with Tab / Shift-Tab and
Up / Down on every edit box), GA's `ApplyConfig` heat was measured and fixed, the silent-yes engine
fix was DISPROVED by trace and replaced with a list-row mark, texture-less auras show their spell's
icon, `hgAnchor` has one copy, DK runes work. **GU's "This spell" kind was REMOVED by the owner**:
the engine ignores spell-ID filters on the PLAYER's DEBUFFS (FINDINGS §20.6), so it could never
single out a debuff. What is left is bigger — start fresh.)
---

## Open items

### 12 · Gloom's Unit Frames — what is left
**Repo:** `~/GloomsUnitFrames` (on GitHub since 2026-09-20) · **Size:** watching, then small pieces · **Evidence:** everything shipped is owner-QA'd

**Done 2026-09-20:** profiles (item 14) · the GitHub repo · DK runes (via `GetRuneCooldown`, class
red) · the aura-group PREVIEW (sample icons from the spellbook while the Auras section is open) ·
the shape-mask bind no longer errors when a button is wired mid-fight · the spell-list boxes
round-trip by ID and are greyed where the engine ignores them.

**Left, in order:**
1. **The shield wash switching OFF** — still only ever seen on the probe square (§19). The owner
   will watch for it in the next raid.
2. **Aura filter CLASSES** beyond timed-only and cast-by-you (boss, dispellable, the dispel types,
   CC…) — same engine path, `UNTESTED` individually; he will use them in the real world and report.
   ⚠ Spell-ID lists on a PLAYER Debuffs group are DEAD (§20.6) — that is not one of these.
3. **The aura PREVIEW's alignment** — it reproduces the engine's flow rules (icon rect, spacing,
   wrap, growth, anchor corner) with our own textures; nobody has yet compared it against a live
   group pixel-for-pixel. If it is off, it is a one-number correction in `LayoutAuraPreview`.
4. **The mid-cast tint and kick tick under secrecy** — off for an instanced target by design
   (the cast's clock is secret). Park unless he asks.
5. **The Gu mark** in the tab header is still the Hub's logo. Art, not code.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` · [FINDINGS.md](FINDINGS.md) §18–§20

---

### 13 · The Unit Frames tab — the tidy pass after the compaction
**Repo:** `~/GloomsUnitFrames` (the tab) · **Size:** an hour, once he has a mock · **Evidence:** landed and owner-QA'd 2026-09-20 — "a little messy, we can clean up later"

The compaction shipped: every section body is a `UI.grid` (two cells per line), the deep clusters
sit behind `UI.cog` popovers, one-line conditionals appear inline under their switch, the shortcode
list is a popover that inserts on click. What is left is the LOOK — spacing, which pairs sit
together, label widths — and **the owner said he might make a mock**; ask for it before touching
anything. Do not redesign the mechanism. Two things he called confusing today, worth folding in:
the filter popover differs by kind (now titled "FILTERS — BUFFS / DEBUFFS"), and the rail's PROFILE
block sits above UNITS with nothing separating the two.

**Read first:** `~/GloomsUnitFrames/GloomsUnitFrames_Tab.lua` (the header comment explains the
three tiers) · [CONTRACTS.md](CONTRACTS.md) §4 (`UI.grid` / `UI.popover` / `UI.cog`)

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **GU's "This spell" aura kind (one aura by spell ID, wearing a Hub effect)** — **REMOVED by the
  owner 2026-09-20.** On the player, the engine ignores `includeSpellIDs` AND `excludeSpellIDs` on
  HARMFUL auras — measured through a slot and a group, in either creation order, with a fresh filter
  table, against a permanent zone debuff (Void Breach) and a timed self-debuff (Blood Draw); the
  HELPFUL side and GA's HARMFUL slots on the TARGET filter correctly (FINDINGS §20.6). *"It needs
  to be able to track specific DEBUFFS to be of any value."* The Hub-effect-under-a-button machinery
  went with it, which is why **item 15 (Effects animating in combat) is CLOSED as moot** — nothing
  in the suite runs an effect under an aura button any more. The tab greys the spell-list boxes on a
  player Debuffs group and says why. **Do not rebuild it on the same engine call.** The "boss debuff
  on me" job is a Debuffs group with the *Boss debuffs* class filter.
- **An automatic "is the spell known?" check to fix the silent yes (item 6)** — **DISPROVED by trace
  2026-09-20**, FINDINGS §12: a bound, WORKING Corruption bar answers `known=no` on all three calls
  (it is keyed on the debuff's ID). Any known-check would hide working auras. The owner's
  Spell / Talent Known condition stands, and the Auras list now marks an aura whose cooldown trigger
  points at an UNBOUND spell (the `!` next to the eye) so the next Soul Fire warns before it fires.
- **"Why does GA's `ApplyConfig` run so hot?" (item 4)** — **ANSWERED and FIXED 2026-09-20**,
  FINDINGS §1 addendum: `UpdateBar` re-attached on every feed and cleared the style fingerprint, so
  every UNIT_AURA repainted every shown bar (1,165 pushes in a 30s dummy fight). The guard now keys
  on the painted BUTTON + style; after the fix, 3,227 skipped / 0 deferred. `/ga hot on` is the
  instrument, off by default.
- **A texture-less aura drawing magenta (item 9)** — **RULED and FIXED 2026-09-20**: it shows its
  spell's icon; an explicit texture always wins. Same resolver in the list rows.
- **`hgAnchor` in two places (item 10)** — **COLLAPSED 2026-09-20.** GB delegates to the Hub's
  `GrowAnchor`; the bodies were diffed identical first, the owner looked, nothing moved.
- **Items 1, 2, 5, 7, 8** — all **CLOSED 2026-09-20** on owner evidence (bars, raids for weeks,
  GB's profile clicks, the power condition on a Rogue incl. a group, `/ga debug`). ARCHIVE has it.
- **Settings changing MID-COMBAT, in GU** — the owner, 2026-09-20: *"People don't do that.
  Whether it updates mid-fight doesn't matter, as long as a change does at least go through after
  combat ends."* **Said for GU only — he corrected a suite-wide reading.** Do not QA GU's
  container rebuilds in combat; do make sure a refused write is replayed at regen.

- **"An absorb ARC on the health ring"** — **NOT POSSIBLE, measured 2026-09-19**, FINDINGS §19:
  no absorb-percent function exists, a curve refuses to evaluate a secret, and `UnitHealthPercent`'s
  flag does not include absorbs (34 / 34 with a 292K shield). What shipped is the shield WASH
  (presence via the plain-zero-then-secret alpha gate) and `[absorb]` as text. Reopen only on a new API.
- **"Start an aura icon's glow from the button's OnShow / from a child's OnUpdate"** — **NO**,
  FINDINGS §20: no script under an aura button ever fires and its `IsShown` is a secret boolean.
  Effects start at wiring time and live under the button; the Hub's modules verify their mask bind.
- **Class color + gradient on the health fill** — **mutually exclusive by the owner's call**
  (2026-09-19): a gradient wins, and the switch hides in gradient mode. Do not blend them.
- **A GA display as the "boss debuff on me" highlight** — **not the answer**: GA's displays are
  CDM-trackable auras; a boss debuff is not one. The GU "This spell" aura group is the tool for it.

- **"Draw the unit-frame rings with `SetGradient`, or hide an empty piece with alpha 0, or
  position anything with a secret"** — **NO, all measured 2026-09-19**, FINDINGS §18. A texture with
  `SetGradient` ignores a secret alpha; a secret alpha of exactly ZERO is ignored everywhere;
  `SetPoint` accepts a secret and drops it. The engine's gradient is a ramp *layer*, "empty" is
  geometry, and nothing is positioned by a value.
- **"A cast ring could use the Cooldown swipe"** — **never needed** (2026-09-20): the player's times
  are plain, and a target's fully secret cast draws through the duration object's percent
  evaluators on the ring's own curves (§18.10). Do not reach for the swipe.
- **"The cast ring hides when a target's total is secret"** — **KILLED 2026-09-20**, §18.10. The
  total is secret in every delve cast and the ring draws anyway.
- **Gloom's Unit Frames staying account-wide** — **RULED WRONG by the owner and REPLACED 2026-09-20.**
  Profiles ship (`GloomsUnitFramesDB` v2: a library + per-character bindings; the old config became
  "Default", which every unbound character lands on). Do not argue for the old shape.
- **"Rings over 180° can be one piece"** — **NO.** Masks only subtract; two chunks, overlapped by a
  hard-edged start mask. §18.

- **"Show the 3D model of an enemy targeted mid-combat in an instance"** — **NOT POSSIBLE, measured
  2026-09-19** (FINDINGS §17). On a restricted map the game identifies ONE unit for an addon: the
  target, out of combat. Nameplate units and mouseover are secret even before the pull; `SetUnit`
  on any of them loads nothing. What ships is the ceiling: 3D out of combat, 3D for a mob targeted
  before the pull when tabbed back to (nameplate-matched, `SetCreature`), the correct 2D portrait
  otherwise, flipping back to 3D when combat drops. The owner called it "so fucking lame" and he is
  right; **do not re-chase it without a NEW API.** `UnitIsUnit("target","nameplateN")` being a real
  boolean in combat is the one door that is open, and it is already used.
- **A ROUND-BOTTOMED 3D bust (a mask on a PlayerModel)** — **IMPOSSIBLE on the current client**
  (2026-09-19). A `PlayerModel` is a live viewport into a rectangle, not a texture; `MaskTexture`,
  `SetClipsChildren` and alpha all act on textures or rectangles, and there is no render-to-texture
  for addons. A corner matte hides the world under the corners; slicing into clipped copies is
  jagged, heavy and the copies' idle animations drift apart. **Becomes a one-liner if Blizzard ever
  ships model-to-texture — that is the only trigger for reopening it.** The owner wants it; record
  the wish, not a hack.
- **The WoWup / GitHub-Releases distribution path** — **RETIRED by the owner, 2026-09-19.** He runs
  every suite addon as a SYMLINK for development; WoWup's GitHub install "doesn't work very well"
  (learned on Build Barn and Loot Advisor, both moved to CurseForge). Tags still cut a GitHub
  Release as a version marker, nothing more. **If the suite ever goes public it goes through
  CurseForge**, and he will say when. Do not frame changes as "so WoWup picks it up", do not verify
  `latest` for WoWup's sake, do not tell him to install from a release.
- **Gloom's Portraits keeping its own minimap button / floating panel / slash subcommands** — all
  **GONE with stage 2** (2026-09-19). The suite has ONE launcher; `/gp` opens the tab; the tab's
  open/close IS the lock. Reset lives in the tab's rail.

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
- **GA telling GB to glow a real action button** — **RULED OUT by the owner, 2026-08-25.** It was
  offered twice as the exact fix for "make the Cataclysm button glow" (perfect shape, perfect
  alignment, follows the bars automatically). He declined both times: *"I don't really want an aura
  telling GB what to do — that's a level of complexity that I suspect would introduce more problems
  than it solved."* **He is content aligning an aura over a button by hand.** Do not re-offer it.
- **"GA's shape/animation does nothing"** — check WHICH shape and WHICH texture before believing it.
  Measured against the icon rect, `roundsq1` crops **1.2%**, `roundsq2` 4.7%, `circle` 21.4%,
  `diamond` 50.1%. A rounded square over soft-edged art is a legitimately invisible change.
  Animations additionally need a Shape set — with none they are skipped by design. FINDINGS §14.
- **Distribution to friends/guild** — not ready; the owner will say when.
- **The user's own media shipping in the addon** — FIXED and purged. **Never re-track them.**
- **The colour picker** — **FULLY owner-QA'd.** IN USE holds the USER's colours; it is not modal.
- **GB's empty-button collapse hiding the CONTAINER** — **MOVED to the alpha path 2026-08-24**,
  FINDINGS §13. Blizzard re-shows containers and GB is combat-gagged, so the hide could never hold.
  **Do not reinstate `cont:SetShown(false)` for empties**; comments at both ends say so.
- **"Gloom's Hub says my fonts did not load, but they work"** — **FIXED 2026-09-08**, FINDINGS §5.
  The probe read its own first cold draw as the verdict, so it accused every drop-in catalog font on
  every cold client start and never on `/reload`. It now re-checks ~2s later and reports only what
  fails twice. ⚠ **The warning is still worth having** — a real typo or a deleted `.ttf` fails both
  passes. **Do not gate font REGISTRATION on it**; that reasoning is unchanged and is what kept the
  owner's fonts working throughout.
- **"Buttons past the bar's count reappear in combat"** — **FIXED 2026-09-05**, FINDINGS §13 (see
  the AMENDED block). Same mechanism as the empty-slot case, in the count path that was left behind.
  Out-of-grid containers are now alpha-0 AND parked off-screen. ⚠ **The trigger is HOVERING the bars
  in combat** — without that it will not reproduce, which is not the same as being fixed. **Do not
  "simplify" the parking away**: alpha alone leaves an invisible button clickable on top of live
  ones.
- **`C_Spell.IsSpellUsable` being simply banned** — **QUALIFIED 2026-08-24**, FINDINGS §12. Still
  invalid ALONE; valid ANDed with the cooldown mirror, and it is the only signal that sees a proc.
  GA's `CASTABLE` trigger state is built on that pairing.
- **Sourcing the "comes off cooldown" sound from events only** — **TRIED and WRONG**, FINDINGS §12.
  `CooldownFrame_Clear` is not reliably fired; the polled reconciler is sometimes the only witness.
  Judge the transition's DURATION, not which writer noticed. Do not re-split by source.
- **A settle/debounce timer on the ready sound** — **REMOVED**, it swallowed real sounds.
  `CDM:PlaySound`'s 1s per-display throttle already handles duplicates.
- **"The owner has stale Hunter auras"** — **FALSE.** Those live in OTHER CHARACTERS' profiles.
  ⚠ `GloomsAurasDB`/`GloomsBarsDB` hold one profile per character and display IDs restart in each
  (`d18` exists several times). **Any script reading them must be profile-aware** — grabbing the
  first regex match produced two confidently wrong diagnoses on 2026-08-24.
- **Reporting EllesmereUI's font-cache bugs upstream** — **DECLINED by the owner, 2026-09-19.**
  FINDINGS §16 names both bugs; the Hub-side fix makes them moot for us. Do not draft the report.
- **"Make the bar FILL change colour in the pandemic window"** — **NOT BUILT, by design** (2026-09-19).
  The fill is the engine's Blizzard button and cannot be restyled in combat (FINDINGS §1, §15); the
  owner chose the BACKDROP and it shipped. Do not re-offer the fill.
- **Immolate's pandemic sound firing every ~21s** — **NOT A BUG** (measured 2026-08-24: ~7 in 4.5
  minutes). A Destruction rotation refreshes into the pandemic window constantly and the alert fires
  each time; the spurious falloff one is separately suppressed (FINDINGS §12). Raised with the owner;
  **he did not ask for anything.** Do not build a rate limit unprompted.
