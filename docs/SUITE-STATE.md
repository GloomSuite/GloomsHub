# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-24 (session that scaffolded GloomsHub).

## Phase status

| Phase | What | Status |
|---|---|---|
| — | Scaffold GloomsHub repo + symlink + docs (home of record) | **DONE (not QA'd — no code yet)** |
| **A** | Stand up GloomsHub, media-only (registration + resolver + ST→Hub copy-migration + compat shim + asset folders). Touch nothing else. | **NOT STARTED** ← next |
| **B** | Empty tabbed shell + Media tab. Add `/gloom`. Old windows still work. | not started |
| **C** | Migrate Gloom's Bars as the proof (Bars tab, `/gb` reroute, toolkit → LibGloomSkin). | not started |
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | not started |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | not started |
| **F** | Retire StoneTweaks (delete last, non-destructively). | not started |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, embed LibGloomSkin, WoWup. | not started |

## Locked decisions (do not reopen — see SUITE-PLAN §"Decisions locked")
- Shared base = **GloomsHub** (permanent asset path `Interface\AddOns\GloomsHub\…`).
- StoneTweaks fully retired; media half absorbed into the Hub as the **Media tab**. No standalone media addon.
- VibeOverlay → **Gloom's Overlays**, reskinned in one go. `Vibe` name dropped.
- Four separate addons + one shared base (NOT a mega-addon). Hub ships as its own release; GB/GA/Overlays hard-depend on it.
- **Gloom's Build Barn is OUT of the suite** (data-fed cron pipeline, not a tab tool). Do not fold it in.

## What's physically in place right now
- `~/GloomsHub` git repo, symlinked into AddOns as `GloomsHub` (matches GB/GA convention).
- `GloomsHub.toc` (scaffold, no Lua files yet), `CLAUDE.md`, `docs/{SUITE-PLAN,SUITE-STATE,CONTRACTS,HANDOFF}.md`.
- GB & GA `CLAUDE.md` carry a "part of the Gloom Suite → GloomsHub" pointer.
- **No Lua, no assets, no runtime behavior yet.** Installing GloomsHub today does nothing in-game.

## Open (non-blocking) questions — see SUITE-PLAN §6
Overlays slash name; shared-footer contents; compat-shim lifetime; final LibGloomSkin public surface; stray `BoordensStreet.otf` fate.

## How to keep this honest
Any session that edits GB/GA/Overlays/Hub **for suite reasons** updates the relevant phase row
here before finishing. A phase is "DONE" only when its SUITE-PLAN QA gate has been met by the owner;
mark "in progress" until then.
