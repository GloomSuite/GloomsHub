# Gloom Suite — shared runtime CONTRACTS

> **Home of record for every fact that more than one addon depends on.** If you change
> anything here, change it HERE and update every consumer in the SAME session. Consumers
> (GB/GA/Overlays) must never keep their own divergent copy — that is exactly the drift this
> file exists to prevent. **Everything below is BUILT and QA'd** as of Phase E (2026-07-24) —
> §§1–4 describe live code, not proposals. Phase ledger: [SUITE-STATE.md](SUITE-STATE.md).

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
- **★ THE KIT (MINOR 11, 2026-09-21 — the redesign, BACKLOG 16).** A second palette and type set,
  read off the owner's Figma PRIMITIVES frame, for the light-grey window: `plate #d2d2d2` ·
  `ink #444444` (action buttons, labels) · `violet #6c2fe6` (persisting state) · `lilac #a881f8`
  (the tool's name in a wordmark) · `indigo #3b1684` (an open list, the picker's rim) · `amber
  #ffa04e` (destructive, the dial's mark, the highlighted list row) · `night #110628` (the picker
  and dialog plate) · `paper #ffffff` (inputs) · `chip #d9d9d9` · `dim` / `faint` (#3e3e3e at 50% /
  20%) · `black`. Fonts: `FONT.ui` Play Regular (11: buttons, inputs) · `FONT.uiB` Play Bold (12:
  labels, 14: section headers) · `FONT.mark` Michroma (wordmarks, the big Player/Target buttons).
  ⚠ **THE TRANSITION:** until every tab has migrated, the OLD tokens are re-pointed to read on the
  light plate — `text` and `mute` are dark, `rim` is black at 18%, `skinPlate` paints `plate`, and
  `flatButton` picks white or dark text by how strong its fill is. Every pre-kit widget still
  works; it just draws light. This goes away with the last migrated tab.
> **GB (Phase C) and GA (Phase D) both consume these — the duplicated toolkits are GONE**
> (2026-07-24): each tool's local copy is deleted and its `.COLOR` aliases the lib's table.
> Deliberate exception, both tools: `GB.FONT`/`GA.FONT` still point at each tool's OWN font
> FILES — GB's bar text rasterizes per (path, size) so a swap would cold-start it; GA's users
> have GA paths STORED in their configs (cfg.text.font via the font picker). The files are
> byte-identical to the Hub's; config-UI chrome uses the lib FONT everywhere.

## 2. The tabbed-shell API (GloomsHub owns)
```lua
GloomsHub:RegisterTab{
  id       = "bars",           -- stable key; the slash focuses by this
  title    = "BARS",          -- the tab button's label (uppercased by the kit)
  order    = 20,              -- fallback sort weight — the shell orders KNOWN ids itself (below)
  wordmark = "BARS",          -- MINOR 11: what the banner shows after "gloom"; defaults to `title`
  profile  = api,             -- MINOR 11: a UI.profileBlock-style api → the shell draws the tool's
                              --   PROFILE ROW in the window's footer (UI.profileRow); optional
  build    = function(container) … end,  -- called ONCE, lazily, on first show; parent to `container`
  refresh  = function() … end,           -- optional; called each focus (maps to a tool's C:Refresh)
}

GloomsHub:Open(id)      -- show the Suite window + focus tab `id`
GloomsHub:FocusTab(id)  -- switch tabs within an open window
GloomsHub:ToggleWindow(id?)  -- slash semantics (added Phase B): open→close if on `id`
                             -- (or no id), switch if on another tab, else Open(id)
```
- `build` runs lazily on first show (never at login). A tool whose addon isn't loaded simply
  doesn't register; the shell shows present tools' tabs + the always-present Media tab.
- A tool's former window-local footer controls move INTO its tab container, not the shared footer.
- Reserved tab ids: `auras`, `bars`, `unitframes`, `portraits`, `overlays`, `media`. **The strip's
  order is the MOCKS' and is fixed in the shell** (`TAB_ORDER`, 2026-09-21): Auras · Bars · Unit
  Frames · Portraits · Overlays · Media; a tab's own `order` only places an unknown id.
- **★ THE SHELL IS THE MOCKS' (2026-09-21, redesign stage 1): 1060 × 740, fixed**, the light plate,
  three bands — HEADER 54 (the "gloomSUITE" wordmark; the tab pills right-aligned with the X; the
  version line is the wordmark's hover-tip), BANNER 36 (a 250px violet block carrying
  "gloom<wordmark>", the rest dim), FOOTER 65 (a line, then the tool's profile row, drawn only for
  a tab that passed `profile`).
- **Container content size — PINNED:** a tab WITH a footer profile row gets **1060 × 585**; a tab
  WITHOUT one runs to the window's bottom and gets **1060 × 650**, so the pre-redesign pin of
  **860 × 626** (Phase D) still holds for every un-migrated tab. The shell may GROW either, never
  shrink one without updating its tabs in the same session.
- The container fires normal OnShow/OnHide as the tab gains/loses visibility (window
  open/close AND tab switches) — tools may hook these for show/hide side effects (GB ends
  move mode there; GA toggles its editor preview + closes its docked drawers).

## 3. Media / resolver (GloomsHub owns; salvaged from StoneTweaks)
```lua
GloomsHub:ResolveAssetPath(name)   -- name → "Interface\AddOns\GloomsHub\{Textures|Graphics}\<file>", or nil
GloomsHub:ListMedia(kind)          -- kind "graphics"|"textures" → { {name=, tex=path}, … }  (GA uses this)
GloomsHub.Media:AddFont(name,file) / :RemoveFont(i) / :AddTexture(…) / :AddGraphic(…) / …
GloomsHub.Media:AddSound(name, ref)  -- ref = FileDataID (number) OR a filename in GloomsHub\Sounds\
GloomsHub.Media:RemoveSound(i)
GloomsHub.Media:Play(ref, kind)      -- kind "kit" → PlaySound (SoundKitID); otherwise PlaySoundFile
GloomsHub.Media:Stop()               -- silences whatever Play last started
GloomsHub.Media:SoundKits()          -- the game's 865 named SOUNDKIT entries, sorted (browser only)
GloomsHub.SOUND_MANIFEST             -- GENERATED index of Sounds\; see SoundsManifest.lua
```
- Fonts register into LSM as `font`; textures as `statusbar`; graphics are NOT in LSM (name→path only).
- **Sounds register into LSM as `sound` (added 2026-08-24).** That registration is the whole point:
  it is what puts them in GA's sound picker and every other LSM-aware addon. Two sources, both
  ending in the same LSM table — the Media tab's hand-added entries (`GloomsHubDB.sounds`) and
  everything listed in `SOUND_MANIFEST`.
