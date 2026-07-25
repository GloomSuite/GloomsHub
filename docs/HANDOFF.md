# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases A–D are **DONE and QA'd**. Gloom's Bars AND Gloom's
Auras now live entirely inside the Suite window (tabs: AURAS · BARS · MEDIA); the one
toolkit is `LibGloomSkin-1.0` (MINOR 2); the one launcher is the Hub's GS minimap button;
GA no longer reads any StoneTweaks data. **Next: Phase E — VibeOverlay becomes Gloom's
Overlays: rename + repo move + mount the Overlays tab + FULL reskin, in one phase.** This
file is a COLD-START briefing — a session that never saw the earlier conversations should
be able to execute Phase E from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — phase ledger + locked decisions + the polish backlog.
   **Update it at the end of any session that moves the suite.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases. For E read §5.E, §4.4 (the
   Overlays half), §0 (ground truth on VibeOverlay).
4. [CONTRACTS.md](CONTRACTS.md) — §2 tab API + the PINNED container size (860×626 min),
   §3 resolver/media API, §4 the LibGloomSkin surface (MINOR 2).

## Session setup for Phase E
Start in `~/GloomsHub`; you'll need the AddOns + WTF dirs (both pre-authorized in
`.claude/settings.json`) and — once created — `~/GloomsOverlays`. Commit each repo
separately. **Two things to settle WITH THE OWNER at session start (open Qs, SUITE-PLAN §6):**
1. **Slash:** recommend `/go` for the tab + keep `/vibe` as a legacy alias (both routing to
   `GloomsHub:ToggleWindow("overlays")`; `list`/`debug` subcommands stay).
2. **Repo creation:** VibeOverlay is NOT a git repo — it lives raw in
   `…/Interface/AddOns/VibeOverlay/`. The family convention is a `~/GloomsOverlays` git repo
   symlinked into AddOns. Plan: create the repo, copy the three Lua files in (renamed), add
   TOC/CLAUDE.md/.gitignore, symlink as `GloomsOverlays`, and REMOVE the old VibeOverlay
   folder in the same step (two addons defining the same overlays would double-render).
   Don't copy `.DS_Store` or the stray `backups, pretinkering/` folder.

## VibeOverlay recon (verified on disk 2026-07-24)
- Files: `VibeOverlay.lua` (371 lines — overlay engine + `/vibe` router at ~line 328),
  `VibeOverlay_Editor.lua` (1036 — the overlay manager/editor, native `BackdropTemplate`),
  `VibeOverlay_Preview.lua` (563 — the asset browser). TOC: `## Interface: 120000` (needs
  120007), `SavedVariables: VibeOverlayDB`, `SavedVariablesPerCharacter: VibeOverlayDBChar`.
- The resolver consumer (SUITE-PLAN §4.4): `VibeOverlay.lua` ~line 155 —
  `local stPath = StoneTweaks_ResolveAssetPath and StoneTweaks_ResolveAssetPath(t)` →
  change to `GloomsHub:ResolveAssetPath(t)` (the Hub's global compat shim keeps old saved
  strings working regardless; CONTRACTS §3).
- The editor label: `VibeOverlay_Editor.lua` ~line 464 — `"Texture (StoneTweaks name, atlas
  name, file ID, or Interface\\ path):"` → say "Media name" / "Suite media name".
- `/vibe` help also advertises `overlays`/`o` and `preview`/`p` subcommands — the branches
  aren't in the ~328 router block, so the Editor/Preview files extend or wrap the handler:
  READ all three files fully before rerouting (they're small).

## ⚠ THE SavedVariables-RENAME TRAP (plan around this FIRST)
WoW stores SavedVariables per ADDON FOLDER NAME: `WTF/Account/<acct>/SavedVariables/
VibeOverlay.lua` (+ per-character copies under each character's SavedVariables dir for
`VibeOverlayDBChar`). Renaming the addon to `GloomsOverlays` means the client will load
NOTHING from those files — the owner's overlays would silently vanish. Migration (pick at
session start; (a) is recommended):
- **(a) Offline file copy (recommended, client CLOSED):** copy each `VibeOverlay.lua` SV
  file to `GloomsOverlays.lua` alongside it (account-level AND every character dir that has
  one — search the WTF tree, don't assume one). Keep the GLOBAL names (`VibeOverlayDB` /
  `VibeOverlayDBChar`) in the new TOC unchanged — then the copied files load as-is, zero
  Lua migration. Rename the globals later (or never); the old VibeOverlay SV files stay
  behind as a rollback, same non-destructive pattern as the ST migration.
