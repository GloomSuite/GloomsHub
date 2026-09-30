# Gloom Suite — STATE

> **Where things stand. Settled facts only.**
>
> Nothing provisional belongs here — a guess written beside a fact inherits the fact's authority,
> which is exactly how a wrong conclusion nearly cost a day's work on 2026-07-26. Diagnosis lives in
> [FINDINGS.md](FINDINGS.md) with an evidence tag; open work lives in [BACKLOG.md](BACKLOG.md).
>
> **Keep this file short enough to re-read.** If it passes ~180 lines, move the settled history to
> [ARCHIVE.md](ARCHIVE.md). A document nobody re-reads is a document nobody corrects.

**Last updated:** 2026-09-29 (**the FOURTH Suite design, "two windows", is on master for ALL SIX
tools**: a selector + a settings window per tool, sections with pop-outs, Global Settings, Sansation
only — `LibGloomSkin` **MINOR 18**, the Hub's `Windows.lua`. Portraits, Overlays and Media joined on
2026-09-27, built without mocks; nothing opens in the old big window any more. BACKLOG 16 holds the
brief and its decisions.)

---

## The one-paragraph answer

**The 7-phase plan is complete and QA'd. Five addons: the Hub and four tools.** GloomsHub is the
shared base; Bars, Auras, **Gloom's UI** (the `GloomsOverlays` folder — Overlays with Portraits folded
in as an overlay type since 2026-09-29) and **Unit Frames** each mount their windows in it and
hard-depend on it. **Gloom's Portraits is retired** (its AddOns symlink removed 2026-09-29; the repo
and its public copy untouched — the owner's call what happens to them). StoneTweaks is retired; **all six suite repos are public under the
`GloomSuite` org** (Build Barn stayed with `HandofDevastation`); `GloomsUnitFrames` went up on
2026-09-20, verified anonymously (author `Gloom`, no linked account). **Hub, Bars and Auras are at
`v1.4.0`; Overlays at `v1.3.0`; Portraits at `v1.0.0`** with stage 2 on `master` untagged; Unit
Frames untagged. Versions drift by design — do not "level" them. What's left is in
[BACKLOG.md](BACKLOG.md).

**★ Patch 12.1 went LIVE on 2026-08-11, and every suite TOC declares `## Interface: 120100`**
(bumped 2026-08-12; the number was read off the installed addon set, not assumed).

**Known live bugs in shipped code: none the owner has reported.** (The Quick Keybind concern that
used to sit here was CLOSED as not a GB bug — FINDINGS §8 — and the two bugs found since, FINDINGS
§13 and §5, were fixed the day they were found and are in `v1.4.0`/master.)

**The release ZIPs are verified at every cut, never assumed** — no drop-in media, no identifying
filename, both manifests EMPTY (they are tracked files the in-game tooling WRITES, so they show up
populated in the working tree and must never be staged). The v1.3.0 verification record and the
wowace-outage note moved to [ARCHIVE.md](ARCHIVE.md) 2026-09-19; the rules live in
[LESSONS.md](LESSONS.md) § Git, GitHub & packaging.

---

## Phase status

**All seven phases (A-G) are complete and QA'd**, the last on 2026-07-25. The per-phase table and
its full QA evidence moved to [ARCHIVE.md](ARCHIVE.md) on 2026-08-24 — nothing in it has changed
since it was written, and it was pure history sitting in the file people re-read. Do not redo any
of it.

---

## Locked decisions — do not reopen

- **Gloom's UI = Overlays + Portraits, in the `GloomsOverlays` FOLDER** (2026-09-29, the owner): the
  folder and `VibeOverlayDB` never renamed; a portrait is an overlay TYPE; the old portrait settings
  were not carried over. Groups attach to other tools' frames through the Hub's ANCHORS (CONTRACTS §2).
- **ONE undo history for the whole suite; ONE window place for every tool** (2026-09-30, the owner).