- **★ TWO ID NAMESPACES, NOT INTERCHANGEABLE.** `FileDataID` → `PlaySoundFile`; `SoundKitID` →
  `PlaySound`. The same raid-warning sound is FileDataID `567397` and SoundKitID `8959`.
  **LSM's sound table is FileDataID/path ONLY** — every consumer Fetches a value and hands it
  straight to `PlaySoundFile` (BigWigs is the reference; GA's `CDM:PlaySound` does the same). A
  SoundKitID registered into LSM would play the wrong file, or nothing, in every addon that read it.
  `Media:Play(ref, "kit")` is the ONE place allowed to know the difference, and the Media tab's
  sound browser is preview-only for exactly this reason. **Do not "fix" it by registering a kit ID.**
- **`Media:AddSound` VERIFIES before saving** — it test-plays the reference and refuses anything that
  produces no sound, naming the SoundKit if that is what was pasted. WoW exposes no filesystem API,
  so a play attempt is the only existence check available; saving an unplayable sound is worse than
  refusing it, because it reaches GA's picker looking valid and then fails silently on the aura.
- **Back-compat shim — PERMANENT (decided Phase F step 6, the owner 2026-07-24):** GloomsHub defines
  global `StoneTweaks_ResolveAssetPath = function(n) return GloomsHub:ResolveAssetPath(n) end`
  **only if** ST's real one isn't loaded. **Nothing in the suite calls it** (Overlays moved to
  `GloomsHub:ResolveAssetPath` in Phase E gate A) — it is kept as zero-cost insurance for anything
  stale outside the suite. **Live and proven since Phase F**, when ST was retired. Do not remove it.
  The `only if` guard is what makes re-enabling ST safe: ST defines the real function at file load,
  before `PLAYER_LOGIN`, so ST wins and the shim stays dormant.
- SavedVariable `GloomsHubDB.fonts/.textures/.graphics/.sounds` — same `{name,file}` shape as
  `StoneTweaksDB`. For a sound, `file` may be a **number** (FileDataID) as well as a path string.
- **Drop-in folders are `Fonts/ Textures/ Graphics/ Sounds/`** — all four git-ignored, all four the
  owner's own media. `Sounds/` needs a generated index because WoW cannot list a directory:
  `Rebuild Sounds.command` → `tools/build-sound-manifest.sh` → `/reload`. ⚠ **`SoundsManifest.lua`
  ships EMPTY**, exactly like GB's `IconsManifest.lua`. Never commit a populated one.

## 4. LibGloomSkin-1.0 (the shared toolkit) — **PINNED (Phase C, 2026-07-24)**
Registered via LibStub: `local Skin = LibStub("LibGloomSkin-1.0")`. GloomsHub is the canonical
shipper — its `Skin.lua` IS the lib body (embedding a copy in each tool via `.pkgmeta`
externals is Phase G work). `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are Hub-side aliases of the
same tables. Consumers: **GB since Phase C, GA since Phase D, Overlays since Phase E**.

**Exported surface (MAJOR `"LibGloomSkin-1.0"`, MINOR 11) — the whole API; nothing else is public:**
- `Skin.COLOR` — `purple · heroic · green · red · orange` (each `{r,g,b,hex}`), `dark`, `rim`
  (both `{r,g,b,a}`), `text`, `mute` (`{r,g,b}`). The §1 literals.
- `Skin.FONT` — `title · head · body · bodyM · label` → font files under
  `Interface\AddOns\GloomsHub\Media\fonts\` (pre-warmed paths; see the warm-list contract).
- `Skin.MEDIA` — `"Interface\AddOns\GloomsHub\Media\"` (the permanent Hub path — locked).
- `Skin.UI` — the stateless widget factory:
  - `UI.CARET` (caret art path) · `UI.CARET_DOWN` (rotation radians for "open") · `UI.COG` (the
    sub-settings gear, white, tint it — MINOR 9)
  - `UI.setFont(fs, path, size, flags?)` → **`true` if the requested face applied, `false` if the
    stock fallback was used** (MINOR 5). ★ **`SetFont` RAISES on a missing asset — it does not
    return false** (FINDINGS §2/§5), so this helper `pcall`s and can never raise, whatever it is
    handed. Before MINOR 5 it returned nothing and carried the wrong guard internally; a consumer
    that branches on the result **must declare `SKIN_NEEDS = 5`**, because against an older Hub the
    return is `nil` and `if not UI.setFont(...)` takes the fallback branch every single time.
  - `UI.newText(parent, fontPath, size, color?, justify?)` → FontString
  - `UI.addEdges(frame, color, thick?)` — four 1px edge textures (squared border); returns a
    handle with `.top/.bottom/.left/.right` + `:SetColor(color, alpha?)` (MINOR 2 — GA's
    richer variant; ignoring the return stays fine)
  - `UI.skinPlate(frame)` → the flat dark base Texture
  - `UI.hLine(parent)` → 1px rim Texture (caller anchors; SetWidth(1)+anchors for vertical)
  - `UI.flatButton(parent, w, h, color, label?, textSize?)` → Button with `.text`, `:SetActive(on)`,
    `:SetBase(alpha)` — ★ purple/heroic when off, ORANGE when active, for EVERY flatButton
  - `UI.makeToggle(parent, get, set)` → 40×20 sliding switch, `:refresh()`
  - `UI.flatEditBox(parent, w, h)` → EditBox (faint purple fill, brighter on focus).
    ★ **KEYBOARD (MINOR 10, the owner 2026-09-20):** every box the lib makes joins one registry.
    **Tab / Shift-Tab** focus the next / previous box that is visible and shares this box's
    top-level frame (the Suite window, or an open popover / dialog — each its own ring), ordered
    top-to-bottom then left-to-right, wrapping; the box tabbed into selects its text. Leaving a
    box is what commits it in every consumer, so Tab applies. **Up / Down** step a number in the
    box by 1 (**Shift: 10**). Default: the TEXT only (the consumer's Enter / focus-lost commit
    applies it). A consumer wanting the value applied LIVE while the box keeps focus sets
    `e.stepper = function(e, delta) … end` and owns the step (clamp, apply, refresh) — an older
    lib ignores the field, so setting it needs no gate bump (GU's `cNum`, GA's power box).
    ⚠ **Consumer rule (LESSONS):** a box that STORES a setting commits on focus-lost, never
    Enter-only; Escape restores the stored value before it clears focus.
  - `UI.sliderRow(parent, yTop, label, min, max, step, get, set, fmt?, sub?)` →
    `{ refresh, setEnabled, SetShown }` (44px row; ~15px taller with `sub`)
  - `UI.colorSwatch(parent, get, set, withAlpha?, label?)` → `{ swatch, refresh }` — get/set
    use `{r,g,b[,a]}` ARRAYS. Since MINOR 6 it opens `UI.colorPicker`, not Blizzard's frame.
    `label` (also MINOR 6) names the element — `"Bars › Border color"` — and is what the
    palette tooltip lists as WHERE a color is in use. Optional and additive: an older Hub
    ignores it, so **passing it needs no gate bump**.
  - `UI.colorPicker(opts)` → **the suite's ONE color picker** (MINOR 6). Family plate and
    OK/Cancel: HSV field + hue strip, a hex box, the **IN USE palette row** (below), and an
    **Opacity row — the shared `UI.sliderRow`**, so opacity is the same control here as
    everywhere else.
    `opts = { color = {r,g,b[,a]}, hasAlpha?, title?, owner?, onChange(c), onAccept(c)?, onCancel()? }`
    ★★ **It is NOT a modal, unlike `nameDialog` and `confirm` — do not "fix" that**
    (the owner, 2026-07-26). It **changes something on screen while it is open**, so a
    scrim would dim the very thing you are judging. Therefore:
    · **no scrim** — a **purple 1px rim** separates it from the tab instead, which is the
      job the scrim was doing for the other two (same near-black navy on both);
    · **draggable by its plate** (`SetMovable` + `SetClampedToScreen`), because a fixed
      centre-screen panel always lands on top of what you are looking at. On drop it
      re-anchors TOPLEFT so the Opacity row appearing grows it DOWNWARD, and it keeps
      that position for the rest of the session;
    · **`opts.owner`** (the swatch) closes + cancels the picker when its tab or the Suite
      window hides — non-modal is what makes an orphaned picker reachable at all; and
    · opening it while already open **cancels the first session first**, so the previous
      consumer still gets its restore.
  - `UI.NoteColor(c, applied?)` / `UI.ForgetColor(hex)` — the **IN USE palette row**
    (MINOR 6). ★ **It holds colors from the USER'S OWN elements — bars, auras, overlays —
    NOT the suite's design tokens.** The first cut of the row was the token set and that
    was rejected (the owner, 2026-07-26): "Gloom Suite is a lot of purple and orange, and
    those colors shouldn't necessarily be in the palette if the end user isn't using them
    on live elements in their own UI."
    **No tool needs wiring:** every color control in the suite already runs through
    `colorSwatch`/`colorPicker` and every one drives a user-facing element (chrome colors
    are hardcoded tokens and never pass through), so the lib sees exactly the right set.
    `colorSwatch` notes passively on each refresh; the picker's **OK** notes `applied`.
    GA's `MakeColor` calls `UI.NoteColor` itself, being the one swatch not built by the lib.
    · **Two tiers:** *picked* (OK'd) outranks *seen* (merely on an element). A seen color
      takes a free slot or none — it can never evict something the user chose. **This is
      not just recency:** GB refreshes 22 swatches at once, so a single Bars-tab visit
      would otherwise flush every deliberate pick.
    · **Ordered by HUE, not recency** — recency decides what survives, never where it sits.
    · ★ **Passive notes are suppressed while the picker is open.** Consumers refresh their
      swatch on every live change, so one drag across the field would otherwise pour ~60
      intermediate colors a second into the row and bury every real one. Found before it
      ever ran; the drag's RESULT is recorded by OK, which is the whole point.
    · **Right-click removes**, and the removal is REMEMBERED in `paletteHidden` — a color
      still live on an element would otherwise be re-harvested seconds later. Picking it
      again lifts the removal. Deliberately NOT routed through `UI.confirm`: nothing is
      lost and it is trivially reversible.
    · **Provenance — the tooltip's "where is this used" list — is DERIVED, never stored**
      (`UI.RegisterColorSource(frame, get, label)`, walked on each open). ★ Storing a label
      beside the hex as it is harvested **produces a tooltip that lies**: harvesting reports
      what a swatch IS, never what it stopped being, so a color you moved away from would
      keep claiming its old element forever. Computed fresh, it cannot go stale.
      ⚠ **Its honest limit, which the tooltip states:** tabs build LAZILY, so a tool whose
      tab you have not opened this session has registered nothing and can never be listed.
      **"Not seen" is not "not used"** — do not reword the tip into a claim it can't back.
      Registry is keyed BY FRAME so a rebuilt row overwrites itself; `get` is `pcall`ed
      because a closure left by a rebuilt row can reference a bar or aura that is gone.
      Labels: GB wraps `colorSwatch` locally to prefix `"Bars › "` once instead of at 20
      call sites.
    · ★ **`UI.RegisterColorProvider(key, fn)` — for a tool that owns MANY elements of the
      same kind.** A tool's editor has ONE Recolor control that re-points at whatever is
      selected, so a per-control getter can only ever report **the selection** — recolor
      forty auras and the tooltip still names one (the owner, 2026-07-26). A provider walks
      the tool's own config and reports every element **by name**; only the tool knows how.
      `fn()` → `{ { color = {r,g,b}, label = "Auras › Recolor (Kill Shot)" }, … }`
      **Providers also feed the palette itself** (walked on open, before `Show`, so the
      open-picker guard doesn't eat it) — otherwise an aura recolored months ago never
      reaches the row unless you happen to click it again.
      | tool | how | why |
      |---|---|---|
      | **GA** | provider, all displays | recolor/text/glow are **per aura** |
      | **Overlays** | provider, all overlays | tint is **per overlay**; plain white skipped, since untinted overlays store white and would bury the row |
      | **GB** | per-swatch labels, no provider | ★ its colors are **one per PROFILE** (`GB.db.styleData`), NOT per bar — verified 2026-07-26 |
      ⚠ Both providers are called through `if UI.RegisterColorProvider then`, so
      **Overlays' gate stays at MINOR 4 deliberately** — losing tint provenance on an old
      Hub is cosmetic, while declaring 6 would disable its whole editor. Drop the guard and
      the gate must go to 6 in the same commit.
    · Storage: `GloomsHubDB.palette` / `.paletteSeq` / `.paletteHidden`, cap **12**.
      ★ **The lib may reach for the Hub's SavedVariable** because there is exactly one of
      each — the Hub is a hard dependency and per-tool embedding was DROPPED (ARCHIVE).
      Without a Hub the row degrades to empty and never errors.
    ★ **It applies LIVE via `onChange` and RESTORES on every non-OK close** — Cancel, ESC,
    or the frame being hidden underneath it. Blizzard's picker only restored if you passed
    a `cancelFunc` and **nothing in the suite ever did**, so cancelling used to leave the
    last color you dragged over applied. That bug is fixed everywhere at once.
    `onChange` does NOT fire on open — seeding the widgets is not an edit.
  - `UI.dirRow(parent, yTop, label, get, set)` → `{ refresh, setEnabled }` — "up"|"down"|"left"|"right"
  - `UI.makeScrollbar(parent, scrollFrame, place)` → thin orange-thumb bar with `:Sync()`
  - `UI.attachTip(frame, title, body)` — the family hover tooltip (HookScript, coexists)
  - `UI.dropdown(parent, w, getLabel, getOptions, getCurrent, onPick)` → the family's
    "pick from a list" (MINOR 3): a flat button + orange caret opening a flyout behind a
    full-screen click-catcher; `getOptions()` → `{ {value=,label=}, … }`; scrolls past 12
    rows. Returns the button with `:refresh()`. Promoted from GB's private `animDropdown`.
  - `UI.flyout()` → the shared flyout frame (built on demand), exposed so a consumer can
    observe the open list. **Test it with `:IsVisible()`, not `:IsShown()`** — the flyout is
    a child of the catcher and is only ever hidden via that parent. GB pings the selected
    bar while its Preset list is up.
  - `UI.nameDialog(title, initial, onAccept)` — the skinned text-entry modal (MINOR 3);
    OK/Enter accepts, Cancel/ESC drops it. Replaces StaticPopup **and** the near-identical
    private copies GB and GA each used to carry. ★ **Since MINOR 7 it TRIMS leading/trailing
    whitespace** before calling back, once, for every consumer — a stray space made a second
    profile that looked identical to the first in the dropdown. A consumer that still trims
    its own name (GA's Core does) is harmless, just redundant.
  - `UI.confirm(body, onYes, acceptLabel?, titleText?)` — the skinned yes/no modal; **its plate
    grows with the body** (MINOR 10 — a profile delete may list several characters)
    (MINOR 3). ★ **Every destructive action uses this.** A self-arming "click twice to
    confirm" button is NOT acceptable: once armed there is no way to back out
    (the owner 2026-07-24 — GB's old `confirmable` had exactly that trap and is retired).
  - `UI.profileBlock(parent, w, api)` → **the suite's ONE profile/preset management
    control** (MINOR 3): header + `UI.dropdown` + New/Copy/Rename/Delete + an inline note
    line, with delete routed through `UI.confirm`. The tool supplies only its data
    plumbing, so the mechanism is identical in every tab (the owner 2026-07-24: "for this
    mechanism … they should all be using the same thing"). Omitting `api.copy` lays the
    buttons out 3-across (GB's preset block). Returns `{ frame, refresh, note, height }`.
    `api` = `noun · names() · active() · switch(v) · create(name) · copy(name)? ·
    rename(name) · delete()` (each mutator → `ok, err`; `err` shows in the note line)
    `· users(name)? · onChange()? · title? · accent? · tips{dropdown,new,copy,rename,delete}?`
    ★ **`users(name)` (MINOR 10, the owner 2026-09-20) → the DELETE GATE:** returns the keys of
    every character bound to that profile (the tool's own format, `Name-Realm` or `Name - Realm`;
    the block trims to the name and drops the character you are on). When any remain, the
    confirmation lists them — *"Besides this character, it's in use by A, B and C — they'll fall
    back to another profile"* — so a shared profile is never deleted blind. GB, GA and GU supply
    it from their account-wide maps; Overlays cannot (per-character SavedVariables) and keeps the
    plain confirmation. Omitting it needs no gate bump.
    ★ **`accent` (MINOR 7)** recolours the block's four buttons; defaults to `COLOR.heroic`.
    It exists because GB's rail carries TWO of these blocks and, in one colour stacked
    together, they read as the same control — the owner could not tell which scope a button
    belonged to (2026-08-15). GB now draws PROFILE purple at the top of the rail and PRESET
    **orange at the bottom**. An older lib ignores the key, so **passing it needs no gate
    bump** (same rule as `colorSwatch`'s `label`) — the buttons just stay purple.
  - `UI.tabHeader(parent, opts)` → **the suite's ONE tab header** (MINOR 4): the owning
    tool's square mark beside its wordmark, with a divider under it. The owner, 2026-07-25:
    he saw it on the Overlays tab and wants it on every tab. **Overlays built it inline
    first and now CONSUMES this** — do not re-inline it anywhere.
    `opts = { texture, label, x = 14, y = -12, size = 26, gap = 9, fontSize = 17,
    divY = -48, rightInset = x }`. Returns `{ logo, text, divider, bottom }`; `bottom` is
    the y offset callers anchor their first row below.
    ★ **The mark is SQUARE — the art is 1:1 (512×512, transparent). Never stretch it.**
    **All four tabs carry one as of 2026-07-25** — Auras was the last holdout (its
    retired splash sat exactly where the header goes) and adopted it in its layout rework.
    ★ **Which mark:** a *tool's* tab wears that tool's mark; the **Media tab wears Gh**
    (the Hub-as-an-addon), NOT GS — GS is the *suite's* mark and already sits on the
    window title bar directly above.
  - `UI.WarmFonts(extraPairs?)` — **the Hub calls this, once, at PLAYER_ENTERING_WORLD**
    (Media.lua's `VerifyFonts`; LSM *registration* itself moved earlier, to the Hub's own
    ADDON_LOADED, on 2026-09-19 — FINDINGS §16); draws the base list + everything registered + the arg
  - `UI.RegisterWarmPairs({ {fontPath, size}, … })` — **how a TOOL warms its pairs**: call at
    file load; pairs queue and warm with the Hub's PEW batch (called after the batch — e.g.
    load-on-demand — it warms immediately). Each (path, size) draws at most once per session.
  - **Both return `dead`** (MINOR 5) — a `path → true` map of every pair whose face would not
    load, or `nil` if all were fine. Because warming draws each font before anything else uses
    it, this is the **only existence check the client permits**: WoW exposes no filesystem API,
    so a failed draw is the one way to learn a saved filename is a typo or its file is gone.
    `Media.lua` uses it to name a broken catalog entry in chat. ⚠ **Do not gate LSM registration
    on it** — a font added this session with a restart pending may fail the probe while being
    perfectly valid (fonts load at launch), and dropping a good font is worse than the warning.
  - **`UI.grid(parent, yTop, opts?)` → the TWO-COLUMN placer (MINOR 9).** The owner, 2026-09-19:
    EUI "compacts the settings panels into dropdowns and side-by-side display, whereas you tend to
    just stack things endlessly." `g:cell(h, build)` → a half-width Frame (two per line; a
    one-column grid — `opts.cols = 1`, a popover's stack — makes every cell a row) ·
    `g:row(h, build)` → full width · `g:gap(px)` · `g:endLine()` · `g:show(frame, on)` hides a
    cell and the line collapses when empty · `g:layout()` restacks and returns / sets `g.height`.
    Cells anchor by the parent's edges and centre, so they follow its width with no numbers of
    their own; widgets inside keep their 18px insets, so the outer margin is the family's and the
    two columns get a 36px gutter for free (`opts.gutter` widens it). **A tab's `refresh` calls
    `g:layout()` and re-reads `g.height`** — the grid moves, the accordion follows. First consumer:
    the Unit Frames tab, every section body.
  - **`UI.popover(opts)` → a small anchored panel for a control's SUB-SETTINGS (MINOR 9)**, and
    **`UI.cog(parent, opts)` → the gear that opens one** (purple, orange while open; `opts.tip =
    { title, body }`). `opts = { owner, w, title, build(content) → contentHeight, onOpen(content)
    → newHeight?, onClose? }`. The family plate with the colour picker's purple rim and NO scrim
    (you are judging the thing it changes), hanging off the owner's bottom-right, clamped to the
    screen; built lazily once. Closes on any outside click (a full-screen catcher at FULLSCREEN
    level 0, the panel at level 5), on its owner hiding, or when another popover opens.
    ★ **Layering, fixed on purpose:** the dropdown flyout's catcher was raised to level 20 so a
    list opened INSIDE a popover dismisses cleanly; the colour picker (FULLSCREEN_DIALOG) floats
    over both. A control inside a popover that changes something the grid also shows (GU's
    interrupt popover carries the ring's Color) must repaint the grid's copy itself — nothing
    links them. Consumers: the Unit Frames tab (shield tint · interrupt colouring · effect
    settings · aura filters · the shortcode list).
- **★ THE KIT (MINOR 11, 2026-09-21)** — the redesign's widgets, one per PRIMITIVES control. Each
  function's header comment in `Skin.lua` is its spec; this is the surface:
  · `UI.roundFill(parent, layer?)` → the ONE nine-slice (4px corners, `UI.ROUND`, margins 5) ·
    `UI.tint(tex, color, a?)`
  · `UI.button(parent, label, opts?)` → `{ kind = "action"|"state"|"warn"|"quiet"|"paper", w, h=17,
    size=11, padX=20, font, caps=true, active, onClick }`; `:SetLabel · :SetActive · :SetKind`.
    Width follows the label unless `w`. Disabled = 50% alpha.
  · `UI.label(parent, text)` → Play Bold 12 ink · `UI.field(parent, w, opts?)` → the white input (a
    `flatEditBox` underneath — same Tab ring, same commit rules; lilac selection)
  · `UI.segments(parent, options, get, set, opts?)` → the segmented bar, `:refresh · :setEnabled`;
    `UI.toggleBar(parent, get, set)` = OFF | ON · `UI.check(parent, label, get, set)` → checkbox
  · `UI.pick(parent, w, getLabel, getOptions, getCurrent, onPick, opts?)` → the dropdown: `kind =
    "state"` (violet, as wide as its widest option when `w` is nil) or `"field"` (white + triangle);
    an indigo list, current row amber. ⚠ The owner dislikes its look (BACKLOG 16) — expect change.
  · `UI.sectionHeader(parent, text, { open, onToggle })` → triangle + Play Bold 14 violet; `:SetOpen`
  · **`UI.dial(parent, opts)` → THE SCRUB DIAL, the replacement for every slider.** `{ label, min,
    max, step=1, get, set, unit="", centre=false, w=194, dragPx=900, fmt? }` → `:refresh ·
    :setEnabled`. Its definition (five rounds with the owner) is the header comment — do not
    redesign it. `UI.sliderRow` stays for un-migrated tabs.
  · `UI.wordmark(parent, suffix, size, opts?)` → "gloom" + SUFFIX in Michroma, `:SetMark`
  · `UI.profileRow(parent, api, mark)` → the footer form of `profileBlock` (same `api`, same
    dialogs, same delete gate); the shell calls it — a tab passes `profile` to `RegisterTab`.
  · `UI.makeScrollbar(parent, scroll, place, { kit = true })` → the kit's capsule scrollbar.
  · The **dialogs, tooltip and colour picker** wear the kit (night plate + indigo rim, kit buttons;
    the picker is 440 wide with the Opacity DIAL on the hex row). **Modals dim the Suite WINDOW,
    not the screen** (the owner, 2026-09-21); the picker never dims (his 2026-07-26 ruling stands).
  · Art under `Media/ui/`: `round4` (nine-slice) · `pill` (scrollbar) · `dot` · `tri` (points DOWN;
    +90° = right) · `dial` / `dial-c` (the tick strips, 141 × 16).
  · **Not built yet:** the colour CHIP (swatch + "(Remove)" / "None") and the picker's colour
    SOURCES — they land with the first consumer that stores a source (stage 2).
- **NOT exported (deliberate):** `makeSection` — each tab's accordion closes over its own
  scroll/relayout/one-open state, so the Media tab and the Bars tab each keep a local copy of
  the small pattern. Revisit at Phase D if GA shows a clean shared shape; adding it then is a
  MINOR bump, not a break.
- **Warm-list contract (QA-proven Phase B):** WoW draws a cold (font file, size) pair BLANK the
  first time it's drawn each client session (a /reload heals it; the next cold start re-breaks
  it). The Hub's base list covers the shell + Media tab + **the lib's own widgets**
  (`title 17/21 · head 12/16 · body 10.5/11/12/13 · bodyM 11/12/13 · label 11`) + each catalog font at
  11/13/14 (picker sizes). `title 17` (nameDialog/confirm) and `head 12` (profileBlock) joined
  the base list at MINOR 3 — the lib draws them itself now, in every tool. **`label 11` joined
  at MINOR 6**: `UI.sliderRow`'s value text is a LIB widget's, and `colorPicker`'s Opacity row
  is the lib drawing one on its own account — the base list owes every pair the lib itself draws. **Every
  (font, size) pair ANY suite tab draws beyond that must go through `RegisterWarmPairs`** —
  when a tool migrates, enumerate its sizes (`grep -ohE 'FONT\.\w+, [0-9.]+' *.lua |
  sort -u`) and register the ones the base list misses. GB registers: `title 17/18 · head
  12/13 · body 9.5/10/12.5 · label 10/10.5/11` (Config.lua, right after the toolkit aliases).
  GA registers: `title 13/16/17/18/20 · head 12/13 · label 11/12` (same spot in its Config.lua).
  The kit's pairs joined the base list at MINOR 11: `ui 11 · uiB 12/14 · mark 12/14/22`.
  Overlays registers: `title 16 · head 13 · label 11` (GloomsOverlays_Editor.lua). Pairs dedupe
  across addons, so overlap — and a tool re-registering something the base already covers — is free.
- **Versioning:** LibStub newest-wins. Additive changes bump MINOR here + in `Skin.lua`
  (`local MAJOR, MINOR`) in the same session; breaking changes need a new MAJOR ("-2.0") and
  The owner's sign-off.

## 5. Consumers to keep in lockstep
- **GloomsBars** — ✅ migrated (Phase C, 2026-07-24): consumes LibGloomSkin, mounts the Bars
  tab, `/gb` + minimap button route to `GloomsHub:ToggleWindow("bars")`, hard-depends on the
  Hub. (Bar ENGINE keeps `GB.FONT` on GB's own files — see the §1 note.)
  **Phase E (QA'd 2026-07-24):** its private name dialog + `animDropdown` +
  two-click `confirmable` are DELETED; the rail's PROFILE and PRESET blocks are now
  `UI.profileBlock`, and `animDropdown` is a one-line alias of `UI.dropdown` for its four
  remaining call sites.
- **GloomsAuras** — ✅ migrated (Phase D, 2026-07-24): consumes LibGloomSkin, mounts the Auras
  tab (centered 620 column), `/ga` → `GloomsHub:ToggleWindow("auras")`, `CatStoneTweaks` →
  `GloomsHub:ListMedia` (relabelled "Suite Graphics"), hard-depends on the Hub. (`GA.FONT`
  stays on GA's own files — user configs store those paths; see the §1 note pattern.)
  **Phase E (QA'd 2026-07-24):** its private name dialog + confirm modal are
  DELETED (`OpenNameDialog` aliases
  `UI.nameDialog`; `C:OpenConfirm` wraps `UI.confirm`), and the shared `UI.profileBlock`
  replaced its own list + four buttons.
  **Layout rework (QA'd 2026-07-25):** the profile DRAWER is gone — the block now sits
  permanently at the top of a GB-style left rail, and GA consumes `UI.tabHeader`, so its gate
  is **MINOR 4** (§6). Four of GA's docked drawers were deleted in that pass; only the
  transient pickers remain. All three tools now drive the same profile control in the same
  place, which is what the shared block was for.
- **Gloom's Overlays** — ✅ migrated (Phase E, both gates QA'd 2026-07-24): repo
  `~/GloomsOverlays`, hard-deps
  the Hub, resolver → `GloomsHub:ResolveAssetPath` (**the suite's last StoneTweaks consumer —
  gone**), slash `/go` (`/vibe` retired; bare `/go` toggles the tab). Gate B: mounts the
  `overlays` tab (order 30) as a GB-style rail + editor; ALL native chrome deleted (no
  `BackdropTemplate`, `UIDropDownMenu`, `StaticPopup`, `UIPanel*Template`, `MakeButton`/
  `MakeSlider`/`MakeCheck`); asset browser is a docked drawer; warm pairs registered.
  Keeps SavedVariables globals `VibeOverlayDB`/`VibeOverlayDBChar` on purpose.
- **Gloom's Portraits** — ✅ built as a consumer from the start (2026-09-19): repo
  `~/GloomsPortraits`, hard-deps the Hub, mounts the `portraits` tab (order 40) as a GB-style rail +
  editor from `GloomsPortraits_Tab.lua`; gate **`SKIN_NEEDS = 4`** (`tabHeader`); warm pairs
  `head 13 · label 11` registered; no profile block (two fixed units, one config); slash `/gp` →
  `GloomsHub:ToggleWindow("portraits")`. Every native template its predecessor used
  (`OptionsSliderTemplate`, `UIPanelButtonTemplate`, `BackdropTemplate`, LibDBIcon) is gone.

---

## 6. The shared-toolkit VERSION GATE — **every tool must carry one**

**The problem it solves.** `LibGloomSkin-1.0` lives in the Hub and **grows** — MINOR 2 added
`addEdges`, MINOR 3 added `dropdown`/`flyout`/`nameDialog`/`confirm`/`profileBlock`, MINOR 10 the
edit-box keyboard ring. Every tool
calls into it. But **`## Dependencies: GloomsHub` only checks that the Hub is PRESENT, never that
it is NEW ENOUGH** — WoW's TOC dependency system has no version constraint at all.

So once the addons version independently (which they now do — the "all four synchronized"
scheme was relaxed once drift became legible), this becomes reachable:

> A user updates **Gloom's Bars** but not **Gloom's Hub**. GB calls a MINOR-4 widget. Their Hub is
> MINOR 3. `UI.newWidget` is `nil` → `attempt to call a nil value` → the tab never builds and
> BugSack fills with errors that mean nothing to them.

**The direction matters:** a Hub AHEAD of its tools is always safe (MINOR only adds). The hazard is
only a **tool ahead of the Hub**.

### The contract
Every file that consumes LibGloomSkin declares the MINOR it needs and checks it *before* touching
the toolkit:

```lua
local SKIN_MAJOR, SKIN_NEEDS = "LibGloomSkin-1.0", 3

local Skin, skinMinor = LibStub(SKIN_MAJOR, true)
if not Skin or (skinMinor or 0) < SKIN_NEEDS then
  -- ... print ONE actionable line at PLAYER_LOGIN ...
  return   -- chunk-level return: the tab is never registered
end
```

- **★ Bump `SKIN_NEEDS` in the SAME commit that first calls a newer widget.** This is the only
  maintenance the gate needs, and forgetting it is the one way to defeat it.
- **Gate the UI file, never the engine.** `Config.lua` is last in GB's and GA's TOC and
  `_Editor.lua`/`_Preview.lua` load after `GloomsOverlays.lua`, so a chunk-level `return` skips
  only the tab. **Bars keep working, auras keep working, overlays keep rendering** — the user
  loses configuration, not function, and the message says so.
- **One message per addon.** GO gates both `_Editor.lua` and `_Preview.lua` but only the editor
  prints; the preview returns silently.
- **The message names the fix, not the fault** — "please update Gloom's Hub", plus needed vs.
  found. Never make a non-developer read a stack trace to learn they should click Update.
- **The shell already degrades safely** — `FocusTab` no-ops on an unknown id and `Open` falls back
  to a valid tab, so a missing tab cannot cause a *second* error. Verified 2026-07-25.

### Current requirement
| Consumer | needs |
|---|---|
| `GloomsBars/Config.lua` | MINOR **5** — branches on `UI.setFont`'s return (font picker) |
| `GloomsAuras/Config.lua` | MINOR **6** — calls `UI.colorPicker` directly (its `MakeColor` swatch) |
| `GloomsOverlays/GloomsOverlays_Editor.lua` | MINOR **4** — calls `UI.tabHeader` |
| `GloomsOverlays/GloomsOverlays_Preview.lua` | MINOR **3** — the drawer needs nothing newer |
| `GloomsPortraits/GloomsPortraits_Tab.lua` | MINOR **4** — calls `UI.tabHeader` |
| `GloomsUnitFrames/GloomsUnitFrames_Tab.lua` | MINOR **11** — the kit (`UI.button` / `dial` / `pick` / `sectionHeader`) and `RegisterTab`'s `profile` footer (bumped 2026-09-21, in the commit that first called them) |

★ Note the table is **not uniform, and that is correct** — each file declares what IT
actually uses. MINOR 4 landed as the first live exercise of this gate: `UI.tabHeader` was
added and the two files that call it were bumped **in the same commit**. GA followed the
same discipline on 2026-07-25 when its layout rework adopted `UI.tabHeader` — gate bumped
in the commit that first called it, which is the only maintenance this gate ever needs.

Hub currently ships **MINOR 11** (`Skin.lua`, 2026-09-21).

⚠ **This line was stale for three weeks** — it still said MINOR 6 after 7 shipped on 2026-08-15, and
was only caught on 09-08. It is the line a session reads to decide whether a `SKIN_NEEDS` bump is
needed, so a stale value here defeats the very gate §6 describes. **Update it in the same commit that
changes MINOR**, exactly as the consumer table demands.

★ **GB and Overlays did NOT need a bump for the color picker** — they reach it through
`UI.colorSwatch`, whose signature is unchanged, so an older Hub simply gives them the old
Blizzard picker rather than a nil call. GA needed one because its `MakeColor` (checkbox +
swatch, with an unset state `colorSwatch` can't express) calls `UI.colorPicker` itself.

**Why this exists at all (the owner, 2026-07-25):** he asked whether letting the four addons'
versions drift was a problem he wasn't aware of. It was — this was the problem, and it was live:
all three tools did a bare `LibStub("LibGloomSkin-1.0")` with no version check whatsoever. The gate
is also what makes the locked **hard-dependency** decision deliver what it promised: that a missing
or inadequate Hub fails **loudly and legibly**, rather than as a pile of nil-call errors.

---

## 7. The silhouette catalog (GloomsHub owns) — **NEW 2026-08-25**
```lua
GloomsHub.SHAPES          -- key → { aspect, orient, label }   (21 shapes)
GloomsHub.SHAPE_ORDER     -- ordered keys, picker order
GloomsHub.SHAPE_GROUPS    -- { {title="1:1", keys={…}}, Portrait, Landscape }
GloomsHub.SHAPE_PARTS     -- { "base","outer","inner","rim","line","swipe" }
GloomsHub:ShapeAsset(key, part)   -- → path, or nil for an unknown key
GloomsHub:ShapeInfo(key)          -- → metadata, falling back to circle
GloomsHub:HasSplitSwipe(key)      -- the five 2:1 portraits also ship swipe-t / swipe-b
GloomsHub:GrowAnchor(tex, icon, grow)
```
Art lives in `Media\art\shapes\<key>-<part>.png`, tracked and shipped.

- **★ THE FILES ARE THE CONTRACT.** `key` and `part` index real files. Adding a shape means adding
  its art AND its catalog row; renaming a key orphans every saved profile that stored it. **Treat
  both as append-only.**
- **★ THE ART IS HALF MARGIN.** 512×512 (portraits 512×768), silhouette in the central half.
  A mask or glow must be anchored to a rect **twice** the icon's size — which is what `GrowAnchor`
  at `grow = 0` produces. `SetAllPoints` draws it at half size in a transparent border.
- **A mask texture must be WHITE**; masks read LUMINANCE, not alpha. This art was whitened on
  import. Set it with `CLAMPTOBLACKADDITIVE` on both axes.
- ⚠ `GrowAnchor` has a **twin**: `hgAnchor` in `GloomsBars/Skin.lua`, still used by GB's own layout.
  Verified identical 2026-08-25. **Change the formula and you change both.** Backlog item 10.

### 7b. The BAR-shape family (GloomsHub owns) — **NEW 2026-09-21**
```lua
GloomsHub.BAR_SHAPES        -- key → { label, canvas = {w,h}, footprint = {x0,y0,x1,y1}, set?, setFootprint? }
GloomsHub.BAR_SHAPE_ORDER   -- ordered keys, picker order
GloomsHub:BarShapeAsset(key, part)   -- part: "base" | "base-s" | "rim" | "rim-thin" | "rim-thick"; nil for an unknown key
GloomsHub:BarShapeInfo(key)          -- → the row, falling back to orb
```
Art lives in `Mediartarshapes\<key>-<part>.png`; `tools/gen-barshapes.py` writes it (generated
shapes, or the owner's imported files) and prints the rows with the footprint MEASURED from the
alpha. **A separate family from §7 by the owner's ruling** — GU never lists the button shapes, GB
and GA never list these. Same mechanism: files are the contract, keys are append-only.
- **The footprint is the bar's box**; the mask is the whole canvas, placed so the footprint lands
  on the box (a set member may sit off-centre). A **set** = members sharing a canvas; `size` on a
  member scales `setFootprint`, so one size nests the set.
- The base art's edge is BINARY; `-base-s` (quarter size, anti-aliased) is for draws under ~192 px.
- Masks refuse flipped texcoords (FINDINGS §21) — a flip is a mirrored file.

## 8. `GloomsHub.Effects` — the shaped animation engine (GloomsHub owns) — **NEW 2026-08-25**
```lua
GloomsHub.Effects.VERSION            -- 1; bump when the module set or contract changes
Effects:Register(mod) / :Get(id) / :Each(fn)
Effects:MergeParams(id, saved)       -- module defaults with `saved` laid over; nil if id unknown
```
Eight modules: `shine` Comet Chase · `march` Marching Lines · `sheen` Sheen Sweep · `sparkle`
Sparkles · `breathe` Breathe · `burst` Burst Ring · `rimflash` Rim Flash · `radar` Radar Sweep.
Shared textures in `Media\art\effects\`.

**Module contract:**
```lua
{ id, label, defaults = {..}, params = { {key, kind, label, ...}, .. },
  Start(host, icon, key, p), Stop(host) }
```
- `host` is ANY frame; `icon` is the region it sizes against; `key` is a Shapes catalog key.
  **Start is idempotent** — call it again to reconfigure live.
- `kind` is what a consumer's UI switches on: `"color"` | `"range"` | `"bispeed"` | `"choice"`.
  A **`bispeed`** is one SIGNED velocity in `[-1,1]`: sign = direction, magnitude = speed, 0 = still.
- **★ EVERY module needs a shape key.** No key, nothing to trace — the consumer must say so rather
  than offering a control that silently does nothing.
- **★ GUARD RE-`Start` ON HOT PATHS.** Modules prime their textures to `PRIME_ALPHA` and reveal one
  frame later (because `AddMaskTexture` fails silently on a never-rendered texture), so an unguarded
  re-push storm makes an animation *invisible*, not merely slow. GB guards via `Anims:Reconcile`
  skipping an unchanged winner; GA via a signature of module + shape + merged params. FINDINGS §14.
- **HOLLOW vs MASKED:** `breathe`, `burst` and `rimflash` draw the shape's `rim` art directly, so
  they have no centre and can overlay a live action button. The other five mask to the shape.
- **★ HOSTS UNDER A BLIZZARD AURA BUTTON are supported (2026-09-19, for Gloom's Unit Frames).**
  The masked modules' deferred bind treats a secret `IsShown` as shown and VERIFIES the bind via
  `GetNumMaskTextures`, retrying every 0.5 s while the instance is active — so `Start` may be
  called at wiring time on a host that has not drawn yet, and the effect appears when the engine
  shows the button. No `VERSION` bump: the contract is unchanged and a plain visible host behaves
  as before. FINDINGS §20 has the measurements.

### Consumers
| Consumer | uses |
|---|---|
| `GloomsBars/Core.lua` | `HAND_SHAPES`/`HAND_ORDER`/`HAND_GROUPS`/`HandAsset` are aliases onto §7 |
| `GloomsBars/Anims.lua` | wiring only — modules come from §8 |
| `GloomsAuras/Displays.lua` | `ApplyShape` (§7) and `ApplyEffects` (§8) |
| `GloomsAuras/Config.lua` | the shape picker and the schema-driven settings popup |
| `GloomsUnitFrames/GloomsUnitFrames_Auras.lua` | `ShapeAsset`/`GrowAnchor` on every aura icon (§7); `Effects` on the "This spell" slot buttons (§8) |
| `GloomsUnitFrames/GloomsUnitFrames_Tab.lua` | the shape dropdown and a schema-driven effect-settings block |

⚠ **These are ENGINE-level dependencies, so they must DEGRADE, never error** — CONTRACTS §6's rule
still holds. `GB:HandAsset` returns a path for any non-nil key even against an ancient Hub;
`GB.HAND_SHAPES` falls back to a one-entry circle catalog; `GB.Anims` resolves `Effects` per call
and runs nothing if it is absent. GB's `Config.lua` login gate now also fires when the catalog is
missing, and its message no longer claims the bars are unaffected — because they would be.


### `UI.WarmFonts` — the second-draw rule (MINOR 8, 2026-09-08)
```lua
UI.RegisterWarmPairs{ {path, size}, … }      -- queue at file load; warms with the batch
UI.WarmFonts(extraPairs, onVerified)         -- the Hub calls this ONCE at PLAYER_LOGIN
```
- The **synchronous return value is a GUESS and must never be used to accuse a file.** The first
  draw of a cold pair fails as a matter of course — that is what warming exists to fix.
- `onVerified(stillDead)` fires ~2s later with only the paths that failed a **second** draw. That is
  the trustworthy answer, and the only one that should reach the user. FINDINGS §5.
- ⚠ **Registration is never gated on either result.** Silently dropping a good font is worse than
  the false warning this replaced.
