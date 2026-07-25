# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases A–D are **DONE and QA'd**. **Phase E is HALF DONE:
gate A (rename + data migration) is built and QA'd; gate B (mount the Overlays tab + full
reskin) is next and is the whole remaining job.** This file is a COLD-START briefing — a
session that never saw the earlier conversations should be able to execute gate B from this
file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — phase ledger + locked decisions + the polish backlog.
   **Update it at the end of any session that moves the suite.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases. For E read §5.E, §4.4, §0.
4. [CONTRACTS.md](CONTRACTS.md) — §2 tab API + the PINNED container size (860×626 min),
   §3 resolver/media API, §4 the LibGloomSkin surface (MINOR 2).

---

## What gate A already did (do NOT redo any of this)
Repo `~/GloomsOverlays` (`master`, commits `3d860f2` + `a96d068`), symlinked into AddOns as
`GloomsOverlays`. The old raw `VibeOverlay/` folder was **moved, not deleted**, to
`~/Desktop/VibeOverlay-retired-2026-07-24` (that's the rollback; safe to delete once gate B
passes). Three renamed files: `GloomsOverlays.lua` (371), `_Editor.lua` (1036),
`_Preview.lua` (563). TOC is `120007` + `## Dependencies: GloomsHub`.

- **Resolver swapped** — `GloomsOverlays.lua:155` now calls `GloomsHub:ResolveAssetPath(t)`
  (local is `mediaPath`). **This was the suite's LAST StoneTweaks consumer. Phase F is
  unblocked.** Editor texture label says "Suite media name".
