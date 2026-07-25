# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-25b — **★ THE FOUR SUITE REPOS MOVED TO A NEW GITHUB ORG, `GloomSuite`.**
`GloomsBuildBarn` + the guild website stayed with `HandofDevastation`. Install URLs are now
`https://github.com/GloomSuite/<Repo>`; old URLs 301-redirect but should not be quoted anywhere.
Membership is PRIVATE on both orgs (verified unauthenticated). Full record + the "second org, never
a rename" reasoning in HANDOFF's session record. (**Phase G BUILT — all four addons now publish `v1.0.0` on GitHub
Releases and the packages are verified. The 7-phase plan is code-complete; only the owner's
fresh-WoWup-install QA remains.** Phases A–F were built + QA'd on 2026-07-24 —
StoneTweaks is RETIRED and the identity scrub, TASK 0, is DONE with all five repos PUBLIC.
2026-07-25 also swept GB's and GA's docs for release facts the release had falsified, and added
the **route-the-request rule** to all four `CLAUDE.md` files — see HANDOFF's session record.)

## ▶ THE TO-DO LIST (single answer to "what's left?")

**The one open phase item**
1. **Phase G QA — fresh WoWup install** of GloomsHub + one tool, full client restart, verify; then
   an update cycle. Script in HANDOFF. ⚠ **Blocked on a hazard, not effort: all four AddOns entries
   are symlinks into the dev repos**, so an install on this machine overwrites live source. Move the
   symlinks aside (restore after) or use a second machine. **Then mark Phase G DONE.**

**Polish backlog — each its own session, by the owner's call (detail at the bottom of this file)**
2. **Auras tab LAYOUT REWORK** — kill the docked drawer for a GB-style always-visible rail, plus the
   landing-page question. Treat the whole Auras tab as the unit of work.
3. **Overlays: Width / Height / X / Y → SLIDERS**, not typed boxes. "It just needs to happen."

**Gloom's Bars (GB repo — route it there)**
4. **Modifier symbols (⌘⇧⌃⌥) take no outline/shadow** — deferred, but the owner wants it; the approved
   path is in GB's handoff item (d). **No open GB bugs.**

**★ LOGO / MARK REWORK (the owner, 2026-07-25) — new**
5. **Redo all four logos to drop the baked-in name text.** Today each `logo.png` is the big stylized
   two letters with the addon name in a small font underneath — which is why the files are portrait
   (`GloomsHub` 197×295, `GloomsOverlays` 179×247, `GloomsBars` 115×128) rather than square. At the
   size a tab-header mark is drawn, that text is a few pixels tall and **reads as an artifact, not
   as type**. Settle on the **two-letter monogram convention** everywhere; the art then becomes
   square, which is also the right shape for the in-tab mark. **Each tool's logo lives in ITS repo —
   route accordingly.** Hub's is here.
6. **Apply "small mark beside the tab name" to ALL tabs** — the owner saw it on one addon page, likes
   it, and wants it as the suite pattern. Shared-toolkit change here + one call site per tool; a good
   single cross-cutting pass **once the new art exists**. Don't start before item 5.
7. **`GloomsOverlays` has NO `## IconTexture`** in its TOC, so it shows a generic default in the
   in-game addon list while its three siblings show their marks. It already has `Media/ui/logo.png`.
   **GO's repo — route it there.**
8. **The Hub's `Media/ui/minimap.png` is only 64×64** where GB's and GA's are 256×256. It doubles as
   the TOC `IconTexture`; regenerate at 256 while the art is being redone.
9. **Org avatar for `GloomSuite`** — the ONLY way to change what WoWup shows at install (its GitHub
   provider hardcodes `owner.avatar_url`; it never reads the addon TOC or zip). 1000×1000 PNG,
   **solid background — NOT transparent** (GitHub renders avatars on white in light theme, so a
   transparent near-black mark disappears), a little padding for the rounded corners, must read at
   48px. Suite colors: background **`#060714`**, bottom glow **`#ff7729` @ 11% alpha** fading out by
   ~55% height (≈ `#211316` at the very bottom edge).
   ⚠ **`COLOR.dark` in Skin.lua is `#12131F`, NOT the on-screen color** — it is pre-compensated
   because WoW darkens it. Artwork must use **`#060714`**, what actually lands on screen.

**Small / housekeeping**
10. **Media tab: show each category's asset count on the COLLAPSED accordion header** (the owner,
   2026-07-25 during Phase G QA) — "would be nice to show how many assets are in each of those
   fonts/textures/graphics categories without having to expand the section." Today the counts are
   only visible once a section is open. Hub work (`Media.lua`). Small, self-contained.
11. Remove the leftover **`test-remove`** graphic from the Media catalog (inherited from StoneTweaks;
   removable in the Media tab).