- **Shared base = GloomsHub**, permanent asset path `Interface\AddOns\GloomsHub\…`.
- **★ THE SUITE UI IS BEING REBUILT FROM THE OWNER'S FIGMA MOCKS — THE TWO-WINDOW DESIGN**
  (Figma page "GloomSuite UI 3", 2026-09-27; the three earlier designs are in ARCHIVE). A rebuilt tool
  (`windows = true`) gets a SELECTOR window and a SETTINGS window (its sections, one open at a time,
  each able to pop out into a window of its own), drawn and managed by the Hub's `Windows.lua`;
  height-only resizing, drag-anywhere moving, all remembered; Global Settings (every tool's profile,
  the tools' own switches, the Addon UI Scale) is the Hub's and the same everywhere. **Sansation only;
  ONE palette** (violet · lilac · lime); **every control at its mock's own x/y inside its section**; a
  control that cannot apply DIMS to 30%, never hides; labels Sansation 10 with the control 15 under,
  rows 41 apart, blocks 30; **"Use Class Color" in every color picker** (a color that follows the
  logged-in class, re-colored at login — CONTRACTS §4); world tooltips hidden where they would cover
  a window; one-screen-pixel outlines; the UI Scale offers
  whole-pixel sizes (+ in-between), 100% = the sharp size nearest the rest of the player's UI.
  CONTRACTS §2/§4 hold the API and the kit; FINDINGS §22 the sharpness evidence (check the owner's
  DISPLAY first). **Do not tidy or restyle an un-rebuilt tool on its own** — each is rebuilt from its
  mocks; until then it opens in the old big window (Shell.lua).
- **★ THE SILHOUETTE CATALOG AND THE ANIMATION ENGINE ARE THE HUB'S** (2026-08-25). Shapes, their
  art, and the eight effect modules serve GB *and* GA, so they have one home like every other shared
  fact. **Since 2026-09-21 the Hub carries TWO families**: the button shapes (GB, GA) and the
  BAR shapes (GU) — same mechanism, separate lists and art, never mixed in a picker (the owner's
  ruling). Bar shapes come from `tools/gen-barshapes.py` (generated or imported, with measured
  footprints, `-base-s` and three rim widths); sets nest by sharing a canvas. **The routing tables in the Hub's and GB's `CLAUDE.md` said "shapes/catalog + art" and
  "glows" belonged to GB; both were rewritten in the same session.** Do not "restore" them — that
  line predates GA drawing shapes at all. What stayed GB's: which shape a button wears, the Bars-tab
  picker, the plate extension, and all glow triggering.
- **Four separate addons + one shared base**, not a mega-addon. The Hub ships its own release.
  **★ The FIFTH tool is Gloom's Portraits** (decided and built 2026-09-19) — 3D/2D player + target
  portraits, its own repo `GloomSuite/GloomsPortraits`, hard-depending on the Hub like the others.
  Not into the Hub (shared infra, not a tool), not into Overlays (a 3D model is not a textured
  overlay). ⚠ Its predecessor's name is not publishable (Hub `CLAUDE.md` PRIVACY); the one permitted
  survivor is the old SavedVariables global in its copy-migration, the `StoneTweaksDB` precedent.
  **★ The SIXTH tool is Gloom's Unit Frames** (decided and built 2026-09-19) — circular health /
  power / class-resource / cast rings for player and target, meant to REPLACE EllesmereUI's player
  and target frames outright (EUI keeps ToT/focus/pet/boss via its per-unit *hidden* source). Its
  own repo, not Portraits: the owner — "they're not necessarily going to be linked in any fashion".
  Not clickable unit buttons yet. Auras, texts, class color and the shield wash are BUILT
  (2026-09-19); profiles, DK runes and the aura-group preview followed (2026-09-20); **BAR MODE
  — every display as an arc OR a StatusBar cut to a silhouette, with a real absorb overlay, an
  outline, and per-display strata/level — landed 2026-09-21 (FINDINGS §21).** **The "This
  spell" kind is GONE (2026-09-20)** — the engine ignores spell-ID filters on the player's debuffs
  (FINDINGS §20.6), and a highlight that cannot single out a debuff was "effectively useless" (the
  owner). Do not rebuild it on `includeSpellIDs`. What remains is BACKLOG item 12 (watching) and
  the tab's tidy pass, item 13.
- **★ DISTRIBUTION: SYMLINKS FOR THE OWNER, CURSEFORGE IF EVER PUBLIC — the WoWup path is RETIRED**
  (the owner, 2026-09-19). Every suite addon on his client is a symlink into `~/<repo>`; WoWup's
  GitHub install "doesn't work very well" (Build Barn and Loot Advisor both moved to CurseForge over
  it). A tag still cuts a GitHub Release, and that is now a version MARKER and nothing else — not a
  delivery. Do not verify `latest` for WoWup's sake, do not frame a change as "so WoWup picks it
  up", do not tell him to install a release. CurseForge setup (project IDs, token) happens only when
  he says the suite goes public.
- **★ THE HUB REGISTERS ITS MEDIA AT ITS OWN `ADDON_LOADED`, NOT AT `PLAYER_ENTERING_WORLD`**
  (2026-09-19). Every addon that sorts before "G" builds its frames at `PLAYER_LOGIN`; registering
  after that let LibSharedMedia hand them its DEFAULT font for the owner's name, which they cached
  (FINDINGS §16). The font load-CHECK stayed at PLAYER_ENTERING_WORLD on purpose (FINDINGS §5). Do
  not move either one back.
- **HARD dependency on GloomsHub, no standalone fallback** (2026-07-24). Each tool deleted its own
  window; its config renders ONLY inside the Hub's shell. Chosen over graceful fallback precisely to
  avoid two window paths that could drift. A tool installed without the Hub fails **loudly**.
- **★ VERSIONS MAY DRIFT — release only the addon that changed** (2026-07-25). *"It doesn't bother
  me if the versions of the individual units drift."* The shell lists every installed addon's
  version (since the redesign, as the hover-tip of the window's wordmark), which is what retired
  the reason for synchronizing them. (The one-time `v1.2.0`
  squaring-up of 2026-07-26 was a tidy-up after the PII purge, not a standing rule — ARCHIVE.)
- **★ EVERY `LibGloomSkin` CONSUMER CARRIES A VERSION GATE** — pinned in [CONTRACTS.md](CONTRACTS.md)
  §6. This is what makes drift safe. `## Dependencies: GloomsHub` checks only that the Hub is
  PRESENT, never that it is NEW ENOUGH — WoW's TOC system has no version constraint. Each consumer
  declares `SKIN_NEEDS` and returns early with one actionable line.
  **★ Bump `SKIN_NEEDS` in the SAME commit that first calls a newer widget** — the only way to
  defeat the gate is to forget.
- **One profile/preset mechanism for the whole suite** (2026-07-24) — `UI.profileBlock`, MINOR 3.
  **GB is the UI reference for the suite, not GA.** When a pattern exists in both, copy Bars.
  ★ **New vs Copy settled 2026-08-15:** New = the FACTORY look, Copy = a full duplicate of the
  active profile. GA and Overlays always worked this way; GB snapshotted the current look for both
  and was the outlier. It now matches. `accent` (MINOR 7) recolours the buttons — GB's rail draws
  PROFILE purple at the top and PRESET orange at the bottom, because two of these blocks stacked in
  one colour read as a single control.
- **No self-arming "click twice" confirms** (2026-07-24). Destructive actions use `UI.confirm`,
  which has a Cancel and an ESC.
- **One colour picker for the whole suite** (2026-07-26, **fully owner-QA'd the same day**) —
  `UI.colorPicker`, MINOR 6. **The last
  native Blizzard frame anywhere in the suite is gone**; `ColorPickerFrame` appears nowhere in any
  of the four repos. ★ **It is deliberately NOT modal** — it changes an element while it is open, so
  it takes no scrim and IS draggable. Do not "fix" that to match `nameDialog`/`confirm`.
  Its palette holds **the user's own element colours**, never the suite's design tokens.
- **StoneTweaks is fully retired**; its media half is the Hub's Media tab. The
  `StoneTweaks_ResolveAssetPath` compat shim in `Core.lua` is **KEPT PERMANENTLY** (CONTRACTS §3) —
  do not "clean it up."
- **VibeOverlay → Gloom's Overlays**, reskinned in one go. The `Vibe` name is retired; the slash
  is `/go`.
- **Gloom's Build Barn is OUT of the suite** — a data-fed cron pipeline, not a tab tool.
- **Never "v1" / "later phase" framing. GUI over slash for user controls.**

---

## What is physically in place

**`~/GloomsHub`** — symlinked into AddOns. `Core.lua` (namespace, `GloomsHubDB`, ST copy-migration,
the permanent compat shim, `/gh` probe) · `Skin.lua` (**the body of `LibGloomSkin-1.0`**, LibStub-
registered, **MINOR 13** — tokens, toolkit, `WarmFonts`/`RegisterWarmPairs`, the suite's own colour
picker + its "in use" palette, the two-column `UI.grid`, the `UI.cog` → `UI.popover` sub-settings
panel, every edit box's Tab ring and Up / Down stepping, the profile-delete gate, **and THE KIT
(2026-09-21): the redesign's tokens and widgets — `UI.button / segments / toggleBar / check /
field / pick / sectionHeader / dial (short · bare) / chip / cell / wordmark / profileRow`, the kit
scrollbar, the dialogs, tooltip, popover and picker (with its colour SOURCES) on the night plate,
the revised dropdown list**, **and THE DARK KIT (MINOR 13, 2026-09-23 — the second design's, unused by any rebuilt tool now)**,
**and THE GLASS KIT (MINOR 14) restyled as THE TWO-WINDOW KIT (MINOR 15-16, 2026-09-26/27): Sansation,
stretched `UI.gButton / gSwitch / gDrop / gField / gDial / gCheck / gColor` (the color PILL), `UI.gList`
(the owner's Dropdown/Popup mock), `UI.gHair` (one-pixel lines), `UI.gRounded`, `UI.gWindow` (tab ·
body · floating close · resize grip), `UI.gSectionHead`, `UI.gScrollArea` (fades + bar),
`UI.gProfileBlock`, `UI.G_DIM` (30%), `UI.G_NUDGE` (0, measured), and (MINOR 17) the class-color
source + `UI.StampClassColors`** — the older widgets kept, drawing on the light plate for the tabs
not yet rebuilt; `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are aliases) · **`Shapes.lua`** (the suite's silhouette catalog — 21 shapes,
`GloomsHub:ShapeAsset/ShapeInfo/GrowAnchor` — **the ONE grow-anchor; GB's `hgAnchor` delegates
to it since 2026-09-20**) · **`Effects.lua`** (the eight shaped animation
modules + `GloomsHub.Effects`) · `Shell.lua` (the Suite window: `RegisterTab`/`Open`/`FocusTab`/
`ToggleWindow` + `/gloom`, `/gloom px` (the pixel-grid probe — also the window's and the hovered
control's edges), `/gloom texttest`, `/gloom fonttest`) · **`Windows.lua`** (the two-window Suite:
selector, settings, pop-outs, Global Settings, the level bands that keep overlapping windows apart;
`Shell.lua` routes a `windows` tool to it; the tool rail) · **`Undo.lua`** (the suite's one undo
history + the arrow-key nudges, 2026-09-30) · **`Anchors.lua`** (frames tools attach to, 2026-09-30) ·
`Media.lua` (LSM registration — `RegisterAll` at the Hub's
ADDON_LOADED, `VerifyFonts` at PLAYER_ENTERING_WORLD — `ResolveAssetPath`, `ListMedia`, the
Media tab, and since 2026-09-30 THE TEXTURE BROWSER — gloomMEDIA → Game Textures and `PickTexture`) · `MinimapButton.lua` (**the ONE suite launcher** — never one per tool). `Shell.lua`
is the OLD big window, kept for the tools not yet rebuilt (their old layouts, unscaled, on the light
plate under the top bar); its glass-page code has no users now. `tools/figma.py` reads the
mocks straight from the Figma desktop server (the app's connector lists no tools).
`tools/gen-kit-art.py` generates the dark kit's art; **`tools/gen-glass-art.py`** the glass
kit's (4× marks, from the owner's SVGs in `tools/glass-svg/`; `v3` = the pop-out icons and the pill art). **`tools/harness/`** runs the suite's UI outside the game (a WoW-API stand-in, the real
TOCs and SavedVariables, a click-everything sweep, and a renderer that draws the built window
to PNG, one window at a time) — how the two-window Auras and Bars were verified before the owner saw
them (`sweep-v3.lua`, `shoot-v3.lua`).

**The shape catalog and the animation engine are the Hub's since 2026-08-25** (a locked decision
above); GB keeps the aliases so its call sites never moved, and **GB's `Glows.lua` shaped halo
deliberately did NOT move** (entangled with Blizzard's spell-alert hooks). The move's record and
QA are in [ARCHIVE.md](ARCHIVE.md).

**Tracked assets are `Media/` ONLY** — Khand ×2, GeneralSans ×3, Play ×2, Michroma, **Saira ×3
(Regular · Bold 2026-09-23, Medium 2026-09-25 — no longer drawn), Sansation ×3 (Light · Regular ·
Bold, 2026-09-27 — the only face the rebuilt tools draw)** — all licences beside them — the GS and Gh marks, the
kit's UI art (`Media/ui/`: `round4` `pill` `dot` `tri` `dial` `dial-c`, and the dark kit's
`pill/cap22|25-fill|rim` `suite-wordmark` `check` `circle` `circle-dash` `dial-ticks`, and the glass
kit's `g-*` marks — `g-corner`, `g-pill-*`, `g-dash`, `g-popout`, `g-popin` since 2026-09-26/27), plus **`Media/art/shapes/` (136 silhouette files) and `Media/art/effects/` (5 shared effect
textures)**. `Libs/` is gitignored and pulled by the packager. ⚠ **`Fonts/`, `Textures/` and `Graphics/`
are the USER's drop-in directories and are gitignored** (2026-07-26). They still exist on the
owner's disk — 7 / 13 / 45 files, which his catalog resolves normally — but they are not in the repo,
not in history, and not in any release. **Never track them.**

**`~/GloomsBars`** — `main`. Hard-deps the Hub; local toolkit and standalone window deleted; mounts
the **Bars** tool; `/gb` → `ToggleWindow("bars")`. `SKIN_NEEDS = 16`: **a TWO-WINDOW tool since
2026-09-27** — the PREVIEW window (the state chips, the live construction, the caption) and seven
sections (Icon Size & Shape · Decoration Layers · Text · Glows & Animations · Casts & Channels ·
Cooldowns & Availability · Bar Visibility, Layout & Presets) under the "Editing Preset" tab; all at
the end of `Config.lua`. The per-bar Empty Icons is a Global / Show / Hide override (`Skin.lua`
`emptyOverride`).

**`~/GloomsAuras`** — `main`. Hard-deps the Hub; since 2026-09-27 a TWO-WINDOW tool drawn by
**`Pages.lua`** (the selector's groups and auras, the aura tab, six sections; it gates itself on
LibGloomSkin 16; groups and auras have right-click menus, groups drag to reorder), running on `Config.lua`'s logic through its `C.X` exports; the previous editor's
builders in `Config.lua` are unmounted and kept until the owner approves the new one.
`Config.lua`'s own `SKIN_NEEDS = 6`. An aura now has a frame **Level** (`cfg.level`, applied in
`Displays.lua`; nil = the frame's own). Since 2026-08-25 it
also consumes the Hub's shapes and effects: a per-aura **Shape** (crops the texture, shapes the
animation), the **eight animations** with a settings popup built from each module's own schema,
**Effects only** (draws no artwork — for overlaying a live action button), and **rotation** as both a
fixed angle and a continuous spin.

**`~/GloomsOverlays`** — `master`. Hard-deps the Hub; its windows are `GloomsOverlays_Pages.lua`
(`SKIN_NEEDS = 17`; `GloomsOverlays_Editor.lua` is out of the TOC, to delete once approved); frame
pooling and in-place layout apply; all nine stratas plus a numeric Level; the eye is a while-editing
preview (`ov.preview`, `GloomsOverlays_SetPreview` / `SetPick`); `/go debug` prints real sizes.

**`~/GloomsPortraits`** — `master`. Hard-deps the Hub; two files — the ENGINE (`GloomsPortraits.lua`:
frames, `GloomsPortraitsDB`, the secret-identity handling of FINDINGS §17, a small API on the
`GloomsPortraits` namespace) and its **windows** (`GloomsPortraits_Pages.lua`, `SKIN_NEEDS = 17`,
order 40; the old `GloomsPortraits_Tab.lua` is out of the TOC). A **Level** within the strata since
2026-09-29 (per mode, 0 = Auto). `/gp` → `ToggleWindow("portraits")`. No profile block (two fixed units, one account-wide
config), no minimap button, no floating panel. Each mode keeps its own size/position/layer
(`cfg.layouts[mode]`); the in-combat 2D stand-in wears the 2D set; a unit's visibility can be
**Off** (`showCondition = "never"`, 2026-09-21). The Gp mark is
`Media/ui/logo.png`, composed from the family G and GB's b flipped.

**`~/GloomsUnitFrames`** — `GloomSuite/GloomsUnitFrames`, `master`, symlinked into AddOns. Hard-deps
the Hub; four files — the ENGINE (`GloomsUnitFrames.lua`: the arc renderer of FINDINGS §18,
`GloomsUnitFramesDB` **v2 = `{ profiles = { [name] = { player, target } }, charProfiles }`** — the
engine's `db` is the ACTIVE profile, an unbound character lands on "Default", the v1 account-wide
config became that profile — rings per unit in 16-level bands, class/reaction color, the shield
wash of §19, DK runes counted via `GetRuneCooldown` (`UnitPowerPercent` does not take them), the
cast/kick logic — a target's secret cast drawn from the duration object's percent evaluators
(§18.10) — a small API + `/gu debug` / `/gu probe` / `/gu gate` / `/gu auras` / `/gu casttrace`),
the **TEXT pieces** (`GloomsUnitFrames_Text.lua`: shortcode templates → one `SetFormattedText`),
the **AURA groups** (`GloomsUnitFrames_Auras.lua`: Buffs / Debuffs `AuraContainer` groups with
class filters and Hub shapes — FINDINGS §20; the sample-icon PREVIEW while the tab's Auras section
is open) and the **Unit Frames windows** (`GloomsUnitFrames_Pages.lua`, `SKIN_NEEDS = 17`, **a
TWO-WINDOW tool since 2026-09-27**: the selector is Player | Target, the tab "gloomUNITS: <unit>", seven
sections from the owner's mocks — Global <Unit> Settings (with Copy Settings from the other unit and
Reset to Defaults), Texts (rows + the Shortcodes popup), Auras (rows + the Filters popup), and the four
rings from one row-flow builder with an ARC and a BAR face; `GloomsUnitFrames_Tab.lua`, the first
design's tab, is out of the TOC and waits to be deleted). The engine's BAR renderer
(`NewBar`, FINDINGS §21) sits beside the arc renderer; `/gu bar <ring> …` drives it from chat.
`/gu` → `ToggleWindow("unitframes")`. Art in `Media/art/` is GENERATED (Python/PIL, the
scripts were throwaway): `disc.png` + its ramp companion and `disc-ramp-10…90.png` (the ramp at
narrower fade widths, for the shield wash), the two half-plane masks per sweep direction, the two
"lead" masks, `hole.png`, `cap.png`, and for bars `ramp.png` / `ramp-v.png` (plain gradient
ramps) and `hatch.png` (the 8 px absorb stripe tile). The Gu mark is still the Hub's logo — a real
mark is owed.

⚠ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys SavedVariables off
the addon FOLDER name; 23 save files were copied in place and **12 characters ride non-Default
profiles**. Renaming those globals is silent data loss, not cleanup.

**Live on the owner's account:** `GloomsHubDB` = 1 font / 6 textures / 36 graphics,
`migratedFromST = true`. The Hub is the only media registrar and wins all 7 LSM names with no
collision.

---

## ⚠ Standing hazards

- **Two Desktop folders must NOT be deleted** — `~/Desktop/VibeOverlay-retired-2026-07-24` (the ONLY
  copy of the pre-rename Overlays source; git never held it) and
  `~/Desktop/StoneTweaks-retired-2026-07-24` (the rollback for the Hub's media half). Details in
  [ARCHIVE.md](ARCHIVE.md).
- **Every suite addon points at its normal repo on BOTH the retail and PTR clients**, so an edit is
  live on both. Remember that before editing during PTR work.
- **★ `~/GloomsBars/IconsHD/` is the ONLY copy of the owner's hand-authored action-bar icons.** It is
  gitignored by design (his art must never enter a public repo), so git holds nothing and deleting
  the folder destroys the work permanently. `IconsManifest.lua` IS tracked, but it is only an index
  of filenames — it cannot rebuild the art. **Never clean, reset or `git clean -x` that folder**, and
  if he ever mentions backups, this is the thing that needs one.

---

## How to keep this honest

1. **Settled facts only.** Anything unproven goes in [FINDINGS.md](FINDINGS.md) with a tag.
2. **Closed work leaves.** When an item closes, its record moves to [ARCHIVE.md](ARCHIVE.md) — it
   does not accumulate here as another "before that…" clause.
3. **Point, never copy.** A cross-cutting fact restated in a second repo *will* go stale; release
   state was copied into three sibling docs and all three were wrong within a day.
4. **The handoff ritual maintains this file.** See the Hub's [CLAUDE.md](../CLAUDE.md).
