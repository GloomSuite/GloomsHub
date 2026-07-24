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
> The authoritative values are whatever GB `Core.lua`'s `GB.COLOR`/`GB.FONT` hold at migration
> time; Phase C lifts them here verbatim. Record the final literals in this section when lifted.

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
> When Phase C extracts the toolkit, pin the exact exported names + signatures HERE so GB/GA/
> Overlays all call the identical API.

## 5. Consumers to keep in lockstep
- **GloomsBars** — tokens + toolkit (→ LibGloomSkin), `/gb` config reroute, Bars tab.
- **GloomsAuras** — tokens + toolkit, `/ga`, Auras tab, `CatStoneTweaks` → `GloomsHub:ListMedia`.
- **Gloom's Overlays** — `ResolveAssetPath` call site + label, `/go`, Overlays tab, full reskin.
