# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-25e — **the AURAS TAB LAYOUT REWORK (to-do item 1) is DONE and QA'd**;
see the to-do list below. Before that: **★★ PHASE G IS DONE AND THE 7-PHASE PLAN IS COMPLETE.** The owner
QA'd the WoWup install AND update paths on 2026-07-25; all four addons now publish **`v1.0.1`**.
No phase work remains — everything left is the polish backlog below.
**★ THE FOUR SUITE REPOS ALSO MOVED TO A NEW GITHUB ORG, `GloomSuite`.**
`GloomsBuildBarn` + the guild website stayed with `HandofDevastation`. Install URLs are now
`https://github.com/GloomSuite/<Repo>`; old URLs 301-redirect but should not be quoted anywhere.
Membership is PRIVATE on both orgs (verified unauthenticated). Full record + the "second org, never
a rename" reasoning in HANDOFF's session record.

**Also 2026-07-25 (records 25c/25d):** the **new 512×512 square logo set** landed across all four
addons (GS = the suite, **Gh = the Hub as an addon**); **`UI.tabHeader` promoted into LibGloomSkin
as MINOR 4** and adopted by Bars, Overlays and Media (**and by GA on 2026-07-25**, in the layout
rework it was held back for — all four tabs now carry a header); the **shell footer now lists every installed addon's version**; the **Media tab shows
per-category counts** on collapsed headers; and the **version GATE** was added to every LibGloomSkin
consumer, which is what makes independent versioning safe.

Earlier context: Phases **A–F** were built + QA'd on 2026-07-24 — StoneTweaks is RETIRED and the
identity scrub (TASK 0) is DONE with all five repos PUBLIC. **Phase G** was built 2026-07-24 and
QA'd 2026-07-25. 2026-07-25 also swept GB's and GA's docs for release facts the release had
falsified, and added the **route-the-request rule** to all four `CLAUDE.md` files.

## ▶ THE TO-DO LIST (single answer to "what's left?")

