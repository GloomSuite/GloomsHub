# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** GloomsHub is SCAFFOLDED (docs only, no code). **Next: build Phase A.**
This file is a COLD-START briefing — a session that never saw the planning conversation should be
able to execute Phase A from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — the phase ledger + all locked decisions. Source of truth
   for "where are we." **Update it when Phase A completes.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — full architecture + all 7 phases + rationale.
4. [CONTRACTS.md](CONTRACTS.md) — the shared runtime shapes (tokens, tab API, resolver, LibGloomSkin).

## What exists now
- `~/GloomsHub` git repo (2 commits+), symlinked into `…/Interface/AddOns/GloomsHub`. Remote
  intended: `github.com/HandofDevastation/GloomsHub` (not pushed yet).
- `GloomsHub.toc` (scaffold — no Lua files listed), `CLAUDE.md`, `.gitignore`, the 4 docs.
- GB & GA `CLAUDE.md` carry a "part of the Gloom Suite → GloomsHub" pointer.
- **No Lua, no `Media/`, no `Libs/`, no runtime behavior.** Installing GloomsHub today does nothing.

## Locked decisions (do NOT reopen — full list in SUITE-STATE.md)
Base = GloomsHub (permanent path `Interface\AddOns\GloomsHub\…`). **Hard dependency, no
fallback.** StoneTweaks retired, its media half absorbed here. VibeOverlay → Gloom's Overlays
(reskin). Four addons + one base, not a mega-addon. **Gloom's Build Barn is OUT** (cron/WCL
pipeline). Never use "v1"/"later phase" framing. GUI over slash for user controls.

---

## ▶▶ PHASE A — stand up GloomsHub, MEDIA ONLY. Touch nothing but GloomsHub.

**Goal:** GloomsHub registers the salvaged fonts/textures into LibSharedMedia and exposes the
graphic/texture resolver — so when StoneTweaks is eventually deleted (Phase F, much later),
nothing that depends on it breaks. **GB, GA, VibeOverlay, StoneTweaks are NOT edited in Phase A.**

