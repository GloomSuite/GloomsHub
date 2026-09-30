# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-30 (a long build session: **Gloom's UI** (Overlays + Portraits as one tool,
with groups), shaped bar fills in Unit Frames, the texture browser moved into gloomMEDIA, the tool
rail, one window place for every tool, suite-wide UNDO, attaching gloomUI groups to unit frames,
arrow-key nudges, Grow From. Item 19 closed. **The next session starts with item 21** — the
owner's call.)
---

## Open items

### 21 · ★ START HERE — the texture browser, and how assets get in
**Repo:** `~/GloomsHub` (`Media.lua`: the catalogs + the TEXTURE BROWSER block) · **Size:** a design
DISCUSSION first · **Evidence:** the owner's request, 2026-09-30 ("I'd like to discuss the texture
browser and how that and adding assets from the game library and external assets works").

What he wants to talk through: the texture browser (gloomMEDIA → Game Textures, and the Texture
Browser window any tool's Browse opens — `GloomsHub:PickTexture`), how the GAME's art gets found
(he uses Texture Atlas Viewer, `/tav`; flipbooks are named `…flipbook…` / `…-flip`; a sheet's grid
is a GUESS the owner may have to correct) and how EXTERNAL art gets in (the Hub's drop-in folders
`Fonts/ Textures/ Graphics/`, gitignored, registered by name in the Media catalogs). Explain first,
then let him steer. Nothing is decided yet.

**Read first:** the header of `~/GloomsHub/Media.lua` and its "THE TEXTURE BROWSER" block ·
CONTRACTS §3 (the resolver) · `GloomsOverlays_BrowseAssets` in `~/GloomsOverlays/GloomsOverlays_Pages.lua`

---

### 22 · This session's builds — waiting on the owner's use (2026-09-30)
**Repo:** `~/GloomsHub` · `~/GloomsOverlays` · `~/GloomsUnitFrames` · **Size:** his fixes as they come ·
**Evidence:** each harness-checked (0 errors in `sweep-v3.lua`, targeted scripts); the owner
confirmed in game what is marked ✓.
- **Gloom's UI** (`~/GloomsOverlays`, folder unchanged): portraits are an overlay TYPE; groups with a
  shared anchor, drag-into-group ✓, the eye hides as well as shows ✓, spritesheet settings, last
  selection remembered ✓, **Attach To** a unit frame ✓ (the login-order fix ✓), Hide With Its Frame,
  group Scale — untested in game: that attaching leaves a group exactly in place (the harness can't
  tell), Hide With Its Frame, Scale.
- **Unit Frames bar fills:** Fill End (round / angled / point) ✓, the track and the absorb stripes
  cut to it ✓, Marker, Segments (dividers or Whole), Grow From — untested in game: the 1-px seam fix
  (the owner saw seams), the masked gloss rim on a round end (his "white crust"), markers, segments.
- **Hub:** the tool rail ✓, one place for every tool's windows ✓ (min selector height 340), the
  Texture Browser ✓, Tab through fields, UNDO ✓ ("nice, I like it") — untested: that one action is
  exactly one step, the Ctrl/Cmd+Z keys, arrow-key nudges.
- **Waiting on his approval to DELETE:** `~/GloomsOverlays/GloomsOverlays_Preview.lua` (the old
  drawer) and `GloomsOverlays_Editor.lua`, both out of the TOC. **The Portraits addon is retired**
  (its AddOns symlink removed 2026-09-29; the repo untouched) — what happens to the repo and its
  public GitHub copy is his call.

**Read first:** `~/GloomsOverlays/CLAUDE.md` · the headers of `~/GloomsHub/Undo.lua` and
`~/GloomsHub/Anchors.lua` · the "THE FILL'S EDGE PIECES" comment in `NewBar`
(`~/GloomsUnitFrames/GloomsUnitFrames.lua`) · FINDINGS §21's 2026-09-29/30 addendum

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
1. **His fixes from use** — BugSack text first. Unmocked choices to confirm if he raises them:
   Overlays' Class Color is one Off | Player | Target switch, Flip one None | Horiz | Vert | Both
   switch, an empty Tint = white.
2. **Mocks needed from him:** the sound / font / shape / spell pickers, the color picker, the tooltip
   — still the first design's kit. (The texture browser moved to the new kit 2026-09-30, built from
   the pages without a mock at his request; the confirm and name dialogs 2026-09-27.)
