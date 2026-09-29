# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-29 (**every tool is now in the two-window design** — Portraits, Overlays and
Media were built from the other tools' pages without mocks, at the owner's request; he is testing
through use over the coming days. Item 18 closed. **The next session starts with item 19** — the
owner's call.)
---

## Open items

### 19 · ★ START HERE — "Gloom's UI": Overlays + Portraits as one module, and GROUPS that move as one
**Repo:** `~/GloomsOverlays` + `~/GloomsPortraits` (and the Hub if the module becomes a new tool) ·
**Size:** a design DISCUSSION first — no code until the owner has chosen · **Evidence:** the owner's
request, 2026-09-29.

Two things he wants to talk through:
1. **Combining Gloom's Overlays and Gloom's Portraits into one "Gloom's UI" module.** Both are "put a
   graphic on screen, place it, give it a layer and a show condition". Questions to put to him, not
   answer for him: one addon or two sharing a window; what happens to `/go` and `/gp`; one profile
   system (Overlays has profiles, Portraits has none); and the migration.
   ⚠ **Overlays' SavedVariables globals are `VibeOverlayDB` / `VibeOverlayDBChar` and must not be
   renamed without a real migration** (its CLAUDE.md, "THE ONE THING…"). ⚠ Portraits keeps its
   predecessor's migration shim (its CLAUDE.md, the privacy rule) — a merge must not surface the old name.
2. **Grouping elements and moving a group as one unit** — overlays with a portrait, or several
   overlays. Prior art in the suite: Unit Frames' per-piece drag handles on top of a unit anchor
   (`GU:SetDragPiece`, 2026-09-27) and its rings-hugging unit box; Auras' groups (a container with its
   own load rule). Offer the shapes (a group = a shared anchor with member offsets, like a unit frame)
   and let him pick.

**Read first:** `~/GloomsOverlays/CLAUDE.md` · `~/GloomsPortraits/CLAUDE.md` · the headers of
`~/GloomsOverlays/GloomsOverlays_Pages.lua` and `~/GloomsPortraits/GloomsPortraits_Pages.lua` · the
PER-PIECE DRAGGING block in `~/GloomsUnitFrames/GloomsUnitFrames.lua` (search `SetDragPiece`)

---

### 16 · THE SUITE UI — THE TWO-WINDOW DESIGN (fourth redesign)
**Repo:** `~/GloomsHub` (`Windows.lua` + the kit) · `~/GloomsAuras` (`Pages.lua`) · `~/GloomsBars` (the
end of `Config.lua`) · `~/GloomsUnitFrames` (`GloomsUnitFrames_Pages.lua`) · later each tool ·
**Size:** his fixes as they come (small) · **Evidence:** Auras, Bars and Unit Frames `TESTED` in game
by the owner through 2026-09-29 (heavy Unit Frames use). **Portraits, Overlays and Media BUILT
2026-09-27 without mocks** (the owner: "there's already a lot of source material") from the Unit
Frames / Auras pages; he confirmed the Overlays eye rules and the new dialogs in game and is testing
the rest through use. `tools/harness/sweep-v3.lua` drives all six tools — 0 errors.

The mocks: Figma page **"GloomSuite UI 3"** (`tools/figma.py` → `get_metadata` on page `798:2`):
"gloomAuras, …", "gloomBars, …", "gloomUnits, <section>" + "Shortcodes Popup" (the Unit Frames
selector is the frame still NAMED "gloomBars, preview window" at y 1002), "Dropdown/Popup Menu".

**Next, in order:**
1. **His fixes from use** of Portraits, Overlays and Media — BugSack text first. My unmocked choices
   to confirm if he raises them: Overlays' Class Color is one Off | Player | Target switch, Flip one
   None | Horiz | Vert | Both switch, an empty Tint = white; Portraits has no nudge arrows (the dials'
   arrow keys); Media's selector lists the five catalogs with counts.
2. **Mocks needed from him:** the texture / sound / font / shape / spell pickers, the color picker,
   Overlays' asset browser, the tooltip — all still wear the first design's kit. (The confirm and
   name dialogs moved to the new kit 2026-09-27 at his request.)
3. Delete the unmounted previous editors once he approves: Auras `Config.lua`'s (`BuildTab`, the
   accordion, `Build*Section`s, ~2,000 lines — **keep `C.X` and all it exports**), Unit Frames'
   `GloomsUnitFrames_Tab.lua`, Portraits' `GloomsPortraits_Tab.lua`, Overlays' `GloomsOverlays_Editor.lua`
   (all out of their TOCs).
