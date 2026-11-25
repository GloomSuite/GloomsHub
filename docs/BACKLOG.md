# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-11-25 (the 2026-11-04 → 20 WoW Forever work is DONE and the owner has since dropped
Forever — ARCHIVE; item 29 is the next job. **Next: item 29, the Evoker's empowered casts.** Also still
unanswered: have the bars vanished again?)
---

## Open items

### 29 · Empowered casts (Evoker) have no indication on the cast ring / bar ★ START HERE
**Repo:** `~/GloomsUnitFrames` · **Size:** medium · **Evidence:** the owner's description only (2026-11-25); nothing
looked at in game yet. He is playing his Evoker more, so this matters.

The owner's words: *"some abilities are channeled but can be ended earlier than the full duration to modify the
results … there's no indication in the addon on the castbar for this kind of ability cast/channel."* That is an
**EMPOWERED cast** (Fire Breath, Eternity Surge, Upheaval …): the game reports it as a CHANNEL whose
`UnitChannelInfo` tenth return `numStages` is > 0; each stage has its own length (`GetUnitEmpowerStageDuration(unit,
stage)`), plus a hold-at-max window (`GetUnitEmpowerHoldAtMaxTime`); the events are `UNIT_SPELLCAST_EMPOWER_START /
UPDATE / STOP`. Blizzard's bar draws the stage DIVIDERS and lights each stage as it is reached. Today `CastState`
treats it as a plain channel, so the ring / bar drains with nothing marking the stages or which one is held.
Decide with him what the indication should be (dividers on the ring / bar like Blizzard's · a color per stage ·
a text piece naming the stage) before building. Remember 12.1's secrecy rules for a TARGET's cast (FINDINGS §21);
the player's own stage durations should be plain numbers — check first.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` · `CastState` and the cast section around it in
`~/GloomsUnitFrames/GloomsUnitFrames.lua` (~line 2720) · Blizzard's
`_retail_/BlizzardInterfaceCode/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/CastingBarFrame.lua` — the
`UnitChannelInfo` call with `numStages` (~line 419), `AddStages` (~line 1022) and the empower events · FINDINGS §21

---

### 27 · The 2026-10-06 → 15 builds — waiting on the owner's use ★ START HERE
**Repo:** `~/GloomsAuras` · `~/GloomsOverlays` · `~/GloomsBars` · `~/GloomsHub` · `~/SoulstoneWatch` (no git) ·
**Size:** his fixes as they come · **Evidence:** each harness-checked (0 errors in `sweep-v3.lua`, targeted
scripts); ✓ = the owner confirmed in game. Everything else is UNTESTED in game — don't call it done.
- **The vanishing action bars (Bars) — the one to ask about first.** FINDINGS §35. Stale `isShownExternal`
  is now cleared on "Always Visible" bars; re-assert on dismount; the stray-hide watch prints an orange
  chat line naming the culprit. The manual call was ✓ (bar 2 came back); **the automatic fix is not yet
  seen surviving a real occurrence.** If it recurs: paste the orange line. What sets off the camera UI
  mode is still unknown (the owner was asked, unanswered).
- **Auras — multi-select EDITS:** a change copies to every selected aura; Shift = range, Option = add / drop
  one; Position moves all by the same amount; names, group, order and eye stay each aura's own — not
  explicitly confirmed. The **eye on a selected aura toggles the whole set** ✓. Same edits in **Gloom's UI**
  (same kind only: texture vs portrait) — unconfirmed.
- **Auras, ✓:** Charged Color / Charged Point (Auto = its Player Power N; beats Color Change) · trigger
  "Ready again (after use)" (arms only in combat, resets leaving combat) · trigger "Ready in [N] sec left"
  (timed from use, base cooldown) · Shadow Dance "At max (Charges)" once the CDM row was Always Visible.
