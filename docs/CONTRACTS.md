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
- The widget toolkit is `LibGloomSkin-1.0` (Skin.lua is the lib body; `GloomsHub.UI` is the
  Hub-side alias) — formalized Phase C, surface pinned in §4.
> **GB (Phase C) and GA (Phase D) both consume these — the duplicated toolkits are GONE**
> (2026-07-24): each tool's local copy is deleted and its `.COLOR` aliases the lib's table.
> Deliberate exception, both tools: `GB.FONT`/`GA.FONT` still point at each tool's OWN font
> FILES — GB's bar text rasterizes per (path, size) so a swap would cold-start it; GA's users
> have GA paths STORED in their configs (cfg.text.font via the font picker). The files are
> byte-identical to the Hub's; config-UI chrome uses the lib FONT everywhere.

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
- Reserved tab ids: `auras` (order 10, live Phase D), `bars` (order 20, live Phase C),
  `overlays` (Phase E), `media` (order 90).
- **Container content size — PINNED (Phase D, 2026-07-24): at least 860 wide × 626 high.**
  Tabs may lay out against these as deterministic minimums (GA's centered 620-wide column
  does; GB's panes stretch). The shell (Hub-owned `SHELL_W/H`, currently 860×740) may GROW
  the area, but never shrink it below this without updating every tab in the same session.
- The container fires normal OnShow/OnHide as the tab gains/loses visibility (window
  open/close AND tab switches) — tools may hook these for show/hide side effects (GB ends
  move mode there; GA toggles its editor preview + closes its docked drawers).

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

## 4. LibGloomSkin-1.0 (the shared toolkit) — **PINNED (Phase C, 2026-07-24)**
Registered via LibStub: `local Skin = LibStub("LibGloomSkin-1.0")`. GloomsHub is the canonical
shipper — its `Skin.lua` IS the lib body (embedding a copy in each tool via `.pkgmeta`
externals is Phase G work). `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are Hub-side aliases of the
same tables. Consumers: **GB since Phase C, GA since Phase D**; Overlays swaps in E.

**Exported surface (MAJOR `"LibGloomSkin-1.0"`, MINOR 2) — the whole API; nothing else is public:**
- `Skin.COLOR` — `purple · heroic · green · red · orange` (each `{r,g,b,hex}`), `dark`, `rim`
  (both `{r,g,b,a}`), `text`, `mute` (`{r,g,b}`). The §1 literals.
- `Skin.FONT` — `title · head · body · bodyM · label` → font files under
  `Interface\AddOns\GloomsHub\Media\fonts\` (pre-warmed paths; see the warm-list contract).
- `Skin.MEDIA` — `"Interface\AddOns\GloomsHub\Media\"` (the permanent Hub path — locked).
- `Skin.UI` — the stateless widget factory:
  - `UI.CARET` (caret art path) · `UI.CARET_DOWN` (rotation radians for "open")
  - `UI.setFont(fs, path, size, flags?)` — SetFont with stock-font fallback
  - `UI.newText(parent, fontPath, size, color?, justify?)` → FontString
  - `UI.addEdges(frame, color, thick?)` — four 1px edge textures (squared border); returns a
    handle with `.top/.bottom/.left/.right` + `:SetColor(color, alpha?)` (MINOR 2 — GA's
    richer variant; ignoring the return stays fine)
  - `UI.skinPlate(frame)` → the flat dark base Texture
  - `UI.hLine(parent)` → 1px rim Texture (caller anchors; SetWidth(1)+anchors for vertical)
  - `UI.flatButton(parent, w, h, color, label?, textSize?)` → Button with `.text`, `:SetActive(on)`,
    `:SetBase(alpha)` — ★ purple/heroic when off, ORANGE when active, for EVERY flatButton
  - `UI.makeToggle(parent, get, set)` → 40×20 sliding switch, `:refresh()`
  - `UI.flatEditBox(parent, w, h)` → EditBox (faint purple fill, brighter on focus)
  - `UI.sliderRow(parent, yTop, label, min, max, step, get, set, fmt?, sub?)` →
    `{ refresh, setEnabled, SetShown }` (44px row; ~15px taller with `sub`)
  - `UI.colorSwatch(parent, get, set, withAlpha?)` → `{ swatch, refresh }` — get/set use
    `{r,g,b[,a]}` ARRAYS (ColorPickerFrame flow)
  - `UI.dirRow(parent, yTop, label, get, set)` → `{ refresh, setEnabled }` — "up"|"down"|"left"|"right"
  - `UI.makeScrollbar(parent, scrollFrame, place)` → thin orange-thumb bar with `:Sync()`
  - `UI.attachTip(frame, title, body)` — the family hover tooltip (HookScript, coexists)
  - `UI.WarmFonts(extraPairs?)` — **the Hub calls this, once, at PLAYER_ENTERING_WORLD**
    (Media.lua's RegisterAll); draws the base list + everything registered + the arg
  - `UI.RegisterWarmPairs({ {fontPath, size}, … })` — **how a TOOL warms its pairs**: call at
    file load; pairs queue and warm with the Hub's PEW batch (called after the batch — e.g.
    load-on-demand — it warms immediately). Each (path, size) draws at most once per session.
- **NOT exported (deliberate):** `makeSection` — each tab's accordion closes over its own
  scroll/relayout/one-open state, so the Media tab and the Bars tab each keep a local copy of
  the small pattern. Revisit at Phase D if GA shows a clean shared shape; adding it then is a
  MINOR bump, not a break.
- **Warm-list contract (QA-proven Phase B):** WoW draws a cold (font file, size) pair BLANK the
  first time it's drawn each client session (a /reload heals it; the next cold start re-breaks
  it). The Hub's base list covers the shell + Media tab (`title 21 · head 16 · body
  10.5/11/12/13 · bodyM 11/12/13`) + each catalog font at 11/13/14 (picker sizes). **Every
  (font, size) pair ANY suite tab draws beyond that must go through `RegisterWarmPairs`** —
  when a tool migrates (D/E), enumerate its sizes (`grep -oE 'FONT\.\w+, [0-9.]+' Config.lua |
  sort -u`) and register the ones the base list misses. GB registers: `title 17/18 · head
  12/13 · body 9.5/10/12.5 · label 10/10.5/11` (Config.lua, right after the toolkit aliases).
  GA registers: `title 13/16/17/18/20 · head 12/13 · label 11/12` (same spot in its Config.lua;
  pairs dedupe across addons, so overlap with GB's list is free).
- **Versioning:** LibStub newest-wins. Additive changes bump MINOR here + in `Skin.lua`
  (`local MAJOR, MINOR`) in the same session; breaking changes need a new MAJOR ("-2.0") and
  The owner's sign-off.

## 5. Consumers to keep in lockstep
- **GloomsBars** — ✅ migrated (Phase C, 2026-07-24): consumes LibGloomSkin, mounts the Bars
  tab, `/gb` + minimap button route to `GloomsHub:ToggleWindow("bars")`, hard-depends on the
  Hub. (Bar ENGINE keeps `GB.FONT` on GB's own files — see the §1 note.)
- **GloomsAuras** — ✅ migrated (Phase D, 2026-07-24): consumes LibGloomSkin, mounts the Auras
  tab (centered 620 column), `/ga` → `GloomsHub:ToggleWindow("auras")`, `CatStoneTweaks` →
  `GloomsHub:ListMedia` (relabelled "Suite Graphics"), hard-depends on the Hub. (`GA.FONT`
  stays on GA's own files — user configs store those paths; see the §1 note pattern.)
- **Gloom's Overlays** — 🔄 half-migrated (Phase E gate A, 2026-07-24): repo `~/GloomsOverlays`,
  hard-deps the Hub, resolver call site + editor label swapped to `GloomsHub:ResolveAssetPath`
  (**the suite's last StoneTweaks consumer — gone**), slash is `/go` (`/vibe` retired).
  **Still owed by gate B:** consume LibGloomSkin (it still ships the old native
  `BackdropTemplate` chrome and its own `MakeButton`/`MakeSlider`/`MakeCheck` locals), register
  the `overlays` tab (id reserved §2, order 30), dock the asset browser, and register its warm
  pairs §4. Note it keeps SavedVariables globals `VibeOverlayDB`/`VibeOverlayDBChar` on purpose.