4. **Every tool has moved**, so the old big window's code (`Shell.lua`'s panel) and the first/second
   designs' kits can now be retired — check nothing still calls them first.

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
- **No mouse wheel on a dial** (the owner, 2026-09-27): the wheel only ever scrolls; the number box
  steps with ↑/↓ (Shift ×10). **Tooltips wait 1 second** (`UI.TIP_DELAY`), everywhere.
- **Auras: Icon, Texture and Bar are real TYPES** (the owner, 2026-09-27 — he rejected merging Icon
  and Texture): an Icon starts with no art (its trigger's icon, the red question mark until then), a
  Texture on the white sphere; the tab says which. **Right-click → Duplicate As… / Change Type…**
  switch types; each type's settings are kept, and each side remembers its size. Settings that do
  nothing for the type DIM (the audit); **Bar Fill & Readouts is LOCKED shut** on a non-bar (the
  Hub's section `locked`). Every Auras setting has a tooltip.
- **The EYE (Auras and Overlays):** each item's saved eye is its state while NOT selected; selecting
  shows it regardless, the eye on the selected item toggles only for now, and deselecting returns it
  to its saved eye. In Overlays the eye is this preview — ON/OFF is the Visibility section's switch.
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

**Done 2026-09-27/29:** a bar's gradient at ANY angle (item 18) · a shape's WIDTH and HEIGHT apart
(it stretches; a lime bracket links them) · **no outline on bars** (the owner: no use for it; arcs keep
theirs) · offsets out to ±1500 · **per-piece dragging** (a lime handle on the open section's piece) ·
**Rounded Ends** on Rectangle bars (a CLAMP-wrapped cap mask, FINDINGS §21) · **Gloss** (his Figma
inner shadow, rendered by `tools/gen-gloss.py`).
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
7. **Delete the `/gu capprobe` probe** — its answer is in FINDINGS §21 (a mask honours CLAMP).
⚠ The tab's LOOK is item 16's (rebuilt 2026-09-27); do not tidy it separately.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` · [FINDINGS.md](FINDINGS.md) §18–§21

---

### 20 · Gloom's Auras — two leftovers from the settings audit
**Repo:** `~/GloomsAuras` · **Size:** small each · **Evidence:** the audit of 2026-09-27 (every
control traced to its read site in `Displays.lua` / `CDM.lua`).
1. **A note under Bar Type when the first trigger's spell is the wrong kind** (a Cooldown bar on an
   aura, an Aura Duration bar on a cooldown): today that bar never moves and only Bar Type's tooltip
   says why. `SUSPECTED` approach: the CDM already knows a spell's family.
2. **Opacity may not fade a duration bar's moving fill** — `SUSPECTED` from the code (the engine's
   drain lives on a frame parented to UIParent, `AuraDuration.lua` ~190); the backdrop and text do
   fade. Needs one in-game look before any fix.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md` · `BuildBar` in `~/GloomsAuras/Pages.lua`

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

- **Merging Auras' Icon and Texture types** — **REJECTED by the owner 2026-09-27**: they are different
  to a user; they were made real instead (item 16's decisions).
- **An outline on Unit Frames BARS** — **REMOVED by the owner 2026-09-27** ("I still can't think of a
  use for it"); a stretched shape would have thickened its baked rim anyway. Arcs keep theirs.
- **Growing the upper layers' masks to hide the faint dark rim at a rounded bar end** — **TRIED and
  REVERTED 2026-09-29** (points where the curve begins, a flattened middle). The owner: *"I just live
  with it."* FINDINGS §21. Do not re-offer.
- **"Overlay and unit-frame sizes don't match"** — they DO: both are UI units on UIParent, measured
  equal with `/go debug` 2026-09-29 (the case was a health orb at 80, not 123). Check the numbers first.

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

- **Older "not open" records (settled July–August 2026)** — GB profiles and presets, GA's 12.1
  duration bars and the deleted Tracked-Bar mirror, the damage-meter and Quick Keybind non-bugs, icon
  overrides, the colour picker, empty-button collapse, the font-load warning, the ready-sound rules,
  the Hunter-aura and EllesmereUI calls, the pandemic fill — moved to ARCHIVE.md ("NOT-OPEN RECORDS
  moved out of the BACKLOG", 2026-09-29). **Read them there before re-raising any of those.**
