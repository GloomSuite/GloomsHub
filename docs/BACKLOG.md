# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-21 (**the shaped-bar session, and the redesign is specified.** GU's
four displays gained BAR MODE — a StatusBar cut to a silhouette, FINDINGS §21 — with per-display
layering, an outline in either mode, a real EUI-style absorb overlay, and the Hub got a SEPARATE
bar-shape family (`Orb`, `Pill`, the generated `Bracket` set, the owner's `Tall crescent` set).
Portraits got an **Off** visibility. Then the owner mocked **the whole Suite UI in Figma** —
24 screens + a PRIMITIVES kit — and the redesign is item 16, fully briefed. **Item 13 (the tab
tidy pass) closed as superseded by it.**)
---

## Open items

### 16 · ★ THE SUITE UI REDESIGN — from the owner's Figma mocks
**Repo:** `~/GloomsHub` first (tokens, fonts, shell, `LibGloomSkin`), then every tab · **Size:** several sessions, ONE per stage · **Evidence:** the mocks exist and were read through the Figma desktop connector 2026-09-21

The owner: *"I've grown to hate how it looks."* He mocked it all in Figma, file page **"GloomSuite UI"
(node `646:144`)**: 24 screens at **1060 × 740** — Auras ×7, Bars ×10, Unit Frames ×7 — plus a
**PRIMITIVES** frame (`674:13578`) holding every repeated control and a redesigned colour picker.
The connector reads frames BY ID (`get_metadata` for structure, `get_screenshot`,
`get_design_context` after loading its guidance resource); he does not need to select anything.
Layers inside screens are mostly auto-named — the TEXT layers carry the labels, and the PRIMITIVES
frame is the key for matching controls by shape.

**Decisions already taken (do not re-ask):**
- **Window 1060 × 740, fixed** — the shell grows first (CONTRACTS §2 allows growing, never shrinking).
- **Light grey window** (`#c0c0c0`-ish) with the deep purple as the persisting-state colour, orange
  for destructive actions and the scrub indicator; the nine colour chips in PRIMITIVES are the
  palette, roles as a starting point, **not a law** — follow the mocks, flag exceptions.
- **Fonts: Audiowide** (wordmark, section headers, the big Player/Target buttons) and **Play**
  regular + bold (body 11 regular, labels 12 bold) — both OFL, ship them with licence files, and
  **a new font needs a full client restart** to load. Smaller type throughout, deliberately.
- **Button states:** dark = action, purple = persisting state (tabs, dropdowns, choices), light =
  disabled. Hover/pressed are the assistant's to derive and should be quiet.
- **The scrub dial replaces every slider**: tick strip + value box, drag anywhere (the whole screen
  is the drag range), wheel steps, click-to-type; unit from context (px / ° / % / none); the
  centre-mark variant wherever zero is meaningful (offsets, angles).
- **No cogs, no popovers** — settings live on the panel (anything that appears only after a
  dropdown choice is in the mocks).
- **Colour SOURCES live in the picker** (class / power type / resource / reaction) — a swatch holds
  a fixed colour OR a source; the "use class colour" toggles disappear. "(Remove)" only on optional
  colours.
- **ONE layer control unit** everywhere in GU (rings, auras, texts): a **Global Settings** panel
  holds the default strata + level for both units; each element inherits (in the automatic order)
  or **overrides** with its own two numbers. The per-unit Layer section goes.
- **Rounded corners at one radius throughout** → one nine-slice family. Dashed borders and a
  right-click context menu are possible and may be used (`contextMenu` is not mocked — derive).
