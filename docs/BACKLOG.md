# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-27, late (**Unit Frames is rebuilt in the two-window design** and waits on the
owner's in-game look; Auras and Bars took his first round of in-game fixes. **The next session starts
with item 18** — the owner's call.)
---

## Open items

### 18 · ★ START HERE — a BAR's gradient at ANY angle (Unit Frames)
**Repo:** `~/GloomsUnitFrames` (the bar renderer, `NewBar` in `GloomsUnitFrames.lua`) · **Size:** an
investigation, about a session; it may end "not possible" · **Evidence:** `OBSERVED` by the owner
2026-09-27 (an orb health bar: the Gradient Angle dial gives only four looks). The cause is known from
the code: bar mode lays its gradient with `SetGradient` (HORIZONTAL / VERTICAL only) plus the ramp
images `ramp.png` / `ramp-v.png`, and snaps the angle to the nearest of four. **Arcs take any angle.**

The owner chose to INVESTIGATE rather than just make the dial step by 90° on bars (that is the
fallback if no route works — his "option 1"). Ideas, all `SUSPECTED`: a gradient image on a texture
that is NOT the fill, rotated with `SetRotation`, masked by the shape and clipped to the filled part
the way the absorb overlay is (an invisible StatusBar sizing a `SetClipsChildren` frame). Walls already
measured (FINDINGS §21): no `SetTexCoord` on a mask, no `SetRotatesTexture` on a masked fill, a tiled
texture's scale is its file size. Test in game one step at a time; say what he should SEE.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` (the BAR MODE block) · FINDINGS §21 · `NewBar`,
`bar:SetGradient` and the absorb overlay in `~/GloomsUnitFrames/GloomsUnitFrames.lua`

---

### 16 · THE SUITE UI — THE TWO-WINDOW DESIGN (fourth redesign)
**Repo:** `~/GloomsHub` (`Windows.lua` + the kit) · `~/GloomsAuras` (`Pages.lua`) · `~/GloomsBars` (the
end of `Config.lua`) · `~/GloomsUnitFrames` (`GloomsUnitFrames_Pages.lua`) · later each tool ·
**Size:** his fixes as they come (small), then Portraits / Overlays / Media once he mocks them (a
session each) · **Evidence:** Auras + Bars `TESTED` in game by the owner 2026-09-27 (his fixes below
landed and he confirmed them). **Unit Frames BUILT 2026-09-27, verified OUTSIDE the game only**
(`tools/harness/sweep-v3.lua` drives all three tools, both units — 0 errors; every Unit Frames label
matched to its mock within a unit by the same comparison); the owner has only seen the Shortcodes
popup (its close disc was dead — fixed).

The mocks: Figma page **"GloomSuite UI 3"** (`tools/figma.py` → `get_metadata` on page `798:2`):
"gloomAuras, …", "gloomBars, …", "gloomUnits, <section>" + "Shortcodes Popup" (the Unit Frames
selector is the frame still NAMED "gloomBars, preview window" at y 1002), "Dropdown/Popup Menu".

**Next, in order:**
1. **The owner's look at Unit Frames in game** — BugSack text first. Choices of mine to confirm: a
   Rectangle bar shows Width, then Height, then Rotation (not mocked); Rounded Fill dims on a bar (it
   is arc-only in the engine; his Cast mock shows it live); the Filters popup is the sections' rows
   (Never | Any | Only, two columns); the shortcode line for `[level]` says "level" (his said "item level").
2. **Mocks needed from him:** the texture / sound / font / shape / spell pickers, the color picker,
   the name + confirm dialogs, the tooltip — all still wear the first design's kit.
3. **Portraits, Overlays, Media:** mock, then rebuild. Until then they open in the OLD big window
   (Shell.lua), which the tool switcher moves to and from.
4. Delete the unmounted previous editors once he approves: Auras `Config.lua`'s (`BuildTab`, the
   accordion, `Build*Section`s, ~2,000 lines — **keep `C.X` and all it exports**) and Unit Frames'
   `GloomsUnitFrames_Tab.lua` (out of the TOC already).
5. Retire the old big window's code and the first/second designs' kits when the last tool moves.