- **Auras, unconfirmed:** Duplicate Group (also Gloom's UI) · trigger Charged Combo Point · Effects follow a
  resize (0.15 s settle) · Intensity 1×–4× (stacked copies) · Stack Count (Text Only) · sample stacks while
  the panel is open · Player Power re-checks at once (combo points; FINDINGS §36) · re-Discover on panel open.
- **Bars:** the lime macro dot ✓.
- **Hub:** dropdowns open at the current choice (unconfirmed) · a font that can't draw its name falls back to
  Sansation · **every LSM font warmed at 10** — **the fresh-launch result was never reported** (FINDINGS §37).
- **All six TOCs + Soulstone Watch declare `120100, 120105`** (12.1.5). (Five of the suite TOCs also carry
  `16001`, WoW Forever — see ARCHIVE; Forever is dropped, the line is harmless.)
- **Soulstone Watch:** one cast no longer posts twice (the same caster within 2 s) — untested in a group; its
  raid-night test: buffs read HIDDEN at least once in a raid; the "hold a post until combat ends" fix was
  offered, not built. FINDINGS §38.
- **Older builds (items 22 and 24, 2026-09-30 → 10-04) moved to ARCHIVE on 2026-11-04** with their untested
  lists — look there if something from then misbehaves.

**Read first:** FINDINGS §33–§38 · `~/GloomsAuras/docs/HANDOFF.md` (the 2026-10-06 → 15 block) ·
`~/GloomsOverlays/CLAUDE.md` · `~/GloomsBars/docs/HANDOFF.md` (top block)

---

### 28 · Buffs and procs feel a beat late in Auras (the owner, 2026-10-08)
**Repo:** `~/GloomsAuras` (`CDM.lua`) · **Size:** unknown · **Evidence:** `OBSERVED` (FINDINGS §36) — cause
unproven; the path already reacts at once when the CDM reports. He can't compare it by eye against Blizzard's
icon. Wait for him to name one specific aura, then dig into that one.

**Read first:** FINDINGS §36 · in `CDM.lua`: `OnItemActiveChanged`, `RepollBuffPresence`, `UpdateVisibilityPoll`
### 25 · The 2026-10-05 builds — waiting on the owner's use
**Repo:** `~/GloomsBars` · `~/GloomsUnitFrames` · `~/GloomsAuras` · `~/GloomsOverlays` · **Size:** his fixes as
they come · **Evidence:** each harness-checked (0 errors in `sweep-v3.lua`, targeted scripts); ✓ = the
owner confirmed in game.
- **Bars:** Row Offset (per bar, cumulative per row) ✓ · Hide When Mounted (per bar; mounts + druid
  travel forms; a secure state driver — FINDINGS §29) ✓.
- **Unit Frames:** Hide When Mounted (Global) ✓ · Shaped Ends + End Shape (round / angled / point) and the
  square far end, the parallel slant, the square-off at a square end ✓ · the one-row step (§30) ✓ · the
  gradient on the first cast after a /reload (§31) ✓ · **Focus, Target of Target, Pet** (health, power,
  texts, a cast BAR; no auras) ✓ · hover TOOLTIP ✓ · the click box = health + power only — untested ·
  **Fill Texture** on Rectangle bars (+ Gloss beside it) — untested: the join at the moving tip, and a
  VERTICAL bar (the crop direction is assumed).
- **Auras:** groups as ANCHORS (selectable, Attach To, Scale, position, drag into / out of groups in the
  list, green brackets drag a group, arrow-key nudges) ✓ · the group-conflict note + coral warning ✓ ·
  **Game Art & Flipbooks** (the Hub's texture browser, atlases, `cfg.sheet`) — untested in game ·
  Duplicate in place — untested · group Scale may soften text (it is `SetScale`) — unseen.
- **Gloom's UI:** the group-conflict note + list warning ✓.
- **2026-10-06:** multi-select (shift-click; lime brackets move the set; arrow keys; drag a set into a
  group) ✓ in both · Auras' **Color Change** (Change When: a state or a resource At or Above → Change
  To) and flipbook **Direction** (Forward / Reverse / eased Ping-Pong, Hub `SheetFrame`) — the owner:
  "everything else is working great", not checked one by one · **drag-to-reorder** within a group in
  both lists (Auras `cfg.order`, Gloom's UI the overlay list's order) — untested in game.
- **Diagnostics left in on purpose (the owner: "just leave them")**: `/gb mountprobe`, `/gu endprobe`.

**Read first:** the repo's `CLAUDE.md` · FINDINGS §29–§31 · `~/GloomsAuras/docs/HANDOFF.md` (the 2026-10-05
block) · `~/GloomsUnitFrames/CLAUDE.md` (the 2026-10-05 block)

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

- **WoW Forever** — **DROPPED by the owner 2026-11-25** ("I'm going to stop playing Forever"). The support built
  2026-11-04 → 20 stays in the code, gated on `GloomsHub.IS_FOREVER` / `GB.IS_FOREVER`, inert in retail; the
  Forever install (`_forever_`, symlinks, copied settings) is left as it is. Record in ARCHIVE. Do not extend it,
  do not strip it.
- **The glow's outer bloom hiding under neighboring buttons on the slanted shapes (Bars)** — **DROPPED by the owner
  2026-11-20**. It is by design (the bloom is drawn UNDER the button); lifting the glowing button's frame level was
  tried and reverted the same day — `SetFrameLevel` is PROTECTED in combat (FINDINGS §42). The only real fix is
  hollow outer art per silhouette in the Hub; he said "drop it". The note at the top of `Glows.lua`'s reconciler says why.
- **Probing retail for the same `flyoutDirection` taint Forever showed** (FINDINGS §39's retail `SUSPECTED`) — the owner,
  2026-11-16: "I don't want to address now." Moot unless retail ever shows Edit Mode / flyout taint errors.
- **Command-click to add to a multi-select** — **ABANDONED by the owner 2026-10-06** ("I'll just learn to use
  option"). WoW turns it into a plain right-click (FINDINGS §33). Three attempts, removed. Don't retry.
- **Stack thresholds (a bar / text color at N, "show at 1 or less", a Min Stacks layering trick)** — the count
  is secret in combat; the trick was offered twice and he passed ("It's fine", "I'll work around it").
- **Glow thickness / size controls** — offered with Intensity 2026-10-10; he took Intensity only.
- **A per-row Hide Blizzard CDM** — offered 2026-10-10; Always Visible + Hide Blizzard CDM worked for him.
- **Drop shadows on bars / unit frames** — **DECLINED by the owner 2026-10-05**: WoW has no blur, so a
  shadow means pre-blurred art per shape in fixed steps — "just not worth the effort".
- **Smarter "Hide Blizzard's Cast Bar" (let quest meters through)** — **DECLINED 2026-10-05**: a Brewfest
  quest's meter IS the player cast bar (FINDINGS §32); the owner flips the setting off for it.
- **A class-points OTHER TRIGGER in Auras** — **NOT NEEDED, 2026-10-05**: the Player Power LOAD condition
  on a trigger-less aura does it (§29's addendum).
- **Duplicate As… landing beside the original** — the owner's own 2026-09-27 ask; plain Duplicate stays
  in place (2026-10-05).

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
