# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phase A is **DONE and QA'd** — the Hub's media plumbing is live
in-game. **Next: build Phase B — the empty tabbed shell + the Media tab.** This file is a
COLD-START briefing — a session that never saw the earlier conversations should be able to
execute Phase B from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — the phase ledger + all locked decisions. Source of truth
   for "where are we." **Update it when Phase B completes.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — full architecture + all 7 phases. For Phase B read
   §3 (the tabbed shell), §4.1 (the Media tab), §5.B (scope + QA).
4. [CONTRACTS.md](CONTRACTS.md) — the shared runtime shapes. §2 is the `RegisterTab` API the
   shell must implement exactly.

## What exists now (Phase A shipped 2026-07-24)
- `Core.lua` — `_G.GloomsHub` namespace, `GloomsHubDB` init at `PLAYER_LOGIN`, the one-time
  ST copy-migration (**already ran on the owner's account** — `migratedFromST = true`, so no
  migration prints will appear again), the dormant `StoneTweaks_ResolveAssetPath` compat shim,
  media registration fired at `PLAYER_ENTERING_WORLD`, and a `/gh` QA probe (catalog counts +
  migration flag).
- `Media.lua` — LSM registration (fonts → `"font"`, textures → `"statusbar"`, graphics
  deliberately NOT in LSM), `GloomsHub:ResolveAssetPath(name)`, `GloomsHub:ListMedia(kind)`,
  and `GloomsHub.Media:AddFont/RemoveFont/AddTexture/RemoveTexture/AddGraphic/RemoveGraphic`
  with ST's validation kept (`.otf` rejection, `.ttf/.blp/.tga/.png` gates, cross-catalog
  name-conflict checks).
- `Libs/` (gitignored, expected): LibStub, CallbackHandler-1.0, LibSharedMedia-3.0 — copied
  from `~/GloomsAuras/Libs/`.
- `Fonts/` (8 files), `Textures/` (13), `Graphics/` (45) — committed assets copied verbatim
  from StoneTweaks. Every file the DB references exists here (verified).
- **Live DB state:** `GloomsHubDB` = 1 font (DrukMedium) / 6 textures / 36 graphics.
- **Runtime fact:** the Hub loads before StoneTweaks (alphabetical), so the Hub now WINS the
  LSM name registrations. ST prints "skipped — already registered" lines at every login —
  expected, harmless, ST's own untouched code; gone at Phase F. Do NOT "fix" this.
- GB, GA, VibeOverlay, StoneTweaks: all still untouched, all still working.

## Locked decisions (do NOT reopen — full list in SUITE-STATE.md)
Base = GloomsHub (permanent path `Interface\AddOns\GloomsHub\…`). **Hard dependency, no
fallback.** StoneTweaks retired at Phase F (installed until then — do not remove). VibeOverlay
→ Gloom's Overlays (reskin, Phase E). Four addons + one base, not a mega-addon. **Gloom's
Build Barn is OUT** (cron/WCL pipeline). Never use "v1"/"later phase" framing. GUI over slash
for user controls.

---

## ▶▶ PHASE B — empty tabbed shell + Media tab. Still touch NOTHING but GloomsHub.

**Goal:** `/gloom` opens the one Suite window (product title "Gloom Suite") in the Gloom
design language, with a working **Media** tab — the reskinned Fonts/Textures/Graphics manager
reading `GloomsHubDB`. The old windows (`/gb`, `/ga`, `/vibe`, `/st`) are NOT rerouted and
must keep working exactly as before. **GB, GA, VibeOverlay, StoneTweaks are NOT edited in
Phase B** (GB is READ for reference only — see below).

### Build these under `~/GloomsHub/`
1. **`Shell.lua`** — the tabbed window, implementing CONTRACTS §2 exactly:
   `GloomsHub:RegisterTab{id,title,order,icon,build,refresh}`, `GloomsHub:Open(id)`,
   `GloomsHub:FocusTab(id)`. `build(container)` runs ONCE, lazily, on first show — never at
   login. Frame `GloomsSuiteWindow` on UIParent, registered into `UISpecialFrames` (Escape
   closes). Tab strip of flat buttons — purple `#936bff` unselected / orange active (family
   convention). Reserved tab ids: `auras`, `bars`, `overlays`, `media`.
2. **The Media tab** (in `Media.lua` or a separate file listed after `Shell.lua`) — register
   id `"media"`, order 90. Functional reference: `StoneTweaks_UI.lua`'s Fonts/Textures/
   Graphics sub-pages (list rows, add/remove, preview swatches) — read it, port the behavior,
   but build the UI in the Gloom language (SUITE-PLAN §4.1 recommends the `makeSection`
   accordion pattern). All mutations go through the existing `GloomsHub.Media` API.
3. **`/gloom`** — opens the window on the last-used tab (persist in `GloomsHubDB`). Toggle
   semantics per SUITE-PLAN §3.3: slash while open on that tab closes; on a different tab,
   switches. (`/gh` probe can stay as-is.)
4. **TOC** — add the new file(s) after `Media.lua` (or per §2.2's Core → Skin → Shell → Media
   order if a `Skin.lua` is introduced — see next point).

### Design-token sourcing (decide at build time; recommendation below)
The shell + Media tab need `COLOR`/`FONT` tokens and a few widgets BEFORE Phase C extracts
the full `LibGloomSkin` from GB. The authoritative literals live in `~/GloomsBars/Core.lua`
(`GB.COLOR`/`GB.FONT` — byte-identical to GA's) and the window chrome pattern (warm orange
bottom-glow gradient) in GB `Config.lua` ~3264-3270. **Recommended:** lift the token literals
into `GloomsHub.COLOR/.FONT` now and record them in CONTRACTS §1 (its placeholder expects
this), plus hand-build only the few widgets the shell/Media tab need; Phase C still does the
full toolkit extraction. GB is read-only reference in Phase B — no edits there.

### Loose ends carried from Phase A (minor, resolvable in Phase B)
- The TOC's `## IconTexture` points at `Media\ui\minimap.png`, which doesn't exist — the
  addon-list icon is silently absent. Add the asset (GA has `Media\minimap.png` as a pattern)
  or drop/adjust the line.
- `Fonts/BoordensStreet.otf` still carried (harmless dead file — open Q in SUITE-PLAN §6).

### ★ QA GATE for Phase B (the owner runs; ONE step at a time; verify before claiming)
New files → **FULL CLIENT RESTART** (not `/reload`).
1. Restart WoW. No BugSack errors from GloomsHub on login. (ST's "skipped" chat lines still
   appear — expected, not a failure.)
2. `/gloom` opens a Gloom-styled window; Escape closes it; `/gloom` again toggles.
3. The Media tab lists the catalog: 1 font / 6 textures / 36 graphics, with previews.
4. Add a test font via the tab (validation: an `.otf` name is rejected with the explanatory
   message), then remove it. `/gh` counts return to 1/6/36.
5. Old windows unaffected: `/gb`, `/ga`, `/vibe`, `/st` all open their own windows as before;
   overlays still render.

**If it passes:** update [SUITE-STATE.md](SUITE-STATE.md) Phase B → done, and rewrite this
handoff as the Phase C cold-start briefing (GB is the make-or-break container-mount proof —
see SUITE-PLAN §5.C).

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **ask for BugSack text
  first** on any error.
- New files/assets → FULL CLIENT RESTART (not /reload).
- StoneTweaks stays installed until Phase F (migration already ran, but ST is still the live
  resolver for VibeOverlay; delete it LAST).
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of ANY session that moves the suite.
- Cross-repo edits are fine (all under `~/`), but the Hub is the home of record — keep facts here.
