# Gloom Suite — shared runtime CONTRACTS

> **Home of record for every fact that more than one addon depends on.** If you change
> anything here, change it HERE and update every consumer in the SAME session. Consumers
> (GB/GA/Overlays) must never keep their own divergent copy — that is exactly the drift this
> file exists to prevent. Nothing below is built yet; these are the agreed shapes for the
> phased build (see [SUITE-PLAN.md](SUITE-PLAN.md)).

## 1. Design tokens (the ONE copy)
Today GB and GA each hold a byte-identical `COLOR`/`FONT` table — that duplication is the drift
we are removing. Post-migration these live ONLY in GloomsHub (`GloomsHub.COLOR/.FONT`) and are
consumed via `LibGloomSkin`. Values are the established family language:
- `COLOR.purple = #936bff` (accents, selection, unselected buttons)
- `COLOR.orange` (active/selected buttons, caret) — the warm `#ff7729`-family accent
- Near-black navy plate `#12131F` family + rim; warm orange bottom-glow gradient on windows.
- Fonts: Khand SemiBold/Medium (titles/headers), GeneralSans Regular/Medium/Semibold (body/labels).
**Lifted into `GloomsHub.COLOR/.FONT` (Skin.lua) in Phase B, 2026-07-24 — verbatim from GB
`Core.lua` (byte-identical to GA's). These are now the authoritative literals:**
- `purple #936bff` · `heroic #8031ff` · `green #20ba56` · `red #c41e3a` · `orange #ff7729`
- `dark = rgb(18,19,31)/255` (pre-compensated so `#060714` lands on screen) · `rim = white @ 10%`
- `text = (0.90, 0.92, 0.96)` · `mute = (0.55, 0.57, 0.63)` — promoted from GB `Config.lua`
  locals (TEXT/MUTE) to proper tokens.
- `FONT`: `title` Khand-SemiBold · `head` Khand-Medium · `body` GeneralSans-Regular ·
  `bodyM` GeneralSans-Medium · `label` GeneralSans-Semibold — files under
  `Interface\AddOns\GloomsHub\Media\fonts\`.
- The widget toolkit lives in `GloomsHub.UI` (Skin.lua) — becomes `LibGloomSkin-1.0` in Phase C.
> GB and GA still carry their own token/toolkit copies until Phases C/D swap them to consume
> these. Until then, a change here must be mirrored there (or better: not made until C/D).

## 2. The tabbed-shell API (GloomsHub owns)
```lua
GloomsHub:RegisterTab{
  id      = "bars",           -- stable key; the slash focuses by this
  title   = "BARS",          -- Khand uppercase shown on the tab
  order   = 20,              -- sort weight; Media = 90, tools 10..80
  icon    = "…logo.png",     -- optional
  build   = function(container) … end,  -- called ONCE, lazily, on first show; parent to `container`
  refresh = function() … end,           -- optional; called each focus (maps to a tool's C:Refresh)
}

GloomsHub:Open(id)      -- show the Suite window + focus tab `id`
GloomsHub:FocusTab(id)  -- switch tabs within an open window
GloomsHub:ToggleWindow(id?)  -- slash semantics (added Phase B): open→close if on `id`
                             -- (or no id), switch if on another tab, else Open(id)
```
- `build` runs lazily on first show (never at login). A tool whose addon isn't loaded simply
  doesn't register; the shell shows present tools' tabs + the always-present Media tab.
- A tool's former window-local footer controls move INTO its tab container, not the shared footer.
- Reserved tab ids: `auras`, `bars`, `overlays`, `media`.

## 3. Media / resolver (GloomsHub owns; salvaged from StoneTweaks)
```lua
GloomsHub:ResolveAssetPath(name)   -- name → "Interface\AddOns\GloomsHub\{Textures|Graphics}\<file>", or nil
GloomsHub:ListMedia(kind)          -- kind "graphics"|"textures" → { {name=, tex=path}, … }  (GA uses this)
GloomsHub.Media:AddFont(name,file) / :RemoveFont(i) / :AddTexture(…) / :AddGraphic(…) / …
```
- Fonts register into LSM as `font`; textures as `statusbar`; graphics are NOT in LSM (name→path only).
- **Back-compat shim (transition):** GloomsHub defines global `StoneTweaks_ResolveAssetPath =
  function(n) return GloomsHub:ResolveAssetPath(n) end` **only if** ST's real one isn't loaded,
  so VibeOverlay/Overlays keeps resolving graphics the moment the Hub is installed.
- SavedVariable `GloomsHubDB.fonts/.textures/.graphics` — same `{name,file}` shape as `StoneTweaksDB`.

## 4. LibGloomSkin-1.0 (the shared toolkit, embedded everywhere)
The stateless widget factory + tokens, exposed as a LibStub lib so any tool can build widgets
even before the Hub's frames exist. Public surface (finalize during Phase C; list here as lifted):
`setFont`, `newText`, `addEdges`/`skinPlate`, `hLine`, `flatButton` (purple off / orange on),
`makeToggle` (sliding switch), `makeScrollbar`, `makeSection` (accordion), tooltip helper.
- **`UI.WarmFonts` is part of the toolkit contract (added Phase B, QA-proven):** WoW draws a
  cold (font file, size) pair BLANK the first time it's drawn each client session (a /reload
  heals it; the next cold start re-breaks it). The Hub pre-warms every pair its UI uses at
  `PLAYER_ENTERING_WORLD`. **Every (font, size) pair ANY suite tab uses must be in the warm
  list** — when a tool migrates (C/D/E), enumerate its sizes and warm them.
> When Phase C extracts the toolkit, pin the exact exported names + signatures HERE so GB/GA/
> Overlays all call the identical API.

## 5. Consumers to keep in lockstep
- **GloomsBars** — tokens + toolkit (→ LibGloomSkin), `/gb` config reroute, Bars tab.
- **GloomsAuras** — tokens + toolkit, `/ga`, Auras tab, `CatStoneTweaks` → `GloomsHub:ListMedia`.
- **Gloom's Overlays** — `ResolveAssetPath` call site + label, `/go`, Overlays tab, full reskin.
