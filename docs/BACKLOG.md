# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-10-04 (a long fix-and-build session across every tool — item 24 lists what is
still waiting on the owner's use. **Next session, by the owner's choice: item 23**, a second-row
offset for multi-row GB bars.)
---

## Open items

### 23 · GB — a second-row OFFSET for multi-row bars ★ START HERE (the owner, 2026-10-04)
**Repo:** `~/GloomsBars` (`Layout.lua` + the Bar Layout page in `Config.lua`) · **Size:** small–medium ·
**Evidence:** none yet — a new feature.
The owner wants a slider that shifts a multi-row bar's SECOND row sideways (rows after the first, on
a horizontal bar; columns on a vertical one). **Ask first** what exactly he means before building:
a fixed px shift of every other row (a stagger — the honeycomb look GB's HANDOFF calls "the geometry
fork", which Layout now makes possible since it owns the containers), or only row 2, and whether it
is per bar (yes, almost certainly — `barLayout[barKey]`, beside `gap` / `gapCross`).
- The grid math is `applyBar` in `Layout.lua`: since 2026-10-01 each slot is the DRAWN size of the
  button (`pw` / `ph`, from `Skin:DrawnSize`), not the square — an offset should be in the same units,
  and the bounding box (`maxX` / `minY`, which centres a positioned bar) must include the shifted row.
- The controls: the Bar Layout page (`Config.lua` ~1850: Icon Gap, Rows, Gap Between Rows — `perLabel`,
  `ensureBarLayout(selBar)`, `apply()`), and Copy Layout (~1887) must copy the new field too.
- Layout moves Blizzard's containers OUT OF COMBAT only (`ApplyAll` is combat-gated) — unchanged.

**Read first:** `~/GloomsBars/CLAUDE.md` · `applyBar` in `~/GloomsBars/Layout.lua` · the Bar Layout
page in `~/GloomsBars/Config.lua` (search "Gap Between Rows") · `~/GloomsBars/docs/HANDOFF.md` §
"Positioning/spacing (honeycomb layout)"

---

### 24 · The 2026-10-01 → 04 builds — waiting on the owner's use
**Repo:** all but Portraits · **Size:** his fixes as they come · **Evidence:** each harness-checked
(0 errors in `sweep-v3.lua`, targeted scripts); ✓ = the owner confirmed in game.
- **Hub:** the Slants widened to 424 × 256 ✓ (CONTRACTS §7) · the Sheen's near-0 speed now stops.
- **Bars:** spacing by the DRAWN size (gap 0 = edge to edge) ✓ · custom icons survive any re-set
  (stealth) ✓ · a bar on its own preset keeps its own count / keybind / cast glow when Blizzard
  refreshes them ✓ · **Quick Keybind** in the new look + it now closes the two-window Suite — untested.
- **Auras:** load-condition pairs tick ✓ · bar auras down to 1 px ✓ · **Target Casting** (FINDINGS §26 —
  the visual works in the open world, `OBSERVED`; a delve pending; its SOUND is silent wherever the flag
  is hidden, i.e. everywhere measured) · **Buff Running Low** ✓ (poisons) · **Trinket Ready** ✓ in a delve
  (the return at cooldown end, in combat, untested — §27) · late Cooldown Manager icons rebind ✓ · the
  spell / shape / texture / sound pickers rebuilt as Suite windows (`KitWindow`) — the owner saw the
  sound picker; the others unseen.
- **Unit Frames:** per-spec color-change count ✓ · charged combo points ✓ (§28) · the seam's cause fixed,
  a faint flicker accepted (§21) · right-click menu + left-click target (secure click layer) — untested ·
  Grow From hidden on Resource.
- **Gloom's UI:** Show When Any / All · Hide When Mounted · the Visibility note's spacing · **group-level
  visibility** (a gate in front of every member) — all untested in game.
- **Soulstone Watch** — a SEPARATE tiny addon, NOT a suite member (`~/SoulstoneWatch`, no git, symlinked
  into AddOns): warning when nobody has Soulstone in a raid instance, "X soulstoned Y" and a
  ready-check report to raid chat, a window + minimap button. Its raid-night test is pending: can it
  read buffs and post to raid chat inside a raid instance (`/ssw` window shows both).

**Read first:** the item's repo `CLAUDE.md` · FINDINGS §26–§28 · `~/GloomsAuras/docs/HANDOFF.md` (the
2026-10-04 block) · `~/GloomsBars/docs/HANDOFF.md` (the 2026-10-01 block)