**Decisions taken (do not re-ask):**
- **Two windows per tool:** SELECTOR (240; its starting height is the tool's, `selector.h` — Unit
  Frames' is 105) + SETTINGS (400). Both closes / Escape close the tool; a pop-out's close only puts
  its section back. Height-only resize. Positions, heights, open section and pop-outs persist.
- **One section open at a time**; pop out for more. **Global Settings is the Hub's**, same in every tool.
- **Sansation only · dimmed = 30%, never hidden · close discs 20 above the top-right corner.**
- **Layout:** a control's LABEL is Sansation **10** (the owner, 2026-09-27); the control sits **15**
  under it (the label's 11 + his 4 gap), rows **41** apart, blocks **30**. Columns 170 · 20 · 170;
  three-column 107 · 106 · 107. Text inside boxes is NOT nudged (`UI.G_NUDGE` = 0, measured).
- **Lists** (`UI.gList`): a divider has 4 of space each side; a font list draws each name in its own face.
- **An empty color** is a dotted outline: 1-unit dots, 3 apart (he changed it from 2-unit dashes).
- **"Use Class Color" is in every two-window color picker** (the owner, 2026-09-27): it jumps to the
  class color; left there, the color FOLLOWS the logged-in character's class; any edit disconnects it.
  Saved as a normal color + `class = true`, re-colored at login (CONTRACTS §4). Unit Frames' fill /
  font colors keep their own Class / Power / Resource sources, which follow the UNIT.
- **World tooltips never cover our windows:** one that would is hidden (his option 1 of 3).
- **Auras:** left-click the tab's aura name = the list of auras to switch to (NOT rename); right-click
  = Rename · Duplicate · Move to Group · Delete. Show Charge Count REPLACES the Displayed Text, so the
  text field dims while it is on. An aura's text draws ABOVE a bar (its own frame).
- **Bars:** the preset menus as built; Casts & Channels keeps its extra color, labelled **"Cast
  Complete Color"**. Addon UI Scale's steps up to 150% on his 4K are right.
- **Unit Frames:** Copy Settings from TARGET/PLAYER + Reset to Defaults sit at the foot of Global
  <Unit> Settings. "View Shortcodes" (a lime link) opens the Shortcodes popup; a code clicked goes into
  the text being edited, at its cursor. Filters opens a popup in the new design.

**Read first:** the headers of `~/GloomsHub/Windows.lua`, `~/GloomsAuras/Pages.lua` and
`~/GloomsUnitFrames/GloomsUnitFrames_Pages.lua`, the "THE TWO-WINDOW DESIGN" block at the end of
`~/GloomsBars/Config.lua` · CONTRACTS §2 and §4 · FINDINGS §22 (the owner's DISPLAY setup before any
"it looks soft") · the header of `tools/harness/run.lua` · LESSONS § "Reading the Figma mocks"

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
⚠ The tab's LOOK is item 16's (rebuilt 2026-09-27); do not tidy it separately.

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

- **The ONE big Suite window for rebuilt tools, and baked "glass" backgrounds** — **RETIRED
  2026-09-27.** The glass panels went solid (one shared background, drawn panels) on the 26th, then
  the owner replaced the monolithic window with two windows per tool ("it covers so much of the
  screen"). The big window survives only for tools not yet rebuilt. Do not rebuild baked panels.
- **"The game looks soft/thick — rebuild the UI to fix it"** — first check the **display chain**
  (FINDINGS §22): the Mac's display setting and HDR fixed what no addon change could. Do not
  re-chase sharpness in code before the owner's setup has been checked.

- **GLASS BUTTONS** (glass on every control) — **REJECTED 2026-09-22**; what the owner adopted on
  2026-09-25 is glass PANELS that never move, baked into each page's background from his own
  exports (item 16). WoW gives addons **no backdrop blur and no render-to-texture**, so glass on
  anything that moves or scrolls is still impossible. Do not re-offer per-control glass.
- **"Our text is soft because the window is scaled"** — **KILLED 2026-09-26** (FINDINGS §22): the
  same words scaled ×1.094 and drawn natively at the same size are pixel-identical in game. Do not
  rebuild the kit to avoid SetScale.
- **WEBP textures** — **NOT SUPPORTED** (Warcraft Wiki, `TextureBase:SetTexture`: BLP, JPEG, PNG,
  TGA only, power-of-two sizes; PNG since 10.0.7 and it needs the `.png` extension written out).
  For a large opaque background BLP (DXT) or JPEG is the small option; PNG for crisp small art.

- **The Unit Frames tab tidy pass (item 13)** — **CLOSED 2026-09-21 as superseded**: the whole
  Suite UI is being redesigned from mocks (item 16). Do not tidy the old tab.
- **Audiowide for the redesign's wordmarks** — **WRONG, corrected by the owner 2026-09-21**: the
  Figma file uses **Michroma** everywhere; he had confused the two. Audiowide is not shipped.
- **The scrub dial as a jog wheel (ticks sliding under a fixed mark)** — **built and REJECTED
  2026-09-21**; so was the first cut (a needle riding over the ticks, hidden while dragging). The
  owner's definition is in `UI.dial`'s header. Do not rebuild either.
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