3. Delete the unmounted previous editors once he approves: Auras `Config.lua`'s (`BuildTab`, the
   accordion, `Build*Section`s, ~2,000 lines — **keep `C.X` and all it exports**), Unit Frames'
   `GloomsUnitFrames_Tab.lua`, Overlays' `GloomsOverlays_Editor.lua` and `GloomsOverlays_Preview.lua`
   (all out of their TOCs).
4. **Every tool has moved**, so the old big window's code (`Shell.lua`'s panel) and the first/second
   designs' kits can now be retired — check nothing still calls them first.

**Decisions taken (do not re-ask):**
- **Two windows per tool:** SELECTOR (240, never shorter than 340 — the tool rail) + SETTINGS (400).
  Both closes / Escape close the tool; a pop-out's close only puts its section back. Height-only
  resize. **ONE position and height per window, shared by every tool** (the owner, 2026-09-30: they
  "bounced all over the place"); open section and pop-outs stay per tool.
- **The TOOL RAIL** (the owner's Figma "Frame 614", 2026-09-30): vertical tabs FLUSH on the selector's
  left edge — AURAS · BARS · UNIT FRAMES · OVERLAYS (gloomUI keeps that name) · MEDIA; violet + white,
  the open tool lime + dark purple #0f051d. Art, since WoW can't turn text (`tools/gen-rail-art.py`).
- **UNDO / REDO** (2026-09-30): ONE history for the whole suite (the owner: per-tool "would be weird"),
  while the windows are open, 200 steps; curved arrows on the selector's title row (the tab strip's
  right end is taken in Auras and Bars) + Ctrl/Cmd+Z, Shift for redo. Media is left out.
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

**Done 2026-09-29/30:** a bar's **Fill End**, **Marker**, **Segments** (dividers, or Whole = a row of
window bars) and **Grow From** (item 22 says what is still unproven in game) · the capprobe deleted.
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

- **Carrying the old Portraits settings into Gloom's UI** — **NOT WANTED by the owner, 2026-09-29**:
  *"you can delete any existing portrait settings … I'll rebuild."* A portrait is just an overlay TYPE
  with ONE position (no separate 3D / 2D places).
- **A true cross-tool group (the Hub moving and scaling pieces of several tools as one)** — **NOT
  BUILT, by agreement 2026-09-30**: gloomUI groups ATTACH to a unit frame instead (the Hub's anchors).
  **A linked "unit scale" for Unit Frames** was deferred: gloomUI scales a group, the unit frame is
  adjusted by hand — the owner: "an acceptable compromise".
- **Undo per tool** — **REJECTED by the owner 2026-09-30**: one suite-wide history.

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

- **Not-open records settled 2026-09-19 → 20** (GU's "This spell" aura kind, the silent-yes known-check,
  GA's hot `ApplyConfig`, texture-less auras, `hgAnchor`, mid-combat changes in GU, the absorb arc,
  aura-button scripts, class color vs gradient, secret-value drawing rules, the cast swipe, GU
  profiles, rings over 180°, enemy 3D models in instances, a round-bottomed 3D bust, the WoWup path,
  Portraits' old launcher) — moved to ARCHIVE.md ("NOT-OPEN RECORDS moved out of the BACKLOG,
  2026-09-30"). **Read them there before re-raising any of those.**
- **Older "not open" records (settled July–August 2026)** — GB profiles and presets, GA's 12.1
  duration bars and the deleted Tracked-Bar mirror, the damage-meter and Quick Keybind non-bugs, icon
  overrides, the colour picker, empty-button collapse, the font-load warning, the ready-sound rules,
  the Hunter-aura and EllesmereUI calls, the pandemic fill — moved to ARCHIVE.md ("NOT-OPEN RECORDS
  moved out of the BACKLOG", 2026-09-29). **Read them there before re-raising any of those.**