---

### 22 · The 2026-09-30 builds — waiting on the owner's use
**Repo:** `~/GloomsHub` · `~/GloomsOverlays` · `~/GloomsUnitFrames` · `~/GloomsBars` · **Size:** his fixes as they come ·
**Evidence:** each harness-checked (0 errors in `sweep-v3.lua`, targeted scripts); the owner
confirmed in game what is marked ✓.
- **Gloom's UI** (`~/GloomsOverlays`, folder unchanged): portraits are an overlay TYPE; groups with a
  shared anchor, drag-into-group ✓, the eye hides as well as shows ✓, spritesheet settings, last
  selection remembered ✓, **Attach To** a unit frame ✓ (the login-order fix ✓), Hide With Its Frame,
  group Scale — untested in game: that attaching leaves a group exactly in place (the harness can't
  tell), Hide With Its Frame, Scale.
- **Unit Frames bar fills:** Fill End (round / angled / point) ✓, the track and the absorb stripes
  cut to it ✓, Marker, Segments (dividers or Whole), Grow From — untested in game: the masked gloss
  rim on a round end (his "white crust"), markers, segments. (The seam: item 24 / FINDINGS §21.)
- **Hub:** the tool rail ✓, one place for every tool's windows ✓ (min selector height 340), the
  Texture Browser ✓, Tab through fields, UNDO ✓ ("nice, I like it") — untested: that one action is
  exactly one step, the Ctrl/Cmd+Z keys, arrow-key nudges.
- **Waiting on his approval to DELETE:** `~/GloomsOverlays/GloomsOverlays_Preview.lua` (the old
  drawer) and `GloomsOverlays_Editor.lua`, both out of the TOC. **The Portraits addon is retired**
  (its AddOns symlink removed 2026-09-29; the repo untouched) — what happens to the repo and its
  public GitHub copy is his call.

- **Built 2026-09-30 (second half), harness-checked:**
  - **Texture Browser** (Hub `Media.lua`): sources Game Art ✓ (15,043) · Sheets ✓ · My Media ✓ ·
    Favorites; search ✓; pixel sizes on My Media and in the catalogs ✓; grid lines over a stopped
    sheet ✓; the freeze fix ✓ — untested: **remembered grids**, **dragging the scrollbars**, the 6:1
    warning's wording.
  - **gloomUI:** a group **On/Off** (the save bug fixed after his report — the FIX is untested in
    game) · a new overlay starts at its **image's size** (untested in game).
  - **Hub:** arrow keys move **one screen pixel** + `fine` dials ✓ ("that's better") · drag handles
    are **corner brackets** ✓.
  - **Unit Frames:** **Hide Blizzard's Cast Bar** (its own, not EUI's — untested in game, incl. Edit
    Mode) · `[guild]` / `[title]` ✓.
  - **Bars:** the **Slant / and Slant \ shapes** ✓ (widened 2026-10-04, item 24) — the **even-border
    fix** (`growX`, recomputed for the new width) is untested in game · the spacebar shows as **`_`** ✓.

**Read first:** `~/GloomsOverlays/CLAUDE.md` · the headers of `~/GloomsHub/Undo.lua` and
`~/GloomsHub/Anchors.lua` · the TEXTURE BROWSER / ART LIST blocks in `~/GloomsHub/Media.lua` · the "THE FILL'S EDGE PIECES" comment in `NewBar`
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
2. **Mocks needed from him:** the font picker, the color picker, the tooltip — still the first
   design's kit. (Auras' sound / shape / texture / spell pickers became Suite windows 2026-10-04,
   built like the Texture Browser without a mock — item 24.) (The texture browser moved to the new kit 2026-09-30, built from
   the pages without a mock at his request; the confirm and name dialogs 2026-09-27.)
3. Delete the unmounted previous editors once he approves: Auras `Config.lua`'s (`BuildTab`, the
   accordion, `Build*Section`s, ~2,000 lines — **keep `C.X` and all it exports**), Unit Frames'
   `GloomsUnitFrames_Tab.lua`, Overlays' `GloomsOverlays_Editor.lua` and `GloomsOverlays_Preview.lua`
   (all out of their TOCs).
4. **Every tool has moved**, so the old big window's code (`Shell.lua`'s panel) and the first/second
   designs' kits can now be retired — check nothing still calls them first.

