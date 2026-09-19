# Gloom Suite — STATE

> **Where things stand. Settled facts only.**
>
> Nothing provisional belongs here — a guess written beside a fact inherits the fact's authority,
> which is exactly how a wrong conclusion nearly cost a day's work on 2026-07-26. Diagnosis lives in
> [FINDINGS.md](FINDINGS.md) with an evidence tag; open work lives in [BACKLOG.md](BACKLOG.md).
>
> **Keep this file short enough to re-read.** If it passes ~180 lines, move the settled history to
> [ARCHIVE.md](ARCHIVE.md). A document nobody re-reads is a document nobody corrects.

**Last updated:** 2026-09-19 (Hub/Bars/Auras at `v1.4.0`, Overlays deliberately left at `v1.3.0`;
LibGloomSkin at MINOR 8. Hub media registration moved to ADDON_LOADED; a FIFTH tool, Gloom's
Portraits, is decided and not yet built — BACKLOG item 11.)

---

## The one-paragraph answer

**The 7-phase plan is complete and QA'd. All four addons ship and install cleanly.** GloomsHub is the
shared base; Bars, Auras and Overlays each mount a tab in its window and hard-depend on it.
StoneTweaks is retired, all five repos are public under the **`GloomSuite`** org (Build Barn stayed
with `HandofDevastation`). **Hub, Bars and Auras are published at `v1.4.0`; Overlays remains at
`v1.3.0`** (2026-08-24, verified anonymously against `/releases/latest`, not copied). **This is the
first real version drift and it is correct** — Overlays was not touched, and the locked decision
below permits exactly this. Do not "level" it. What's left is in [BACKLOG.md](BACKLOG.md) — eight
items.

**★ Patch 12.1 went LIVE on 2026-08-11, and all four suite TOCs now declare `## Interface: 120100`**
(bumped 2026-08-12; the number was read off the installed addon set, not assumed). **Shipped in the
`v1.3.0` cut on 2026-08-15** — WoWup users are no longer flagged out of date.

**★ The Hub gained a SOUND CATALOG on 2026-08-24.** Sounds registered into LibSharedMedia — which
is what puts them in GA's sound picker and every other LSM-aware addon. Two routes: a FileDataID or
filename typed into the Media tab, or bulk via `Sounds/` + `SoundsManifest.lua`. **WoW cannot
enumerate a folder**, so the manifest is a generated index — `Rebuild Sounds.command` (double-click)
→ `tools/build-sound-manifest.sh` → `/reload`. Exactly the pattern GB's `IconsManifest.lua` uses.
⚠ `Sounds/` is git-ignored and **`SoundsManifest.lua` ships EMPTY**, same rule as GB's icon
manifest: the mechanism ships, the owner's audio does not.

**★ GA gained three trigger/sound features on 2026-08-24** — a `CASTABLE` trigger state
(`cd_ready AND IsSpellUsable`, the only way to see a proc), a PLAYER POWER load condition (17 power
types, whole units), and a "When it comes off cooldown" sound timing that fires on a real cooldown
transition rather than the display's shown edge. See FINDINGS §12.

**★ GA gained a new subsystem on 2026-08-12: the 12.1 duration engine** (`AuraDuration.lua` +
`AuraDuration.xml`, GA's first XML file). It renders DoT timers and stack counts on 12.1 by driving
regions a Blizzard `AuraButton` owns. Owner-QA'd. See FINDINGS §1.
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

- **Shared base = GloomsHub**, permanent asset path `Interface\AddOns\GloomsHub\…`.
- **★ THE SILHOUETTE CATALOG AND THE ANIMATION ENGINE ARE THE HUB'S** (2026-08-25). Shapes, their
  art, and the eight effect modules serve GB *and* GA, so they have one home like every other shared
  fact. **The routing tables in the Hub's and GB's `CLAUDE.md` said "shapes/catalog + art" and
  "glows" belonged to GB; both were rewritten in the same session.** Do not "restore" them — that
  line predates GA drawing shapes at all. What stayed GB's: which shape a button wears, the Bars-tab
  picker, the plate extension, and all glow triggering.
- **Four separate addons + one shared base**, not a mega-addon. The Hub ships its own release.
  **★ A FIFTH tool is decided (2026-09-19): "Gloom's Portraits"** — the owner's stand-alone
  `StoneModel` addon (3D/2D player + target portraits) joins the suite as `GloomsPortraits`, its own
  repo under `GloomSuite`, hard-depending on the Hub like the others. Not into the Hub (shared infra,
  not a tool), not into Overlays (a 3D model is not a textured overlay). Not built yet — BACKLOG 11.
- **★ THE HUB REGISTERS ITS MEDIA AT ITS OWN `ADDON_LOADED`, NOT AT `PLAYER_ENTERING_WORLD`**
  (2026-09-19). Every addon that sorts before "G" builds its frames at `PLAYER_LOGIN`; registering
  after that let LibSharedMedia hand them its DEFAULT font for the owner's name, which they cached
  (FINDINGS §16). The font load-CHECK stayed at PLAYER_ENTERING_WORLD on purpose (FINDINGS §5). Do
  not move either one back.
- **HARD dependency on GloomsHub, no standalone fallback** (2026-07-24). Each tool deleted its own
  window; its config renders ONLY inside the Hub's shell. Chosen over graceful fallback precisely to
  avoid two window paths that could drift. A tool installed without the Hub fails **loudly**.
- **★ VERSIONS MAY DRIFT — release only the addon that changed** (2026-07-25). *"It doesn't bother
  me if the versions of the individual units drift."* The shell footer lists every installed addon's
  version, which is what retired the reason for synchronizing them.
  **Still true after the 2026-07-26 sync to `v1.2.0`** — the owner asked for a one-time squaring-up
  because the Hub's published releases had just been deleted in the PII purge, which would have left
  the shared base looking *older* than its own dependents. That was a tidy-up of a specific mess, not
  a standing requirement. Do not synchronize versions again by default.
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
registered, **MINOR 8** — tokens, toolkit, `WarmFonts`/`RegisterWarmPairs`, **the suite's own colour
picker + its "in use" palette**; `GloomsHub.COLOR/.FONT/
.UI/.MEDIA` are aliases) · **`Shapes.lua`** (the suite's silhouette catalog — 21 shapes,
`GloomsHub:ShapeAsset/ShapeInfo/GrowAnchor`) · **`Effects.lua`** (the eight shaped animation
modules + `GloomsHub.Effects`) · `Shell.lua` (the Suite window: `RegisterTab`/`Open`/`FocusTab`/
`ToggleWindow` + `/gloom`) · `Media.lua` (LSM registration — `RegisterAll` at the Hub's
ADDON_LOADED, `VerifyFonts` at PLAYER_ENTERING_WORLD — `ResolveAssetPath`, `ListMedia`, the
Media tab) · `MinimapButton.lua` (**the ONE suite launcher** — never one per tool).