- **Slash is `/go`; `/vibe` is retired outright** (the owner chose the clean break over an alias,
  2026-07-24 — the old QA gate's "`/vibe` still works" step is void). Subcommands
  `overlays`/`o`, `preview`/`p`, `list`, `debug`, `reload` all kept, now under `/go`.
- **Logo:** `Media/ui/logo.png` — the owner's GO mark (purple/maroon G, orange O), 179×247.
- QA'd by the owner: clean BugSack, addon list correct, overlays render identically, `/go list`
  correct, **Goldset renders on Gloomthorn**, `/go overlays` + `/go preview` open, `/vibe` dead.

### ★ The SavedVariables trap — ALREADY HANDLED. Do not "tidy" it.
`VibeOverlayDB` and `VibeOverlayDBChar` are **deliberately unchanged** and must stay that way.
WoW keys SavedVariables off the addon FOLDER name, so all **23** save files were copied
`VibeOverlay.lua` → `GloomsOverlays.lua` in place (1 account-level ~35 KB + **22 characters**),
byte-verified, originals left untouched as rollback. Keeping the globals is exactly what lets
those copies load with zero Lua migration.

The character files are **not** boilerplate — they store which profile each character is on,
and **12 ride non-Default profiles**: `Goldset` (Gloomthorn, Gloomwraith) and `Empty` (Gloomfury,
Gloomwick, Gloomvale, Gloomrift, Peiplfer, Gloombuck, Gloomtalon, Gloomstorm, Gloombound,
Gloomriven). Renaming the globals silently resets all of that. If they must ever be renamed it
needs a real migration shim. Recorded in the Overlays TOC and its CLAUDE.md too.

---

## GATE B — the work (this is the largest net-new UI chunk in the whole suite)

Locked: **reskin in one go, no interim native-looking shipping state.** Everything below lands
in one session, then the owner QAs once.

### 1. Mount the tab
`GloomsHub:RegisterTab{ id="overlays", title="OVERLAYS", order=30, build=function(container) … end }`
— id is reserved (CONTRACTS §2). Container is **≥860×626 (PINNED)** and fires OnShow/OnHide on
tab visibility. Reference implementations: **GB `Config.lua`** = simple mount + in-tab footer
row; **GA `Config.lua`** = centered column + docked drawers parented to the container +
OnShow/OnHide side effects. GA is the closer model here (drawers).

Replace the two floating windows: `GloomsOverlaysManager` (400×520) and `GloomsOverlaysEditor`
(460×560) both become panes inside the one tab. Drop their `SetMovable`/drag/resize-grip/
`UIPanelCloseButton`/`tinsert(UISpecialFrames, …)` — the shell owns window chrome and Escape.

> ⚠ **Layout math:** 400 + 460 = 860 = exactly the pinned content width, with zero gutter.
> Rebalance rather than porting those numbers literally.

### 2. Rebuild the UI in LibGloomSkin (CONTRACTS §4)
`local Skin = LibStub("LibGloomSkin-1.0")`. Delete the file-local `MakeLabel` / `MakeEditBox` /
`MakeButton` / `MakeCheck` / `SectionLabel` / `MakeSlider` helpers at the top of `_Editor.lua` —
those ARE the native chrome. Straight swaps:

| Existing (native) | LibGloomSkin |
|---|---|
| `MakeButton` → `UIPanelButtonTemplate` | `UI.flatButton` (★ orange when active, purple when not) |
| `MakeCheck` → `UICheckButtonTemplate` | `UI.makeToggle` (sliding switch) |
| `MakeEditBox` → `InputBoxTemplate` | `UI.flatEditBox` |
| `MakeSlider` → `OptionsSliderTemplate` | `UI.sliderRow` |
| tint swatch + `ColorPickerFrame` | `UI.colorSwatch` (get/set take `{r,g,b}` ARRAYS) |
| `UIPanelScrollFrameTemplate` bars | `UI.makeScrollbar` |
| `SetBackdrop` dialog frames | `UI.skinPlate` + `UI.addEdges` |
| `MakeLabel` / `SectionLabel` | `UI.newText` / `UI.setFont` |
| — | `UI.attachTip` for hover help |

**Inventory to rebuild** (all live-apply via `LiveApply(field,val)` / `LiveApplyMulti(tbl)`,
which write to `profile.overlays[currentEditIndex]` then call `GloomsOverlays_ApplyAll()`):

- **Manager:** profile selector + New/Copy/Rename/Delete; `+ New Overlay`; scrolling row list
  (enabled toggle · name · Edit · Dupe · Delete).
- **Editor** (currently a 1080px-tall scroll child): Name · Texture · Size W/H · Position X/Y ·
  Nudge (increment + 4 arrows) · Rotation slider −360…360 with ticks + Reset · Flip H/V ·
  Spin speed + CW/CCW · Alpha 0–100 · Tint (swatch, picker, reset, player/target class-color) ·
  Blend mode (BLEND/ADD/MOD) · Strata (7) · Visibility (5 conditions) · Save & Apply + status.

> ⚠ **Two gaps where LibGloomSkin has no equivalent — decide with the owner:**
> 1. **Profile dropdown** (`UIDropDownMenuTemplate`). §4 exports no dropdown. The family's
>    "pick from a list" pattern is GA's **docked drawer**, not a dropdown.
> 2. **`StaticPopupDialogs`** for profile New/Copy/Rename name entry — native popups. Needs an
>    inline Gloom-styled row or a small drawer instead.
>
> If either becomes a genuinely reusable widget, add it to the lib and **bump MINOR to 3 in
> both `Skin.lua` and CONTRACTS §4 in the same session.**

### 3. Asset browser → docked drawer (**decided with the owner 2026-07-24**)
`_Preview.lua`'s 780×560 window becomes a drawer over the tab (GA's `DockRight` pattern;
parent it to the container so it hides with the tab). Contents: input + Go · status line ·
300×300 preview square · sprite controls (cols/rows/fps/frames + Animate/Stop) · `+ Save as
New Overlay` · `★ Add to Favorites` · favorites list (scroll, per-row Load/Del, Clear all).
Favorites live in `VibeOverlayDB.favorites`. It should open from the editor's **Texture** field
and return to the editor on pick.