### Build these files under `~/GloomsHub/`
1. **`Libs/`** — copy `LibStub`, `CallbackHandler-1.0`, `LibSharedMedia-3.0` from
   **`~/GloomsAuras/Libs/`** (present there; GB's Libs are gitignored/absent locally). Add them
   to the TOC to load FIRST. (`Libs/` is gitignored — that's expected; the packager refetches.)
2. **`Core.lua`** — namespace `_G.GloomsHub`, `GloomsHubDB` saved-var init, and the migration
   (below). Register events; do the media registration at `PLAYER_ENTERING_WORLD` (that's when
   ST does it — LSM is fully up by then).
3. **`Media.lua`** — the salvaged registration + resolver + public API (below).
4. **TOC** — list `Libs/*` then `Core.lua`, `Media.lua`. Add `## SavedVariables: GloomsHubDB`
   (already in the scaffold TOC).

### Salvage — port these VERBATIM from `…/AddOns/StoneTweaks/StoneTweaks.lua`
Exact source verified 2026-07-24:
- `GetLSM()` (ST lines ~53-63): `pcall(LibStub, "LibSharedMedia-3.0")`.
- `RegisterFont(entry)` → `lsm:Register("font", entry.name, FONT_PATH..entry.file)`.
- `RegisterTexture(entry)` → `lsm:Register("statusbar", entry.name, TEXTURE_PATH..entry.file)`.
- `RegisterAll()` (fired at `PLAYER_ENTERING_WORLD`) — loops `db.fonts`/`db.textures`, registers each.
- `StoneTweaks_ResolveAssetPath(name)` (ST lines 142-155) — searches `textures` then `graphics`,
  returns `TEXTURE_PATH..file` or `GRAPHIC_PATH..file`, else nil.
- **Public API** (rename under the Hub, keep validation incl. `.otf` rejection +
  `.ttf/.blp/.tga/.png` gates): `AddFont/RemoveFont/AddTexture/RemoveTexture/AddGraphic/RemoveGraphic`.

**Path constants change to the Hub's own folder:**
```
FONT_PATH    = "Interface\\AddOns\\GloomsHub\\Fonts\\"
TEXTURE_PATH = "Interface\\AddOns\\GloomsHub\\Textures\\"
GRAPHIC_PATH = "Interface\\AddOns\\GloomsHub\\Graphics\\"
```
Expose as `GloomsHub:ResolveAssetPath(name)`, `GloomsHub:ListMedia(kind)` (returns
`{ {name=, tex=path}, … }` — GA will use this later), `GloomsHub.Media:AddFont(…)` etc. See CONTRACTS §3.
**Do NOT port** any ElvUI code, the `[st:style:*]` tag engine, frame textures/backdrops, or glow
suppression — none of it comes across.

### Copy the asset folders into `~/GloomsHub/`
From `…/AddOns/StoneTweaks/`: `Fonts/` (8 files), `Textures/` (13), `Graphics/` (45). These are
bundled addon assets — commit them (they are NOT in `Libs/`, so not gitignored).
- **Stray file:** `Fonts/BoordensStreet.otf` — WoW can't load `.otf` and `AddFont` rejects it.
  Harmless to carry; optional to drop. (Minor — see SUITE-PLAN §6.)

### The migration (one-time, NON-DESTRUCTIVE) — the "don't lose DrukMedium" requirement
In `Core.lua` at `PLAYER_LOGIN`: if `GloomsHubDB.fonts` is empty AND `_G.StoneTweaksDB` exists,
**COPY** (deepcopy, never move) `StoneTweaksDB.fonts/.textures/.graphics` into `GloomsHubDB`,
then set `GloomsHubDB.migratedFromST = true` (runs once). COPY so ST's SV is untouched and
rollback = just re-enable ST.
- Copy **verbatim** — do not "clean" entries. The live DB contains a leftover `test-remove`
  graphic and entries like `whitesquare`/`simplering`; carry them all.
- ⚠ **Every `{name,file}` the DB references must have its file present in the copied folder**, or
  the resolver returns a live-but-dead path. During QA, spot-check that DB-referenced files
  (e.g. `DrukMedium.ttf`, `whitesquare.png`, `simplering.png`) actually exist in
  `GloomsHub/Fonts|Textures|Graphics`. If a referenced file is missing from ST's folders too,
  that's a pre-existing ST gap, not a migration bug — note it, don't invent the file.

### The compat shim (so VibeOverlay keeps resolving graphics)
In `Core.lua`, AFTER the Hub's resolver exists, define the global **only if** ST's real one
isn't already loaded:
```lua
if not _G.StoneTweaks_ResolveAssetPath then
  _G.StoneTweaks_ResolveAssetPath = function(n) return GloomsHub:ResolveAssetPath(n) end
end
```
During Phase A, ST is still installed → its real function wins → the shim is dormant. That's
fine; the shim matters later (Phase F) when ST is gone. VibeOverlay (`VibeOverlay.lua:155`) is
NOT edited in Phase A.

### ★ QA GATE for Phase A (the owner runs; ONE step at a time; verify before claiming)
Because new files/assets were added, this needs a **FULL CLIENT RESTART**, not `/reload`.
1. Restart WoW. No BugSack errors from GloomsHub on login.
2. GloomsHub registered the fonts into LSM — confirm via an LSM-aware picker (e.g. GA's or GB's
   font picker still lists "DrukMedium" — now it can come from EITHER ST or the Hub; both
   register it, which is fine).
3. `/dump GloomsHubDB.fonts` (or a small `/gh` probe if one is added) shows DrukMedium et al.
   copied in, and `GloomsHubDB.migratedFromST == true`.
4. **VibeOverlays still render their graphics** (they still resolve through ST's real function —
   nothing should have changed for them). Nothing removed, game fully working.

**If it passes:** update [SUITE-STATE.md](SUITE-STATE.md) Phase A → done, and this handoff → "Next: Phase B."

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **ask for BugSack text first** on any error.
- New files/assets → FULL CLIENT RESTART (not /reload).
- StoneTweaks stays installed until Phase F (it's the migration source; delete it LAST).
- The `~/GloomsAuras/Libs/` folder is the source for LibStub/CallbackHandler/LibSharedMedia-3.0.
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of ANY session that moves the suite.
- Cross-repo edits are fine (all under `~/`), but the Hub is the home of record — keep facts here.