- **A Suite SETTINGS tab** with a UI-scale control (EUI's named sizes, Tiny…Massive) — contents beyond
  that to be found.
- Dialogs and tooltips: **new**, derived from the kit — never the old designs.

**Stages, one session each:** (1) Foundation — tokens, fonts, the shell at 1060 × 740, the
primitives, and the **UnitFrames Global** panel on screen to prove the kit; (2) Unit Frames' seven
panels; (3) Bars' ten; (4) Auras' seven; (5) Overlays, Portraits, Media from the kit alone ("same
controls, new skin" — do not ask him to mock them). Within a session: one panel at a time — read
it, list what is there, ask only where ambiguous, build, he `/reload`s and looks.

**Read first:** the PRIMITIVES frame (`674:13578`) and the UnitFrames Global screen (`660:5703`)
through the connector · [CONTRACTS.md](CONTRACTS.md) §1, §2, §4, §6 (what the toolkit and shell
promise today, and the version gate every consumer carries) · `~/GloomsHub/Skin.lua` (the 13
primitives and their call shapes) · `~/GloomsHub/Shell.lua`

---

### 12 · Gloom's Unit Frames — what is left
**Repo:** `~/GloomsUnitFrames` · **Size:** watching, then small pieces · **Evidence:** bar mode owner-QA'd 2026-09-21 (FINDINGS §21)

**Done 2026-09-21:** BAR MODE on health / power / cast / resource (shape · size · rotation · fill
direction · track · gradient · shift · absorb overlay · outline) · per-display strata + level
(level = the display's lowest piece; a bar spans +6, an arc +15) · outline in either mode, three
widths · the bar's own offset, separate from the arc's · `/gu bar <ring> …` QA command (keep it).

**Left, in order:**
1. **A TARGET's cast in bar mode under secrecy** — `SetTimerDuration` from the duration object,
   `UNTESTED` there (§21). Needs a delve or a casting mob; he just looks.
2. **The shield wash switching OFF** (arc mode) — still only ever seen on the probe square (§19).
3. **Aura filter CLASSES** beyond timed-only and cast-by-you — `UNTESTED` individually.
4. **The aura PREVIEW's alignment** against a live group — unverified; a one-number fix if off.
5. **Flips for non-symmetric bar shapes** — a mirrored file per shape + a "Mirror" choice; only
   matters for the crescent set. Masks refuse flipped texcoords (§21).
6. **The Gu mark** — still the Hub's logo. Art.
⚠ The tab's LOOK is item 16's; do not tidy it separately.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` · [FINDINGS.md](FINDINGS.md) §18–§21

---

### 17 · Bar-shape art — the owner's sets
**Repo:** `~/GloomsHub` (`Media/art/barshapes/`, `Shapes.lua` BAR_SHAPE_DEF, `tools/gen-barshapes.py`) · **Size:** minutes per set · **Evidence:** the Tall crescent set imported and drawn 2026-09-21

The family has `Orb`, `Pill`, the generated **Bracket** set (owner: *"too thin, and I'm not even
sure they should be uniform … this isn't it"* — he will draw his own) and his **Tall crescent** set.
A set = one composition exported one member per file on the shared canvas, white on transparent;
the generator derives `-base-s` and three rim widths and prints the catalog rows with measured
footprints. **Size** on a set member scales the SET's footprint so members nest. Expect more sets
from him; each is: drop the files in, run the script, paste the rows.

**Read first:** the header of `~/GloomsHub/tools/gen-barshapes.py` · the BAR SHAPES block at the end of `~/GloomsHub/Shapes.lua`

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **The Unit Frames tab tidy pass (item 13)** — **CLOSED 2026-09-21 as superseded**: the whole
  Suite UI is being redesigned from mocks (item 16). Do not tidy the old tab.
- **Offering the BUTTON shape catalog to a unit frame** — **RULED OUT by the owner 2026-09-21**:
  *"they are fundamentally different things."* GU reads only the Hub's BAR-shape family
  (`GloomsHub.BAR_SHAPES`); the mechanism is shared, the lists never mix in a picker.
- **A shared Offset X/Y between a display's arc and bar** — **RULED OUT 2026-09-21**: *"no scenario
  in which the X/Y placement would be the same."* Each mode keeps its own.
- **WCAG contrast thresholds for the redesign** — the owner **does not care** (2026-09-21): *"if I
  can read at age 50, it's not a problem."* Measure if asked; do not lecture.
- **The mid-combat ruling for GU** stands (2026-09-20): apply at regen is enough.

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