**Also in `_Preview.lua`:** the `PLAYER_LOGIN` block at ~line 542 wraps
`SlashCmdList["GLOOMSOVERLAYS"]` to add the `preview`/`overlays` branches and delegates the rest
to the original router in `GloomsOverlays.lua` (~line 328). Both must end up routing to
`GloomsHub:ToggleWindow("overlays")` / `FocusTab`. `list`, `debug`, `reload` stay chat-only.

### 4. Warm pairs (do not skip — this is the cold-start blank-text bug)
WoW draws a cold `(font file, size)` pair BLANK the first time each client session. After the UI
is built, enumerate its pairs and register the ones the Hub's base list misses:
`grep -oE 'FONT\.\w+, [0-9.]+' GloomsOverlays_*.lua | sort -u` → `UI.RegisterWarmPairs{…}` at
file load, right after the toolkit aliases (GB and GA both do this; pairs dedupe for free).
Base list + GB's + GA's are in CONTRACTS §4.

### 5. Logo placement — OPEN, ask the owner
`Media/ui/logo.png` exists but is deliberately unplaced. **Do not default to a splash/landing
page** — the polish backlog already records that GA's big-logo landing "doesn't really make
sense in the context of the suite" (the owner, Phase D QA). A small header mark is likelier right.

---

### ★ QA GATE B (the owner runs; ONE step at a time; verify before claiming)
Lua-only edits → `/reload` is enough, **except** the cold-start font check, which needs a real
restart.
1. `/reload`. BugSack clean.
2. `/go` → Suite window on **OVERLAYS**; tabs read **AURAS · BARS · OVERLAYS · MEDIA**;
   `/gloom`, `/ga`, `/gb` unchanged.
3. The Overlays tab is FULLY Gloom-styled — no native Blizzard chrome anywhere, no floating
   manager/editor/preview windows left.
4. Manager lists the overlays; enable/Edit/Dupe/Delete work; profile switch/new/copy/rename/
   delete work.
5. Editing (name, texture, size, position, nudge, rotation, flip, spin, alpha, tint, class
   colors, blend, strata, conditions) applies **live** to the on-screen overlay.
6. Asset browser opens as a drawer from the Texture field; Go/preview/animate work; favorites
   Load/Del/Clear work; `+ Save as New Overlay` lands in the manager and opens the editor.
7. `/go list` + `/go debug` still print in chat.
8. **FULL CLIENT RESTART** → no blank text anywhere in the Overlays tab (warm-list proof).
9. Overlays still render on a non-Default-profile character (Gloomthorn / `Goldset`).
10. `/st` untouched; StoneTweaks still installed (it retires in Phase F, not now).

**If it passes:** mark Phase E DONE in SUITE-STATE, update CONTRACTS §5's Overlays row to ✅
migrated, and rewrite this file as the **Phase F briefing** (retire StoneTweaks
non-destructively: disable/remove the folder, verify fonts/textures/graphics/overlays still work
off the Hub, compat shim goes live — SUITE-PLAN §5.F; then G = packaging/release). The owner can
also delete `~/Desktop/VibeOverlay-retired-2026-07-24` at that point.

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
- New files/assets → FULL CLIENT RESTART. Lua-only edits → `/reload`.
- StoneTweaks stays installed until Phase F. Its login "skipped — already registered" lines are
  the known artifact — not a bug. Overlays no longer depends on it either way.
- The addon version shows literally as `@project-version@` until packaging in Phase G.
- **Polish backlog lives in SUITE-STATE** (Auras landing page; Overlays logo placement).
  Don't start polish mid-phase; collect and batch it.
- The suite has ONE minimap launcher (the Hub's GS button) — do not add one to Overlays.
- Locked decisions (full list in SUITE-STATE): hard dependency, no fallback windows; Build Barn
  is OUT; never "v1"/"later phase" framing; GUI over slash.
- **macOS `sed` has no `\b`.** A rename pass in gate A silently skipped its guard because of it
  and nearly renamed the SavedVariables globals. Verify identifier renames with a token count
  against the originals, and `luac -p` every touched file.