**The shape catalog and the animation engine are the Hub's since 2026-08-25**, moved out of GB so
Gloom's Auras could draw the same silhouettes without a second copy of 136 files. GB still owns
which shape a button wears, its picker, the plate extension and all glow TRIGGERING; the Hub owns
the vocabulary, the art and the renderers. GB's `HAND_SHAPES`/`HAND_ORDER`/`HAND_GROUPS`/`HandAsset`
are unchanged aliases onto the Hub's, so its ~25 call sites never moved, and `GB.Anims` kept its
whole public surface (`Get`/`Each`/`Params`/`Enabled`/`Reconcile`/`Invalidate`/`PreviewReconcile`)
so its `Config.lua` and `Glows.lua` did not change at all. Owner-QA'd: all 21 thumbnails, procs and
animations identical before and after. ⚠ **GB's `Glows.lua` shaped halo did NOT move** — it is
entangled with Blizzard's spell-alert hooks and has a solid centre that only works because an opaque
button icon hides it. GA gets its glow from the HOLLOW rim-based modules instead.

**Tracked assets are `Media/` ONLY** — Khand ×2, GeneralSans ×3, their licence files, the GS and Gh
marks, plus **`Media/art/shapes/` (136 silhouette files) and `Media/art/effects/` (5 shared effect
textures)**. `Libs/` is gitignored and pulled by the packager. ⚠ **`Fonts/`, `Textures/` and `Graphics/`
are the USER's drop-in directories and are gitignored** (2026-07-26). They still exist on the
owner's disk — 7 / 13 / 45 files, which his catalog resolves normally — but they are not in the repo,
not in history, and not in any release. **Never track them.**

**`~/GloomsBars`** — `main`. Hard-deps the Hub; local toolkit and standalone window deleted; mounts
the **Bars** tab; `/gb` → `ToggleWindow("bars")`. `SKIN_NEEDS = 5` (its font picker branches on
`UI.setFont`'s return value).

**`~/GloomsAuras`** — `main`. Hard-deps the Hub; mounts the **Auras** tab, fully reworked 2026-07-25
(rail + full-width editor; splash, name banner and four drawers gone); `SKIN_NEEDS = 6` (its
`MakeColor` drives `UI.colorPicker`; its private ColorPickerFrame flow is gone). Since 2026-08-25 it
also consumes the Hub's shapes and effects: a per-aura **Shape** (crops the texture, shapes the
animation), the **eight animations** with a settings popup built from each module's own schema,
**Effects only** (draws no artwork — for overlaying a live action button), and **rotation** as both a
fixed angle and a continuous spin.

**`~/GloomsOverlays`** — `master`. Hard-deps the Hub; mounts the **Overlays** tab; frame pooling and
in-place layout apply; all nine stratas plus a numeric Level.
⚠ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys SavedVariables off
the addon FOLDER name; 23 save files were copied in place and **12 characters ride non-Default
profiles**. Renaming those globals is silent data loss, not cleanup.

**Live on the owner's account:** `GloomsHubDB` = 1 font / 6 textures / 36 graphics,
`migratedFromST = true`. The Hub is the only media registrar and wins all 7 LSM names with no
collision.

### ⚠ Two Desktop folders that must NOT be deleted
- **`~/Desktop/VibeOverlay-retired-2026-07-24`** — the ONLY copy of the pre-rename VibeOverlay
  source. Git never held it: GloomsOverlays' first commit already contains the renamed files.
- **`~/Desktop/StoneTweaks-retired-2026-07-24`** — 73 files. `StoneTweaksDB` was deliberately left
  in WTF, so rollback is just moving this folder back and re-enabling.

Both were identity-scanned and are clean.

---

## ⚠ Standing hazards

- **The dev symlinks and a WoWup install target the SAME folder names.** If an install QA is ever
  re-run on this machine, move the symlinks aside first and restore after — **and uninstall in
  WoWup BEFORE restoring them**, because WoWup's Remove deletes the folder it manages and could
  follow a symlink into live source.
- **All four addons point at their normal repos on BOTH the retail and PTR clients**, so an edit is
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
