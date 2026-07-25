# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-24 (Phases C, D **and E** built + QA'd. **NEXT = the identity scrub, TASK 0 in HANDOFF.md — it outranks Phase F.** Then Phase F — retire
StoneTweaks; briefing in HANDOFF.md). Phase E gate B also promoted the whole profile/preset
mechanism into LibGloomSkin (**MINOR 3**) and switched GB + GA onto it; all three addons were
QA'd in the same pass.

## Phase status

| Phase | What | Status |
|---|---|---|
| — | Scaffold GloomsHub repo + symlink + docs (home of record) | **DONE (not QA'd — no code yet)** |
| **A** | Stand up GloomsHub, media-only (registration + resolver + ST→Hub copy-migration + compat shim + asset folders). Touch nothing else. | **DONE — QA'd by the owner 2026-07-24** (clean BugSack; DrukMedium serves from the Hub; catalog 1 font / 6 textures / 36 graphics, `migratedFromST = true`; Overlays unaffected). Known transition artifact: ST prints "skipped — already registered" lines at login because the Hub (loads first) now wins the LSM names — harmless, ST's own code, gone at Phase F. |
| **B** | Empty tabbed shell + Media tab. Add `/gloom`. Old windows still work. | **DONE — QA'd by the owner 2026-07-24** (window/toggle/Escape/drag; catalog 1/6/36 with previews; accordion + orange scrollbar; add/remove incl. `.otf` rejection; old windows untouched; cold-start re-verified). Two findings baked in: (1) **cold-start blank-text quirk** — WoW draws a cold (font file, size) pair blank the first time each session (a /reload heals, next cold start re-breaks); fixed by Skin.lua's `UI.WarmFonts` login pre-warmer — EXTEND its pair list whenever new UI font sizes appear (Phase C!). (2) overlapping family windows interleave (same strata, pre-existing GB/GA quirk) — accepted by the owner; self-resolves as tools mount tabs (C–E). |
| **C** | Migrate Gloom's Bars as the proof (Bars tab, `/gb` reroute, toolkit → LibGloomSkin). | **DONE — QA'd by the owner 2026-07-24** (gate passed; the one first-pass gap — no suite launcher — was filled same day and verified: the Hub owns the ONE GS minimap button, GB's is deleted). Shipped: `LibGloomSkin-1.0` (surface pinned CONTRACTS §4, incl. `RegisterWarmPairs`); GB hard-deps the Hub; local toolkit + standalone window DELETED; editor mounts as the Bars tab with its own in-tab footer row; `/gb` → `ToggleWindow("bars")` (diagnostics untouched). GB's bar-ENGINE fonts deliberately stay on GB paths (CONTRACTS §1 note). **The container-mount pattern is PROVEN.** |
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | **DONE — QA'd by the owner 2026-07-24** ("works as it did before"). Shipped: GA hard-deps the Hub; local toolkit copy + standalone window DELETED; options UI mounts as the **Auras** tab (centered 620-wide column; docked drawers parent to the container); `/ga` → `ToggleWindow("auras")`; `/ga minimap` drives the Hub's button; GA's minimap button DELETED; `CatStoneTweaks` → `GloomsHub:ListMedia` ("Suite Graphics" — GA reads NO StoneTweaks data anymore). Shell grew to 860×740 (content 860×626 PINNED, CONTRACTS §2); lib at MINOR 2. Noted for polish (below): the Auras landing page. |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | **DONE — QA'd by the owner 2026-07-24. Split into two QA gates** (the handoff's own "QA the migration FIRST" instruction, so a reskin bug can never be mistaken for data loss). **Gate A DONE — QA'd by the owner 2026-07-24**: clean BugSack; addon list shows "Gloom's Overlays", VibeOverlay gone; overlays render identically; `/go list` correct; **Goldset renders on Gloomthorn** (the per-character proof); `/go overlays` + `/go preview` work (still native chrome); `/vibe` retired. **DONE — gate B QA'd by the owner 2026-07-24** (22 steps, all passed, incl. a cold client restart on Gloomthorn/`Goldset` and the GB + GA regression checks). Shipped: the `overlays` tab (order 30) laid out like GB's — a 240 left rail (GO mark + wordmark · the shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, with an in-tab footer (Save & Apply + status); ALL native chrome deleted (no `BackdropTemplate`, `UIDropDownMenu`, `StaticPopupDialogs`, `UIPanel*Template`, and the `MakeButton`/`MakeCheck`/`MakeEditBox`/`MakeSlider`/`SectionLabel` locals are gone); the asset browser is a 360-wide docked drawer opened from the Texture field's **Browse…** (returns the pick via "Use This Texture"); bare `/go` toggles the tab and the old `PLAYER_LOGIN` slash-wrapping in `_Preview.lua` is gone (one router in `GloomsOverlays.lua`); warm pairs registered. **Also, per the owner 2026-07-24 — the profile/preset mechanism is now ONE shared control across the suite** (see the lib row below). |
| **F** | Retire StoneTweaks (delete last, non-destructively). | not started |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, embed LibGloomSkin, WoWup. | not started — but its **BLOCKING PREREQUISITE, the identity scrub, is ✅ DONE (2026-07-24)**. All five repos had history rewritten with `git-filter-repo` (content + commit messages + author/committer metadata), were verified clean on fresh mirror clones *pulled back from GitHub*, and force-pushed. Every gate is zero in all five: author/committer fields, commit messages, all-history blobs, HEAD files. Every author and committer is now `Gloom <gloom@handofdevastation.invalid>` (plus `github-actions[bot]` on Build Barn's cron commits, which is correct). **The two missing repos now EXIST:** `HandofDevastation/GloomsHub` and `HandofDevastation/GloomsOverlays` were created PRIVATE and pushed, so all five repos now have an `origin`. ⚠ **ALL FIVE REMAIN PRIVATE — nothing was flipped public.** Two things Task 0 taught, both recorded in full in HANDOFF.md: (1) **published release ZIPs are a separate surface a force-push cannot reach** — GB's three release assets contained the name and had to be regenerated by re-pushing the rewritten tags; (2) **Build Barn's remote was AHEAD of its local clone** (its cron writes commits and tags directly on GitHub), so the first push rolled its `main` back a fortnight before it was recovered from the surviving tags — nothing lost, `BuildData.lua` verified byte-identical. Still open: old pre-rewrite commits may linger on GitHub addressable by SHA (the airtight fix is delete-and-recreate, which needs a `delete_repo` token scope the `gh` CLI lacks), and **Gloom's Build Barn is currently undeliverable to the guild** — WoWup reads GitHub Releases through the API and a private repo 404s, so GBB has served nobody since it went private on 2026-07-24. GBB is scrubbed and its zips verified clean, so it is safe to re-publish the moment the owner says so. |

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
- **One profile/preset mechanism for the whole suite (the owner, 2026-07-24).** "For this mechanism
  (selecting a profile/preset, creating a new one, copying, renaming, deleting) they should all
  be using the same thing." That thing is `UI.profileBlock` in LibGloomSkin (MINOR 3); GB, GA and
  Overlays all drive it. **GB is the reference for suite UI, not GA** — GA's is the one with
  known issues (see the polish backlog).
- **No self-arming "click twice" confirms (the owner, 2026-07-24).** GB's Delete used to flip to
  "Sure?" with no way to cancel short of closing the addon. Destructive actions use the shared
  `UI.confirm` modal, which has a Cancel and an ESC.

## What's physically in place right now
- `~/GloomsHub` git repo, symlinked into AddOns as `GloomsHub` (matches GB/GA convention).
- `Core.lua` (namespace, `GloomsHubDB`, ST copy-migration, dormant compat shim, `/gh` probe),
  `Skin.lua` (**now the body of `LibGloomSkin-1.0`** — LibStub-registered, **MINOR 3**; tokens +
  toolkit + `WarmFonts`/`RegisterWarmPairs`; `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are aliases.
  MINOR 3 (Phase E gate B) added `UI.dropdown` + `UI.flyout` (promoted from GB's private
  `animDropdown`), `UI.nameDialog` + `UI.confirm` (the modals GB and GA each hand-maintained a
  near-identical copy of), and `UI.profileBlock` — **the suite's ONE profile/preset control**.
  Base warm list grew by `title 17` + `head 12`, which the lib's own widgets draw),
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
  **Phase E gate B (QA'd 2026-07-24):** GB's private name dialog, `animDropdown`/`animFlyout` and
  the two-click `confirmable` are DELETED. Its rail PROFILE + PRESET blocks are now the shared
  `UI.profileBlock` (delete goes through the confirm modal, so the old un-cancellable "Sure?"
  is gone); `animDropdown` survives as a one-line alias of `UI.dropdown` for its four other
  call sites; the Preset flyout's bar-ping now observes `UI.flyout()` (via `:IsVisible()`).
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
  **Phase E gate B (QA'd 2026-07-24):** GA's private name dialog + confirm modal are DELETED
  (`OpenNameDialog` = `UI.nameDialog`; `C:OpenConfirm` wraps `UI.confirm`), and the Profiles
  drawer now hosts the shared `UI.profileBlock` instead of its own click-a-row list + four
  buttons. The drawer stays as the host — see the polish backlog.
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
  **Gate B (QA'd 2026-07-24):** `_Editor.lua` is a full rewrite — the `overlays` tab (rail +
  editor + in-tab footer) built entirely on LibGloomSkin; `_Preview.lua` is the asset-browser
  DRAWER; `GloomsOverlays.lua` owns the one slash router. The two floating windows and every
  native template are gone. `_Preview.lua` also gained a Suite-media branch in its preview
  lookup, so a Hub media name previews the same art the live overlay resolves.
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
gate A: **`/go`, and `/vibe` is retired outright**, the owner 2026-07-24. ~~Overlays logo placement~~
— CLOSED Phase E gate B: a small GO mark + wordmark at the top of the tab's left rail, NOT a
splash. ~~Overlays profile picker~~ — CLOSED: the shared `UI.profileBlock`.)

## Suite polish backlog (post-migration UI work, gathered during QA)
- **Auras tab landing page (the owner, Phase D QA 2026-07-24):** the old standalone window's
  splash/landing (big GA logo + "Add … Aura" buttons on every open) "doesn't really make
  sense in the context of the suite." Works as before for now — rethink after the
  migrations (e.g. open straight to the editor with a compact create row, logo retired or
  moved). GA-side change; coordinate the design with the family language here.
- **★ The Auras tab needs a LAYOUT REWORK, not a tweak (the owner, Phase E gate B QA 2026-07-24):
  "we've got to get rid of the drawer, but the whole layout of this module is now very wrong."**
  Deferred to its own session by his call. Scope so far: kill the docked profile drawer in favour
  of a GB-style always-visible rail (gate B put the shared `UI.profileBlock` inside the existing
  drawer, so the mechanism matches GB/Overlays but is still hidden behind a footer button); the
  landing page above; and a general pass against GB's layout language now that GB is the
  reference. Treat the whole Auras tab as the unit of work — these all redraw the same surface.
- **Overlays: Width / Height / X / Y should be SLIDERS, not typed boxes (the owner, Phase E gate B
  QA 2026-07-24).** "It just needs to happen." They're `flatEditBox` today; the family answer is
  `UI.sliderRow` (as Rotation and Alpha already use), probably slider + typed value box like
  GA's numeric row so exact numbers stay enterable. Nudge arrows stay either way.
- **★ GB is the UI reference for the suite, not GA (the owner, 2026-07-24).** When a pattern
  exists in both, copy Gloom's Bars. The two backlog items above are why.

## How to keep this honest
Any session that edits GB/GA/Overlays/Hub **for suite reasons** updates the relevant phase row
here before finishing. A phase is "DONE" only when its SUITE-PLAN QA gate has been met by the owner;
mark "in progress" until then.