12. Open questions below: **shared-footer contents**; the stray **`BoordensStreet.otf`**.
13. **Before sharing widely:** the public repo PAGES expose `CLAUDE.md` + `docs/` to anyone with the
   link. Excluded from the packaged zips and identity-clean, so not a privacy defect — just working
   notes being visible. The owner's call, flagged 2026-07-25.

**Not a task — context:** the owner considers the suite **still in active development and is NOT
ready to share it with friends/guildies yet** (2026-07-25). Don't push distribution work.
When he is ready, it's **four links, Hub first**, and **no access token** — see HANDOFF.
Phase E gate B also promoted the whole profile/preset
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
| **F** | Retire StoneTweaks (delete last, non-destructively). | **DONE — QA'd by the owner 2026-07-24** (all 6 steps; final restart confirmed "all is well" — Stone Tweaks gone from the addon list entirely, Hub registration line unchanged, no BugSack errors). ST is **disabled AND its folder is out of AddOns** (moved, not deleted, to `~/Desktop/StoneTweaks-retired-2026-07-24` — 73 files, count-verified). **`StoneTweaksDB` in WTF was deliberately left in place, so rollback is still just moving the folder back and re-enabling.** Owner-verified after a full client restart with ST off: no `StoneTweaks:` login lines and no `/st` command (ST's own code never loaded — the positive proof, not mere silence); `Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.` unchanged; **zero Hub-prefixed "skipped" lines, so the Hub won all 7 LSM names with no third-party collision** (`EnhanceQoLSharedMedia` + `EllesmereUI` are installed and don't clash); `/gh` → 1 font / 6 textures / 36 graphics, `migratedFromST = true`; BugSack clean. **The compat shim is LIVE and proven** — `StoneTweaks_ResolveAssetPath("goldset-player-frame")` now returns the *Hub* path via Core.lua's shim. Both resolver branches (textures + graphics) resolve, DrukMedium serves from `GloomsHub\Fonts\`, **Goldset overlays render on Gloomthorn**, all four tabs open, and the Media tab previews draw. Step 1's offline sweep found: no consumer reads ST anywhere in the four repos **or the whole 105-addon client**; `GloomsHubDB` and `StoneTweaksDB` catalogs were **identical** (ST added nothing post-Phase A); all 43 catalog files exist under the Hub and the three asset folders were the **same file sets**; ST's ElvUI half was provably unused (`frameTextures` empty, `suppressGlow` false). Verified offline, nothing left to migrate: (a) **no consumer anywhere reads ST** — all four suite repos and the whole live AddOns folder grep clean for `StoneTweaks_ResolveAssetPath` / `StoneTweaksDB` / `CatStoneTweaks`; the only live-code hits are the Hub's deliberate compat shim + copy-migration in `Core.lua` (everything else is prose/comments). (b) **`GloomsHubDB` and `StoneTweaksDB` catalogs are IDENTICAL** — 1 font / 6 textures / 36 graphics, same name→file pairs, so ST registered nothing new after Phase A. (c) **All 43 catalog files exist under the Hub**, and `Fonts/`, `Textures/`, `Graphics/` are **byte-for-byte the same file sets** in both addons — retiring ST loses no asset. (d) ST's ElvUI half is provably unused (`frameTextures` empty, `suppressGlow` false), so nothing dies with it. |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, WoWup. | **BUILT 2026-07-24 — awaiting the owner's WoWup install QA.** **All four addons now publish `v1.0.0`** and every package was verified after the fact. Shipped: `GloomsHub/.pkgmeta` + `release.yml` (the blocker — the Hub previously had neither and so could not publish at all); `GloomsOverlays/.pkgmeta` + `release.yml`; `GloomsAuras/release.yml` (GA had a `.pkgmeta` but nothing to run it). All four workflow runs succeeded first try. **Verified on the published assets:** the Hub zip carries Fonts 8 / Textures 13 / Graphics 45 / Media 8 with all five libs fetched and no docs/CLAUDE.md/.github; GA's zip fetched `LibCustomGlow-1.0`; Overlays ships **no `Libs/` at all** (correct — it loads none and takes everything from the Hub); every TOC has `## Version: v1.0.0` substituted and the three tools all declare `## Dependencies: GloomsHub`; **`/releases/latest` resolves to `v1.0.0` on all four checked ANONYMOUSLY** (the TASK 0 trap — it did not recur); zero identity in any of the four packages. ★ **Two real defects were caught by doing this, both now fixed:** (1) **the published `GloomsBars` v0.2.0 was NOT merely "broken for a missing dep" as the Phase F handoff claimed — it was tagged at a 2026-07-18 commit, PRE-Phase-C, shipping only `Core.lua` + `Skin.lua` with no config UI and NO `## Dependencies: GloomsHub` line at all.** It was stale by three phases, not dependency-broken; the v1.0.0 re-cut is what actually fixes it. (2) **GA's `LibCustomGlow-1.0` external was dead** — the wowace SVN path `wow/libcustomglow-1-0/trunk` 404s (the other five externals all resolve), so GA's very first packaged build would have failed. Repointed at the maintained upstream `Stanzilla/LibCustomGlow`, whose repo root holds exactly what `Libs/LibCustomGlow-1.0` holds locally; the fetch is confirmed working in the shipped zip. Also tightened GA's `ignore:` (CLAUDE.md + docs were being packaged into its zip). **Version scheme (the owner, 2026-07-24): all four at `v1.0.0`, synchronized** — the suite is feature-complete, and a friends/guild audience should have one answer to "what version are you on?" GB jumped `v0.2.0` → `v1.0.0`. Install instructions for the non-dev audience are in [../README.md](../README.md) (Phase G item 5). ★★ **SUITE-PLAN's "embed LibGloomSkin as an external per tool" was DROPPED** (struck out in the plan itself, 2026-07-24). No tool ships or loads its own copy; all three just call `LibStub("LibGloomSkin-1.0")` and resolve to the Hub's `Skin.lua`. The hard-dependency lock guarantees the Hub is present, so embedding would create N copies for LibStub to arbitrate — precisely the drift the suite exists to prevent — and there is no standalone repo to fetch as an external anyway. Its **prior** blocking prerequisite, the identity scrub, is ✅ **DONE (2026-07-24)** and **all five repos are PUBLIC again, so WoWup delivery is restored.** History was rewritten with `git-filter-repo` across all five (content + commit messages + author/committer metadata). `GloomsBars`, `GloomsAuras` and `GloomsBuildBarn` were then **DELETED AND RECREATED** — see the lesson below — while `GloomsHub` and `GloomsOverlays` were newly created that day and only ever received scrubbed history. Verified **unauthenticated against the public repos**: pre-rewrite SHAs return 422, current commits 200, and zero identity in commit metadata, messages, all-history blobs or release ZIPs. Org membership is still private; releases are authored by `github-actions[bot]`. ★★★ **THE LESSON: a force-push does NOT purge — it only unlinks.** Old commits stayed on GitHub and were served the instant the repos went public (~2 min exposure before revert). **A 404 while a repo is private proves nothing** — that endpoint 404s for any SHA. Only delete-and-recreate purges. Two further traps, both in HANDOFF.md: (1) **published release ZIPs are a separate surface a force-push cannot reach** — GB's assets carried the name and were rebuilt by re-pushing tags; (2) **Build Barn's remote was AHEAD of its local clone** (its cron writes commits and tags directly on GitHub), so an early push rolled its `main` back a fortnight before recovery from the surviving tags — nothing lost, `BuildData.lua` verified byte-identical. |

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
  `migratedFromST = true`, plus `lastTab` + `minimap`; the Hub is the ONLY media registrar and wins
  all 7 LSM names with no collision; **the compat shim is LIVE** (Phase F).
- **StoneTweaks is retired (Phase F, 2026-07-24):** disabled AND its folder moved out of AddOns to
  `~/Desktop/StoneTweaks-retired-2026-07-24` (73 files, count-verified). **`StoneTweaksDB` was
  deliberately left in WTF**, so rollback = move the folder back + re-enable. Its `Fonts/`,
  `Textures/` and `Graphics/` were verified to be the same file sets the Hub already carries.
- ⚠ **`~/Desktop/VibeOverlay-retired-2026-07-24` — KEEP (the owner, 2026-07-24).** It is the ONLY
  copy of the pre-rename VibeOverlay source: GloomsOverlays' *first* commit already contains the
  renamed files and no `Vibe`-named file exists anywhere in that repo's history. Not cleanup debt.
  Both retired folders were identity-scanned and are clean, so TASK 0's "no copy of the old identity
  remains on disk" still holds.
- ⚠ The Media catalog carries a leftover `test-remove` / `test-remove.png` graphic, inherited from
  StoneTweaks (it was in `StoneTweaksDB` too), not from Phase B QA. Harmless; removable in the Media tab.
- GB & GA `CLAUDE.md` carry a "part of the Gloom Suite → GloomsHub" pointer.

## Open (non-blocking) questions — see SUITE-PLAN §6
Shared-footer contents; stray `BoordensStreet.otf` fate; where the
Overlays GO logo belongs inside the tab (NOT a splash — see the polish backlog).
(~~compat-shim lifetime~~ — CLOSED Phase F step 6: **KEEP PERMANENTLY**, the owner 2026-07-24.
Pinned in CONTRACTS §3 + commented in Core.lua. Do not "clean up" the shim.)
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