- (b) Transitional Lua copy (both addons installed once) — more moving parts, needs a
  throwaway load order; only if (a) is somehow blocked.
QA the migration FIRST (restart → `/vibe list` shows the same overlays) before touching
anything else, so a reskin bug can never be confused with a data-loss bug.

## The Phase E work (after the migration QA passes)
1. **TOC:** `## Interface: 120007`, `## Title: Gloom's Overlays`, `## Dependencies:
   GloomsHub`, keep both SV lines. New file names (`GloomsOverlays*.lua`) to match.
2. **Resolver + label:** the two edits above. That is the LAST StoneTweaks dependency —
   after E, Phase F can retire ST.
3. **Mount:** `GloomsHub:RegisterTab{ id="overlays", title="OVERLAYS", order=30, build=… }`
   (reserved id, CONTRACTS §2; container ≥ 860×626, OnShow/OnHide fire on tab visibility —
   GB/GA show the pattern: GB Config.lua = simple mount + in-tab footer; GA Config.lua =
   centered-column mount + docked drawers + OnShow/OnHide side effects).
4. **RESKIN in one go (the largest net-new UI chunk, locked decision — no interim
   native-looking state):** rebuild the manager/editor (and decide with the owner where the
   asset browser goes — a docked drawer like GA's pickers is the family pattern) from
   `BackdropTemplate` into LibGloomSkin (CONTRACTS §4: flatButton, sliderRow, colorSwatch,
   makeToggle, flatEditBox, makeScrollbar, attachTip…). No `Vibe` name anywhere
   user-visible.
5. **Slash:** `/go` (+ `/vibe` alias) → `ToggleWindow("overlays")`; `list`/`debug` stay.
6. **Warm pairs:** enumerate the reskinned UI's (lib-FONT, size) pairs and register the
   ones the Hub's base list misses via `UI.RegisterWarmPairs` (CONTRACTS §4 lists what GB/GA
   already warm; pairs dedupe for free).
7. **Docs, same session:** SUITE-STATE Phase E row + physical-state; CONTRACTS §5 Overlays
   row; new-repo CLAUDE.md with the suite pointer block (copy GB/GA's).

### ★ QA GATE for Phase E (the owner runs; ONE step at a time; verify before claiming)
New addon folder + renamed files → **FULL CLIENT RESTART** (and step 0 happens with the
client CLOSED).
0. (Client closed) SV files copied; old VibeOverlay folder removed; `GloomsOverlays`
   symlink in place.
1. Restart. BugSack clean. Addon list shows "Gloom's Overlays" (no "VibeOverlay" entry).
2. All previously-configured overlays render on screen exactly as before (the SV migration
   + resolver proof — including StoneTweaks-name textures, which now resolve through the
   Hub).
3. `/go` (and `/vibe`) → Suite window on **OVERLAYS**; tabs = AURAS · BARS · OVERLAYS ·
   MEDIA; `/gloom`, `/ga`, `/gb` unchanged.
4. The Overlays tab is FULLY Gloom-styled (no native Blizzard chrome anywhere): manager
   lists overlays; editing (name, texture, size, position, condition…) applies live;
   the asset browser opens where agreed and picks work.
5. `/vibe list` + `/vibe debug` (or `/go …`) still work from chat.
6. No blank text in the Overlays tab after the COLD start (warm-list check).
7. `/st` untouched; ST still installed (it retires in Phase F, not now).

**If it passes:** update SUITE-STATE (E → DONE) and rewrite this handoff as the **Phase F
briefing** (retire StoneTweaks non-destructively: disable/remove the folder, verify fonts/
textures/graphics/overlays all still work off the Hub, compat shim goes live — SUITE-PLAN
§5.F; then G = packaging/release).

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
- New files/assets → FULL CLIENT RESTART. Lua-only edits → /reload (cold-start font checks
  need a real restart).
- StoneTweaks stays installed until Phase F. Its login "skipped — already registered" lines
  are the known artifact — not a bug.
- **Polish backlog lives in SUITE-STATE** (first entry: the Auras landing page doesn't fit
  the suite — the owner, Phase D QA). Don't start polish mid-phase; collect and batch it.
- The suite has ONE minimap launcher (the Hub's GS button) — do not add one to Overlays.
- Locked decisions (full list in SUITE-STATE): hard dependency, no fallback windows; Build
  Barn is OUT; never "v1"/"later phase" framing; GUI over slash.
