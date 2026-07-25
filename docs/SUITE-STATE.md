# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-24 (later session: **Phase C code BUILT — awaiting the owner's QA gate**; also landed the Gloom Suite logo).

## Phase status

| Phase | What | Status |
|---|---|---|
| — | Scaffold GloomsHub repo + symlink + docs (home of record) | **DONE (not QA'd — no code yet)** |
| **A** | Stand up GloomsHub, media-only (registration + resolver + ST→Hub copy-migration + compat shim + asset folders). Touch nothing else. | **DONE — QA'd by the owner 2026-07-24** (clean BugSack; DrukMedium serves from the Hub; catalog 1 font / 6 textures / 36 graphics, `migratedFromST = true`; Overlays unaffected). Known transition artifact: ST prints "skipped — already registered" lines at login because the Hub (loads first) now wins the LSM names — harmless, ST's own code, gone at Phase F. |
| **B** | Empty tabbed shell + Media tab. Add `/gloom`. Old windows still work. | **DONE — QA'd by the owner 2026-07-24** (window/toggle/Escape/drag; catalog 1/6/36 with previews; accordion + orange scrollbar; add/remove incl. `.otf` rejection; old windows untouched; cold-start re-verified). Two findings baked in: (1) **cold-start blank-text quirk** — WoW draws a cold (font file, size) pair blank the first time each session (a /reload heals, next cold start re-breaks); fixed by Skin.lua's `UI.WarmFonts` login pre-warmer — EXTEND its pair list whenever new UI font sizes appear (Phase C!). (2) overlapping family windows interleave (same strata, pre-existing GB/GA quirk) — accepted by the owner; self-resolves as tools mount tabs (C–E). |
| **C** | Migrate Gloom's Bars as the proof (Bars tab, `/gb` reroute, toolkit → LibGloomSkin). | **IN PROGRESS — code built 2026-07-24, QA gate partially run** ← first pass looked good except the launcher gap; finish the gate (HANDOFF.md). Built: `LibGloomSkin-1.0` formalized (surface pinned CONTRACTS §4, incl. `RegisterWarmPairs`); GB hard-depends on the Hub, local toolkit + standalone window DELETED, whole editor mounts as the Bars tab (own footer row inside the tab), `/gb` → `ToggleWindow("bars")`, warm pairs registered. **Launcher consolidation (the owner's call during QA):** the Hub grew the ONE suite minimap button (GS icon, LibDBIcon, `/gloom` semantics); GB's minimap button DELETED (TOC + `.pkgmeta` externals dropped); GA's retires at Phase D. GB's bar-ENGINE fonts deliberately stay on GB paths (CONTRACTS §1 note). Needs a FULL CLIENT RESTART (new files in both addons). |
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | not started |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | not started |
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
- **`~/GloomsBars` (Phase C, built not QA'd):** `## Dependencies: GloomsHub`; local toolkit
  copy + `BuildPanel`/`C:Toggle` + `GloomsBarsConfig` window DELETED; Config.lua consumes
  LibGloomSkin and registers the **Bars** tab (build(container), own footer row in-tab);
  `GB.COLOR` aliases the lib; `/gb` config branch → `GloomsHub:ToggleWindow("bars")`;
  `/gb` diagnostics untouched; bar engine untouched. GB's `MinimapButton.lua` DELETED
  (+ TOC lib lines + `.pkgmeta` LDB/LibDBIcon externals) — the Hub's GS button is the
  suite's one launcher.
- **Live on the owner's account:** `GloomsHubDB` = 1 font / 6 textures / 36 graphics,
  `migratedFromST = true`, plus `lastTab`; Hub wins the LSM names (ST prints skip lines);
  compat shim dormant. GA/VibeOverlay/StoneTweaks still completely untouched.
- GB & GA `CLAUDE.md` carry a "part of the Gloom Suite → GloomsHub" pointer.

## Open (non-blocking) questions — see SUITE-PLAN §6
Overlays slash name; shared-footer contents; compat-shim lifetime; stray `BoordensStreet.otf`
fate. (~~LibGloomSkin public surface~~ — CLOSED Phase C, pinned in CONTRACTS §4. ~~Hub logo~~
— CLOSED, the owner delivered the GS monogram 2026-07-24.)

## How to keep this honest
Any session that edits GB/GA/Overlays/Hub **for suite reasons** updates the relevant phase row
here before finishing. A phase is "DONE" only when its SUITE-PLAN QA gate has been met by the owner;
mark "in progress" until then.