**★★ THE 7-PHASE PLAN IS COMPLETE (Phase G QA'd 2026-07-25). No phase work remains.**
Everything below is polish. ✅ items are done and kept for the record.

**Each its own session, in the repo that owns it — route it there**
(item 1 is done; 2 and 3 remain)
1. ~~**Auras tab LAYOUT REWORK** · `~/GloomsAuras`~~ — **✅ DONE, QA'd by the owner 2026-07-25.**
   Shipped in six owner-verified steps: splash retired · the editor's aura-name banner replaced by a
   rail Rename (+ double-click) through `UI.nameDialog` · buttons restyled to the suite's language ·
   a flush-left 240 rail carrying `UI.tabHeader` + the shared `UI.profileBlock` + the aura tree ·
   **groups made a first-class selection** (clicking a group's name fills the editor pane with its
   settings, retiring the ⚙ gear, the Manage Group drawer and the confusing green "Group:" button) ·
   the editor sections re-laid for the full-width pane · and the Trigger section rebuilt to the
   owner's mock as a bracketed tree. **GA's gate is now MINOR 4** (CONTRACTS §6) — no tab is without
   a header any more. **Four drawers were deleted** (Manage Group, Visibility, Text, Glow), leaving
   only the transient pickers. Two defects were caught by the owner along the way and fixed:
   **Delete Aura had no confirmation** (CONTRACTS §4 — it now uses the shared modal, as does every
   other delete in the tab), and the eye icons didn't reflect that a SELECTED aura is already drawn.
   ★ **A trap worth carrying suite-wide:** deleting a block orphaned a module-local that another
   function still called, which became a nil global — `luac -p` does NOT catch that, and because the
   shell builds a tab before showing it, the whole tab came up blank rather than just the broken
   section. Diff the file's global reads against a known-good revision after any block deletion:
   `luac -l F.lua | grep -oE '_ENV "[A-Za-z_][A-Za-z0-9_]*"' | sort -u`.
2. **Overlays: Width / Height / X / Y → SLIDERS** · `~/GloomsOverlays` — "It just needs to happen."
   `UI.sliderRow` as Rotation/Alpha already use, probably slider + typed box so exact values stay
   enterable. Nudge arrows stay.
3. **Modifier symbols (⌘⇧⌃⌥) take no outline/shadow** · `~/GloomsBars` — deferred but wanted; the
   approved path is in GB's handoff item (d). **No open GB bugs.**

**Small / housekeeping**
4. Remove the leftover **`test-remove`** graphic from the Media catalog (inherited from StoneTweaks;
   removable in the Media tab — an in-game action, no code).
5. Open question: the stray **`BoordensStreet.otf`** — keep or drop?
6. **Before sharing widely:** the public repo PAGES expose `CLAUDE.md` + `docs/` to anyone with the
   link. Excluded from the packaged zips and identity-clean, so not a privacy defect — just working
   notes being visible. The owner's call, flagged 2026-07-25.
7. ~~**Unverified:** do TEXTURE files need a client restart the way new FONTS do?~~ — **ANSWERED
   2026-07-25, in the owner's client: `/reload` IS ENOUGH. The Media tab's Textures note is
   CORRECT — leave it.** Evidence: he re-exported `GloomsAuras/Media/hidden.png` +
   `unhidden.png` from purple to white **over the existing files**, and after a bare `/reload`
   the new art rendered and tinted correctly. That is the *harder* case than a brand-new file —
   the client already had those textures loaded, and it still picked up the replacements — so
   textures are genuinely unlike FONTS, which WoW loads at launch and `/reload` will not
   re-read (HANDOFF 2026-07-25d). Strictly, "a NEW texture file, never previously loaded" is
   still untested, but a cache-busting replacement working makes it a safe assumption.

**✅ Done 2026-07-25 (kept for the record)**
- ~~Phase G QA — WoWup install + update cycle~~ — **DONE**, the plan is complete.
- ~~Redo all four logos, drop the baked-in name text~~ — **DONE.** 512×512 square set; every
  hardcoded portrait draw size moved with it. **GS = the suite, Gh = the Hub as an addon.**
- ~~Small mark beside every tab name~~ — **DONE as `UI.tabHeader` (LibGloomSkin MINOR 4)**, on ALL
  FOUR tabs. Bars, Overlays and Media took it 2026-07-25; **GA followed the same day** once its
  layout rework retired the splash that occupied the space (item 1).
- ~~Overlays has no `## IconTexture`~~ — **DONE.** No more `?` in the addon list.
- ~~Hub's `minimap.png` is only 64×64~~ — **DONE**, now 512.
- ~~Org avatar for `GloomSuite`~~ — **DONE**, the owner uploaded the GS mark.
- ~~Media tab: category counts on collapsed headers~~ — **DONE.**
- ~~Footer shows every addon's version~~ — **DONE**, which also closes the long-open
  **"shared-footer contents"** question.

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
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | **DONE — QA'd by the owner 2026-07-24** ("works as it did before"). Shipped: GA hard-deps the Hub; local toolkit copy + standalone window DELETED; options UI mounts as the **Auras** tab (centered 620-wide column; docked drawers parent to the container); `/ga` → `ToggleWindow("auras")`; `/ga minimap` drives the Hub's button; GA's minimap button DELETED; `CatStoneTweaks` → `GloomsHub:ListMedia` ("Suite Graphics" — GA reads NO StoneTweaks data anymore). Shell grew to 860×740 (content 860×626 PINNED, CONTRACTS §2); lib at MINOR 2. Noted for polish at the time: the Auras landing page — **since resolved: the whole tab was reworked 2026-07-25 (to-do item 1), retiring the landing page, the centred 620 column and four drawers.** |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | **DONE — QA'd by the owner 2026-07-24. Split into two QA gates** (the handoff's own "QA the migration FIRST" instruction, so a reskin bug can never be mistaken for data loss). **Gate A DONE — QA'd by the owner 2026-07-24**: clean BugSack; addon list shows "Gloom's Overlays", VibeOverlay gone; overlays render identically; `/go list` correct; **Goldset renders on Gloomthorn** (the per-character proof); `/go overlays` + `/go preview` work (still native chrome); `/vibe` retired. **DONE — gate B QA'd by the owner 2026-07-24** (22 steps, all passed, incl. a cold client restart on Gloomthorn/`Goldset` and the GB + GA regression checks). Shipped: the `overlays` tab (order 30) laid out like GB's — a 240 left rail (GO mark + wordmark · the shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, with an in-tab footer (Save & Apply + status); ALL native chrome deleted (no `BackdropTemplate`, `UIDropDownMenu`, `StaticPopupDialogs`, `UIPanel*Template`, and the `MakeButton`/`MakeCheck`/`MakeEditBox`/`MakeSlider`/`SectionLabel` locals are gone); the asset browser is a 360-wide docked drawer opened from the Texture field's **Browse…** (returns the pick via "Use This Texture"); bare `/go` toggles the tab and the old `PLAYER_LOGIN` slash-wrapping in `_Preview.lua` is gone (one router in `GloomsOverlays.lua`); warm pairs registered. **Also, per the owner 2026-07-24 — the profile/preset mechanism is now ONE shared control across the suite** (see the lib row below). |
| **F** | Retire StoneTweaks (delete last, non-destructively). | **DONE — QA'd by the owner 2026-07-24** (all 6 steps; final restart confirmed "all is well" — Stone Tweaks gone from the addon list entirely, Hub registration line unchanged, no BugSack errors). ST is **disabled AND its folder is out of AddOns** (moved, not deleted, to `~/Desktop/StoneTweaks-retired-2026-07-24` — 73 files, count-verified). **`StoneTweaksDB` in WTF was deliberately left in place, so rollback is still just moving the folder back and re-enabling.** Owner-verified after a full client restart with ST off: no `StoneTweaks:` login lines and no `/st` command (ST's own code never loaded — the positive proof, not mere silence); `Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.` unchanged; **zero Hub-prefixed "skipped" lines, so the Hub won all 7 LSM names with no third-party collision** (`EnhanceQoLSharedMedia` + `EllesmereUI` are installed and don't clash); `/gh` → 1 font / 6 textures / 36 graphics, `migratedFromST = true`; BugSack clean. **The compat shim is LIVE and proven** — `StoneTweaks_ResolveAssetPath("goldset-player-frame")` now returns the *Hub* path via Core.lua's shim. Both resolver branches (textures + graphics) resolve, DrukMedium serves from `GloomsHub\Fonts\`, **Goldset overlays render on Gloomthorn**, all four tabs open, and the Media tab previews draw. Step 1's offline sweep found: no consumer reads ST anywhere in the four repos **or the whole 105-addon client**; `GloomsHubDB` and `StoneTweaksDB` catalogs were **identical** (ST added nothing post-Phase A); all 43 catalog files exist under the Hub and the three asset folders were the **same file sets**; ST's ElvUI half was provably unused (`frameTextures` empty, `suppressGlow` false). Verified offline, nothing left to migrate: (a) **no consumer anywhere reads ST** — all four suite repos and the whole live AddOns folder grep clean for `StoneTweaks_ResolveAssetPath` / `StoneTweaksDB` / `CatStoneTweaks`; the only live-code hits are the Hub's deliberate compat shim + copy-migration in `Core.lua` (everything else is prose/comments). (b) **`GloomsHubDB` and `StoneTweaksDB` catalogs are IDENTICAL** — 1 font / 6 textures / 36 graphics, same name→file pairs, so ST registered nothing new after Phase A. (c) **All 43 catalog files exist under the Hub**, and `Fonts/`, `Textures/`, `Graphics/` are **byte-for-byte the same file sets** in both addons — retiring ST loses no asset. (d) ST's ElvUI half is provably unused (`frameTextures` empty, `suppressGlow` false), so nothing dies with it. |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, WoWup. | **✅ DONE — QA'd by the owner 2026-07-25.** The install AND update paths are both proven end-to-end from the new `GloomSuite` org, against a client with the dev symlinks moved aside. **Install:** all four installed via WoWup "Install from URL"; addon list showed every addon with **no missing-dependency flag**; TOC versions read **`v1.0.0`**, not `@project-version@` (the proof the client was loading the packaged copy, not a symlink); BugSack clean; `/gloom` opened the Suite window; **all four tabs registered and rendered**; Media catalog still **1 font / 6 textures / 36 graphics**; **Goldset overlays rendered on Gloomthorn**; WoWup's Author column read **`GloomSuite`** on all four and `HandofDevastation` on Build Barn. ★ **`LibStub("LibCustomGlow-1.0", true) ~= nil` → `true`** — GA's repointed external is proven AT RUNTIME, which mattered because GA loads it silently and `pcall`-guards every glow call, so a missing library would have produced no glow and **no BugSack error**: a clean sack would have read as a pass. **Update:** `v1.0.1` tagged on GloomsBars → packager → GitHub release → WoWup detected and applied it → client showed `v1.0.1`; then the other three were tagged and all four brought back to `v1.0.1`, with `/releases/latest` verified **ANONYMOUSLY** on every repo (the TASK 0 latest-pointer trap did not recur). ★ **A WoWup update needs no full client restart — `/reload` is enough** (the owner, 2026-07-25). This held for `v1.0.0` → `v1.0.1`, and he confirmed it generally: he installs new addons via WoWup and `/reload`s. **The old "new files → FULL RESTART" rule is RETIRED.** **BUILT 2026-07-24 — the build record follows.** **All four addons now publish `v1.0.0`** and every package was verified after the fact. Shipped: `GloomsHub/.pkgmeta` + `release.yml` (the blocker — the Hub previously had neither and so could not publish at all); `GloomsOverlays/.pkgmeta` + `release.yml`; `GloomsAuras/release.yml` (GA had a `.pkgmeta` but nothing to run it). All four workflow runs succeeded first try. **Verified on the published assets:** the Hub zip carries Fonts 8 / Textures 13 / Graphics 45 / Media 8 with all five libs fetched and no docs/CLAUDE.md/.github; GA's zip fetched `LibCustomGlow-1.0`; Overlays ships **no `Libs/` at all** (correct — it loads none and takes everything from the Hub); every TOC has `## Version: v1.0.0` substituted and the three tools all declare `## Dependencies: GloomsHub`; **`/releases/latest` resolves to `v1.0.0` on all four checked ANONYMOUSLY** (the TASK 0 trap — it did not recur); zero identity in any of the four packages. ★ **Two real defects were caught by doing this, both now fixed:** (1) **the published `GloomsBars` v0.2.0 was NOT merely "broken for a missing dep" as the Phase F handoff claimed — it was tagged at a 2026-07-18 commit, PRE-Phase-C, shipping only `Core.lua` + `Skin.lua` with no config UI and NO `## Dependencies: GloomsHub` line at all.** It was stale by three phases, not dependency-broken; the v1.0.0 re-cut is what actually fixes it. (2) **GA's `LibCustomGlow-1.0` external was dead** — the wowace SVN path `wow/libcustomglow-1-0/trunk` 404s (the other five externals all resolve), so GA's very first packaged build would have failed. Repointed at the maintained upstream `Stanzilla/LibCustomGlow`, whose repo root holds exactly what `Libs/LibCustomGlow-1.0` holds locally; the fetch is confirmed working in the shipped zip. Also tightened GA's `ignore:` (CLAUDE.md + docs were being packaged into its zip). **Version scheme (the owner, 2026-07-24): all four at `v1.0.0`, synchronized** — the suite is feature-complete, and a friends/guild audience should have one answer to "what version are you on?" GB jumped `v0.2.0` → `v1.0.0`. Install instructions for the non-dev audience are in [../README.md](../README.md) (Phase G item 5). ★★ **SUITE-PLAN's "embed LibGloomSkin as an external per tool" was DROPPED** (struck out in the plan itself, 2026-07-24). No tool ships or loads its own copy; all three just call `LibStub("LibGloomSkin-1.0")` and resolve to the Hub's `Skin.lua`. The hard-dependency lock guarantees the Hub is present, so embedding would create N copies for LibStub to arbitrate — precisely the drift the suite exists to prevent — and there is no standalone repo to fetch as an external anyway. Its **prior** blocking prerequisite, the identity scrub, is ✅ **DONE (2026-07-24)** and **all five repos are PUBLIC again, so WoWup delivery is restored.** History was rewritten with `git-filter-repo` across all five (content + commit messages + author/committer metadata). `GloomsBars`, `GloomsAuras` and `GloomsBuildBarn` were then **DELETED AND RECREATED** — see the lesson below — while `GloomsHub` and `GloomsOverlays` were newly created that day and only ever received scrubbed history. Verified **unauthenticated against the public repos**: pre-rewrite SHAs return 422, current commits 200, and zero identity in commit metadata, messages, all-history blobs or release ZIPs. Org membership is still private; releases are authored by `github-actions[bot]`. ★★★ **THE LESSON: a force-push does NOT purge — it only unlinks.** Old commits stayed on GitHub and were served the instant the repos went public (~2 min exposure before revert). **A 404 while a repo is private proves nothing** — that endpoint 404s for any SHA. Only delete-and-recreate purges. Two further traps, both in HANDOFF.md: (1) **published release ZIPs are a separate surface a force-push cannot reach** — GB's assets carried the name and were rebuilt by re-pushing tags; (2) **Build Barn's remote was AHEAD of its local clone** (its cron writes commits and tags directly on GitHub), so an early push rolled its `main` back a fortnight before recovery from the surviving tags — nothing lost, `BuildData.lua` verified byte-identical. |

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
- **★ VERSIONS MAY DRIFT — release only the addon that changed (the owner, 2026-07-25).** This
  RELAXES the 2026-07-24 "all four synchronized" scheme. His words: *"it doesn't bother me if the
  versions of the individual units drift."* Synchronized versioning existed so a friends/guild
  audience had one answer to "what version are you on?"; that reason is being retired by the footer
  work (to-do 12), and tagging four repos every time one changes is real friction.
  **★ This was only made SAFE by the version gate — see the next entry. Do not relax the scheme in
  a repo whose gate is missing.**
- **★ EVERY LibGloomSkin CONSUMER CARRIES A VERSION GATE (built + QA'd 2026-07-25).** Pinned in
  **[CONTRACTS.md](CONTRACTS.md) §6**. The owner asked whether version drift was "a problem I'm not
  aware of" — it was, and it was **live**: all three tools did a bare
  `LibStub("LibGloomSkin-1.0")` with **no version check at all**, while
  `## Dependencies: GloomsHub` checks only that the Hub is PRESENT, never that it is NEW ENOUGH
  (WoW's TOC system has no version constraint). A tool released ahead of the Hub would have called a
  `nil` widget and sprayed Lua errors. Each consumer now declares `SKIN_NEEDS` and returns early
  with ONE actionable chat line if the Hub is too old.
  **★ BUMP `SKIN_NEEDS` IN THE SAME COMMIT that first calls a newer widget** — forgetting that is
  the only way to defeat the gate.
  **QA'd by forcing GB's gate to require v99 (2026-07-25):** the message printed verbatim, the BARS
  tab vanished from the shell, **`Gloom's Bars: skin ON — 116 buttons styled.` still printed in the
  same session** (the engine is deliberately NOT gated — the user loses configuration, never
  function), and BugSack stayed completely clean.

## What's physically in place right now
- `~/GloomsHub` git repo, symlinked into AddOns as `GloomsHub` (matches GB/GA convention).
- `Core.lua` (namespace, `GloomsHubDB`, ST copy-migration, dormant compat shim, `/gh` probe),
  `Skin.lua` (**now the body of `LibGloomSkin-1.0`** — LibStub-registered, **MINOR 4**; tokens +
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
> **The first two Auras entries below are CLOSED by the 2026-07-25 layout rework** (to-do item 1).
> Kept for the reasoning that drove them.
- **Auras tab landing page (the owner, Phase D QA 2026-07-24):** ✅ **DONE — the splash is retired.** the old standalone window's
  splash/landing (big GA logo + "Add … Aura" buttons on every open) "doesn't really make
  sense in the context of the suite." Works as before for now — rethink after the
  migrations (e.g. open straight to the editor with a compact create row, logo retired or
  moved). GA-side change; coordinate the design with the family language here.
- ✅ **DONE 2026-07-25.** **The Auras tab needed a LAYOUT REWORK, not a tweak (the owner, Phase E gate B QA 2026-07-24):
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
