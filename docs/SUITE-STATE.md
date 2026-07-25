# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-24 (Phases C **and** D built + QA'd; **Phase E is IN PROGRESS — gate A
(rename + data migration) is QA'd, gate B (tab mount + reskin) is next**, briefing in HANDOFF.md).

## Phase status

| Phase | What | Status |
|---|---|---|
| — | Scaffold GloomsHub repo + symlink + docs (home of record) | **DONE (not QA'd — no code yet)** |
| **A** | Stand up GloomsHub, media-only (registration + resolver + ST→Hub copy-migration + compat shim + asset folders). Touch nothing else. | **DONE — QA'd by the owner 2026-07-24** (clean BugSack; DrukMedium serves from the Hub; catalog 1 font / 6 textures / 36 graphics, `migratedFromST = true`; Overlays unaffected). Known transition artifact: ST prints "skipped — already registered" lines at login because the Hub (loads first) now wins the LSM names — harmless, ST's own code, gone at Phase F. |
| **B** | Empty tabbed shell + Media tab. Add `/gloom`. Old windows still work. | **DONE — QA'd by the owner 2026-07-24** (window/toggle/Escape/drag; catalog 1/6/36 with previews; accordion + orange scrollbar; add/remove incl. `.otf` rejection; old windows untouched; cold-start re-verified). Two findings baked in: (1) **cold-start blank-text quirk** — WoW draws a cold (font file, size) pair blank the first time each session (a /reload heals, next cold start re-breaks); fixed by Skin.lua's `UI.WarmFonts` login pre-warmer — EXTEND its pair list whenever new UI font sizes appear (Phase C!). (2) overlapping family windows interleave (same strata, pre-existing GB/GA quirk) — accepted by the owner; self-resolves as tools mount tabs (C–E). |
| **C** | Migrate Gloom's Bars as the proof (Bars tab, `/gb` reroute, toolkit → LibGloomSkin). | **DONE — QA'd by the owner 2026-07-24** (gate passed; the one first-pass gap — no suite launcher — was filled same day and verified: the Hub owns the ONE GS minimap button, GB's is deleted). Shipped: `LibGloomSkin-1.0` (surface pinned CONTRACTS §4, incl. `RegisterWarmPairs`); GB hard-deps the Hub; local toolkit + standalone window DELETED; editor mounts as the Bars tab with its own in-tab footer row; `/gb` → `ToggleWindow("bars")` (diagnostics untouched). GB's bar-ENGINE fonts deliberately stay on GB paths (CONTRACTS §1 note). **The container-mount pattern is PROVEN.** |
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | **DONE — QA'd by the owner 2026-07-24** ("works as it did before"). Shipped: GA hard-deps the Hub; local toolkit copy + standalone window DELETED; options UI mounts as the **Auras** tab (centered 620-wide column; docked drawers parent to the container); `/ga` → `ToggleWindow("auras")`; `/ga minimap` drives the Hub's button; GA's minimap button DELETED; `CatStoneTweaks` → `GloomsHub:ListMedia` ("Suite Graphics" — GA reads NO StoneTweaks data anymore). Shell grew to 860×740 (content 860×626 PINNED, CONTRACTS §2); lib at MINOR 2. Noted for polish (below): the Auras landing page. |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | **IN PROGRESS — split into two QA gates** (the handoff's own "QA the migration FIRST" instruction, so a reskin bug can never be mistaken for data loss). **Gate A DONE — QA'd by the owner 2026-07-24**: clean BugSack; addon list shows "Gloom's Overlays", VibeOverlay gone; overlays render identically; `/go list` correct; **Goldset renders on Gloomthorn** (the per-character proof); `/go overlays` + `/go preview` work (still native chrome); `/vibe` retired. **Gate B NOT STARTED** ← next: mount the Overlays tab + full LibGloomSkin reskin + docked asset browser. |
| **F** | Retire StoneTweaks (delete last, non-destructively). | not started |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, embed LibGloomSkin, WoWup. | not started |

## Locked decisions (do not reopen — see SUITE-PLAN §"Decisions locked")
- Shared base = **GloomsHub** (permanent asset path `Interface\AddOns\GloomsHub\…`).
- StoneTweaks fully retired; media half absorbed into the Hub as the **Media tab**. No standalone media addon.
- VibeOverlay → **Gloom's Overlays**, reskinned in one go. `Vibe` name dropped.
- Four separate addons + one shared base (NOT a mega-addon). Hub ships as its own release; GB/GA/Overlays hard-depend on it.
- **HARD dependency on GloomsHub — NO standalone fallback (the owner, 2026-07-24).** Each tool
  deletes its own window; its config renders ONLY inside the Hub's tabbed shell. Installing a
  tool WITHOUT the Hub = its config has nowhere to render. This is the safer choice for keeping
  the experience identical everywhere (one window, one toolkit, zero drift). `## Dependencies:
  GloomsHub` makes WoWup + the in-game addon list flag the missing dep LOUDLY. Chosen over a
  graceful-fallback (own-window-if-no-Hub) precisely to avoid two window paths that could drift.
  Distribution is limited (friends/guild), so "someone installs one tool alone" is a known,
  acceptable, loudly-failing edge — not a silent break.
- **Gloom's Build Barn is OUT of the suite** (data-fed cron pipeline, not a tab tool). Do not fold it in.

## What's physically in place right now
- `~/GloomsHub` git repo, symlinked into AddOns as `GloomsHub` (matches GB/GA convention).
- `Core.lua` (namespace, `GloomsHubDB`, ST copy-migration, dormant compat shim, `/gh` probe),
  `Skin.lua` (**now the body of `LibGloomSkin-1.0`** — LibStub-registered, MINOR 1; tokens +
  toolkit + `WarmFonts`/`RegisterWarmPairs`; `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are aliases),
  `Shell.lua` (the Suite window: `RegisterTab/Open/FocusTab/ToggleWindow` + `/gloom`; title
  bar now carries the GS monogram), `Media.lua` (LSM registration, `ResolveAssetPath`,
  `ListMedia`, `Media:Add*/Remove*` API + the Media tab; catalog fonts warm at 11/13/14),
  `MinimapButton.lua` (the ONE suite launcher — GS icon, LibDBIcon + fallback, click =
  `/gloom` semantics, `GloomsHubDB.minimap`), `GloomsHub.toc` (Libs → Core → Skin → Shell →
  Media → MinimapButton), `CLAUDE.md`, the 4 docs.
- `Libs/` (gitignored): LibStub, CallbackHandler-1.0, LibSharedMedia-3.0 (from
  `~/GloomsAuras/Libs/`), LibDataBroker-1.1 + LibDBIcon-1.0 (from `~/GloomsBars/Libs/`).
- `Fonts/` (8 files), `Textures/` (13), `Graphics/` (45) — committed ST-salvaged assets.
- `Media/fonts/` (Khand ×2 + GeneralSans ×3, copied from GB) + `Media/ui/caret.png` +
  **`Media/ui/logo.png` + `Media/ui/minimap.png`** (the owner's Gloom Suite GS monogram,
  2026-07-24 — title-bar mark + TOC IconTexture; the old "no Hub logo" open item is CLOSED).
- **`~/GloomsBars` (Phase C, QA'd):** `## Dependencies: GloomsHub`; local toolkit copy +
  `BuildPanel`/`C:Toggle` + `GloomsBarsConfig` window DELETED; Config.lua consumes
  LibGloomSkin and registers the **Bars** tab (build(container), own footer row in-tab);
  `GB.COLOR` aliases the lib; `/gb` config branch → `GloomsHub:ToggleWindow("bars")`;
  `/gb` diagnostics untouched; bar engine untouched. GB's `MinimapButton.lua` DELETED
  (+ TOC lib lines + `.pkgmeta` LDB/LibDBIcon externals) — the Hub's GS button is the
  suite's one launcher.
- **`~/GloomsAuras` (Phase D, QA'd):** `## Dependencies: GloomsHub`; local toolkit
  copy + the `GloomsAurasConfig` window (chrome, panelPos, `C:Toggle`, `C:SavePanelPos`)
  DELETED; Config.lua consumes LibGloomSkin (incl. the MINOR-2 `addEdges`) and registers the
  **Auras** tab — a centered 620-wide column; docked drawers (`DockRight`) parent to the
  container so they hide with the tab; landing/editor/OnShow-OnHide behavior unchanged;
  `LIST_ROWS` 15→13 + `PANE_H` 528 for the 626px content area; "View All Auras" bottom-
  anchored. `CatStoneTweaks` → `CatSuiteMedia` via `GloomsHub:ListMedia` ("Suite Graphics").
  `GA.COLOR` aliases the lib; `/ga` config branch → `ToggleWindow("auras")`; `/ga minimap` →
  the Hub's button; GA's `MinimapButton.lua` DELETED (+ TOC lib lines + `.pkgmeta` externals).
  All `/ga` diagnostics untouched; Displays/CDM engines untouched.
- **`~/GloomsOverlays` (Phase E gate A, QA'd):** NEW git repo on `master`, symlinked into AddOns
  as `GloomsOverlays`; the old raw `VibeOverlay/` folder was **moved (not deleted)** to
  `~/Desktop/VibeOverlay-retired-2026-07-24`. Three renamed Lua files
  (`GloomsOverlays.lua` / `_Editor.lua` / `_Preview.lua`), all `Vibe`/`VIBEOVERLAY` identifiers
  rebranded; TOC `## Interface: 120007` + `## Dependencies: GloomsHub`; `Media/ui/logo.png`
  (the owner's GO mark, 2026-07-24). Resolver → `GloomsHub:ResolveAssetPath` — **this was the
  suite's LAST StoneTweaks dependency; Phase F can now retire ST.** Editor label says "Suite
  media name". Slash `/go` (`/vibe` retired outright — the owner chose the clean break over the
  alias; `overlays`/`preview`/`list`/`debug` subcommands kept). **UI is still the old native
  BackdropTemplate chrome — that is gate B's job.**
  ★ **`VibeOverlayDB` / `VibeOverlayDBChar` are DELIBERATELY unchanged** — see the trap note below.
- **The SavedVariables migration (gate A, done):** WoW keys SV off the addon FOLDER name, so
  all **23** save files were copied `VibeOverlay.lua` → `GloomsOverlays.lua` in place (1 account
  + **22 characters**), byte-verified, originals left as rollback. The character files are NOT
  boilerplate: **12 ride non-Default profiles** (`Goldset` ×2 — Gloomthorn, Gloomwraith;
  `Empty` ×10). Keeping the SV globals unchanged is what makes the copies load with zero Lua
  migration; renaming them later needs a real shim, not a find-and-replace (recorded in the
  Overlays TOC + CLAUDE.md).
- **Live on the owner's account:** `GloomsHubDB` = 1 font / 6 textures / 36 graphics,
  `migratedFromST = true`, plus `lastTab` + `minimap`; Hub wins the LSM names (ST prints skip
  lines); compat shim dormant. VibeOverlay/StoneTweaks still completely untouched.
- GB & GA `CLAUDE.md` carry a "part of the Gloom Suite → GloomsHub" pointer.

## Open (non-blocking) questions — see SUITE-PLAN §6
Shared-footer contents; compat-shim lifetime; stray `BoordensStreet.otf` fate; where the
Overlays GO logo belongs inside the tab (NOT a splash — see the polish backlog).
(~~LibGloomSkin public surface~~ — CLOSED Phase C, pinned in CONTRACTS §4. ~~Hub logo~~ —
CLOSED, the owner delivered the GS monogram 2026-07-24. ~~Overlays slash name~~ — CLOSED Phase E
gate A: **`/go`, and `/vibe` is retired outright**, the owner 2026-07-24.)

## Suite polish backlog (post-migration UI work, gathered during QA)
- **Auras tab landing page (the owner, Phase D QA 2026-07-24):** the old standalone window's
  splash/landing (big GA logo + "Add … Aura" buttons on every open) "doesn't really make
  sense in the context of the suite." Works as before for now — rethink after the
  migrations (e.g. open straight to the editor with a compact create row, logo retired or
  moved). GA-side change; coordinate the design with the family language here.

## How to keep this honest
Any session that edits GB/GA/Overlays/Hub **for suite reasons** updates the relevant phase row
here before finishing. A phase is "DONE" only when its SUITE-PLAN QA gate has been met by the owner;
mark "in progress" until then.