**Decisions taken (do not re-ask)** — the full list (two windows per tool, the tool rail, one
suite-wide Undo, one section open, Sansation, the layout numbers, the eye, Auras' types, Unit Frames'
buttons…) is in ARCHIVE.md, "Item 16's settled design decisions (moved 2026-10-04)". **Read it before
changing anything about the windows' look or behavior.**

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

- **A Kick SOUND that plays only on interruptible casts** — **IMPOSSIBLE as far as known, 2026-10-04**:
  the flag is secret even in the open world (FINDINGS §26); a sound can't be gated by a secret, nor can
  a widget's colour be read back. The visual version works. The one untested long shot
  (`SetShown(secret)`) was offered; the owner didn't take it.
- **Targeting the casting mob for you** — no addon may change target on a condition in combat; the
  owner was given mouseover / focus Kick macros instead (2026-10-04).
- **Soulstone Watch checking HEALERS only** — **declined by the owner 2026-10-03** ("only 1, no 2").
- **Plain names for the red sounds** (SharedMedia_Causese colours its names) — the owner: not
  important (2026-10-03).
- **The last flicker of the cast bar's slanted-end seam** — the owner lives with it (2026-10-02).
- **Option 2 of per-spec settings (a whole profile per spec)** — deferred by the owner 2026-10-01; he
  envisions "a master profile, with spec-specific overrides" if more such cases appear. Unit Frames'
  color-change count is the first override (`breakAtSpec`).

- **Carrying the old Portraits settings into Gloom's UI** — **NOT WANTED by the owner, 2026-09-29**:
  *"you can delete any existing portrait settings … I'll rebuild."* A portrait is just an overlay TYPE
  with ONE position (no separate 3D / 2D places).
- **A true cross-tool group (the Hub moving and scaling pieces of several tools as one)** — **NOT
  BUILT, by agreement 2026-09-30**: gloomUI groups ATTACH to a unit frame instead (the Hub's anchors).
  **A linked "unit scale" for Unit Frames** was deferred: gloomUI scales a group, the unit frame is
  adjusted by hand — the owner: "an acceptable compromise".
- **Undo per tool** — **REJECTED by the owner 2026-09-30**: one suite-wide history.
- **Texture Atlas Viewer as the browser's source** — **NOT NEEDED, 2026-09-30**: the game lists every
  atlas itself (`C_Texture.GetAtlasElements`), and the Sheets view groups them by file. The owner: "less
  concerned about TAV". FINDINGS §25.
- **Guessing a flipbook's grid** — **REMOVED 2026-09-30** (it was always wrong; FINDINGS §25). Everything
  loads still; the owner sets the grid against the lines, and it's remembered per name. Don't restore.
- **A script that packs a frame sequence (e.g. After Effects' PNG sequence) into a spritesheet** —
  offered 2026-09-30; the owner: build it **when he has a render**, not before.
- **Guild RANK as a text code** — the owner asked for `[guild]` and `[title]` only (2026-09-30).
- **"An image loads scrambled"** — check its size for EXACTLY 6:1 first (FINDINGS §25). Not our bug.

- **Merging Auras' Icon and Texture types** — **REJECTED by the owner 2026-09-27**: they are different
  to a user; they were made real instead (item 16's decisions).
- **An outline on Unit Frames BARS** — **REMOVED by the owner 2026-09-27** ("I still can't think of a
  use for it"); a stretched shape would have thickened its baked rim anyway. Arcs keep theirs.
- **Growing the upper layers' masks to hide the faint dark rim at a rounded bar end** — **TRIED and
  REVERTED 2026-09-29** (points where the curve begins, a flattened middle). The owner: *"I just live
  with it."* FINDINGS §21. Do not re-offer.
- **"Overlay and unit-frame sizes don't match"** — they DO: both are UI units on UIParent, measured
  equal with `/go debug` 2026-09-29 (the case was a health orb at 80, not 123). Check the numbers first.

- **Not-open records settled 2026-09-19 → 27** (the one big Suite window and baked glass, "soft" UI →
  check the display chain first (FINDINGS §22), glass buttons, text softness from SetScale, WEBP and
  texture sizes, the GU tab tidy, Audiowide, the jog-wheel dial, button shapes on unit frames, a
  shared arc/bar offset, WCAG thresholds, GU's mid-combat ruling) — moved to ARCHIVE.md ("NOT-OPEN
  RECORDS moved out of the BACKLOG — second batch, 2026-09-30"). **Read them there before re-raising.**
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
