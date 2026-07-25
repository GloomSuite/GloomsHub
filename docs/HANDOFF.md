# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases A, B and **C are DONE and QA'd** — the container-mount
pattern is proven: Gloom's Bars lives entirely in the Suite window's Bars tab, the suite has
ONE minimap launcher (the Hub's GS button), and `LibGloomSkin-1.0` is the one toolkit.
**Phase D — Gloom's Auras migrated into the Auras tab — is CODE-COMPLETE but NOT QA'd.**
The next action is the owner running the QA gate below. This file is a COLD-START briefing — a
session that never saw the earlier conversations should be able to run (or debug) the Phase D
gate from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — phase ledger. The Phase D row = exactly what was built.
   **Update it when the gate passes (D → DONE) or when anything changes.**
3. [CONTRACTS.md](CONTRACTS.md) — §2 now PINS the container content area (860×626 minimum)
   and lists the live tabs; §4 is the LibGloomSkin surface (MINOR 2); §1/§5 record both
   tools' engine-font exceptions.
4. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases (for E read §5.E + §4.4's Overlays
   half; Overlays = rename VibeOverlay + mount + FULL reskin in one go).

## What Phase D changed (built 2026-07-24, parse-checked, NOT in-game-verified)

**GloomsHub repo:**
- `Shell.lua`: window grew 860×680 → **860×740** to host GA's column (GA's old window was
  740 tall). The content area — **860×626 — is now PINNED in CONTRACTS §2**; tabs may treat
  it as a guaranteed minimum. GB's panes stretch (top/bottom anchored) — no GB change needed.
- `Skin.lua`: LibGloomSkin **MINOR 2** — `addEdges` now returns GA's richer edge handle
  (`.top/.bottom/.left/.right` + `:SetColor`); callers ignoring the return are unaffected.

**GloomsAuras repo (`~/GloomsAuras`):**
- TOC: **`## Dependencies: GloomsHub`**; LDB/LibDBIcon lib lines + `MinimapButton.lua` gone.
- `Config.lua`: the local toolkit copy is deleted — consumes LibGloomSkin (aliases keep every
  call site unchanged; GA's `flatButton` never used SetActive, so visuals are identical).
  The standalone window (`GloomsAurasConfig`, chrome, drag, panelPos, `C:Toggle`,
  `C:SavePanelPos`) is DELETED; `BuildTab(container)` mounts the same master/detail UI as a
  **620-wide column centered** in the container. Layout deltas for the 626px content area:
  `PANE_H` 614→528, `LIST_ROWS` 15→13, "View All Auras" bottom-anchored — the editor pane
  already scrolls and the list is windowed, so nothing is lost. Docked drawers (`DockRight`)
  parent to the CONTAINER → they hide on tab switch and window close; free-floating pickers
  still close via the container's OnHide (which also un-forces the editor preview, exactly
  like the old window's OnHide). Registered via `RegisterTab{ id="auras", title="AURAS",
  order=10 }` — no refresh handler; the container's OnShow re-syncs + opens the landing,
  matching old behavior. **`CatStoneTweaks` → `CatSuiteMedia`**: the texture picker's
  "StoneTweaks Graphics" category is now **"Suite Graphics"**, fed by
  `GloomsHub:ListMedia("graphics"/"textures")` — GA no longer reads `StoneTweaksDB` or
  hardcodes ST paths ANYWHERE (one of the two ST dependencies from SUITE-PLAN §0 is gone;
  Overlays' resolver call is the last one, Phase E).
- `Core.lua`: `GA.COLOR` aliases the lib (dup deleted); **`GA.FONT` stays on GA's own files**
  (users' saved configs store those font paths via the font picker; files are byte-identical
  to the Hub's). `/ga` (and `config`/`options`) → `GloomsHub:ToggleWindow("auras")`;
  `/ga minimap` now toggles the HUB's GS button. **Every other `/ga` subcommand untouched.**
- Warm pairs GA registers (via `RegisterWarmPairs`, Config.lua top): title 13/16/17/18/20 ·
  head 12/13 · label 11/12.
- `.pkgmeta`: LDB + LibDBIcon externals dropped.

Both repos are committed separately. VibeOverlay + StoneTweaks: completely untouched.

## Locked decisions (do NOT reopen — full list in SUITE-STATE.md)
Base = GloomsHub (permanent path). **Hard dependency, no fallback** — config renders ONLY in
the Hub shell; the tools' own windows are deleted (never resurrect one while debugging).
StoneTweaks retires at Phase F (keep installed until then). VibeOverlay → Gloom's Overlays
(Phase E, reskin in one go). **Build Barn is OUT.** One suite minimap launcher (the Hub's).
Never "v1"/"later phase" framing. GUI over slash.

---

## ▶▶ NEXT: run the ★ QA GATE for Phase D (the owner runs; ONE step at a time; verify before claiming)

Files changed in TWO addons (GA file deleted, Hub shell resized) → **FULL CLIENT RESTART**.

1. Restart the client. BugSack clean at login. (Known artifact, not a bug: ST's
   "skipped — already registered" lines.)
2. `/ga` → the Suite window (now a bit taller) opens focused on **AURAS**; tabs read
   **AURAS · BARS · MEDIA**; `/gloom` toggles; `/gb` still opens BARS.
3. The Auras tab opens on the landing (logo + Add Icon/Texture/Bar Aura + View All Auras —
   View All now sits just above the footer divider). Creating/selecting auras works; the
   left list scrolls (13 rows now); the editor accordion opens/edits live; the aura NAME
   field renders (cold-start font check — Khand 20).
4. Docked drawers + pickers: texture picker, sound picker, font picker, trigger editor,
   visibility/group/profile drawers all open docked to the WINDOW's right edge, and all
   disappear when you switch to another tab or close the window.
5. **Texture picker → category dropdown → "Suite Graphics"** lists the catalog (36 graphics
   + 6 textures, same art as before — now served from `Interface\AddOns\GloomsHub\…`);
   picking one applies it. Existing auras that used StoneTweaks-path textures still render
   (their saved paths still resolve — ST is still installed).
6. Editor preview behavior: displays force-show while the Auras tab is visible, stop when
   you switch tabs or close the window; profile switching (footer "Profile:" button) still
   rebuilds the list.
7. No blank text anywhere in the Auras tab after the COLD start (name field, section
   headers, pill labels, slider values, drawer titles).
8. `/ga help/list/debug/trace/probe…` all still work; `/ga minimap` toggles the GS suite
   button. `/vibe` + `/st` untouched and their windows still work.

**If it passes:** update [SUITE-STATE.md](SUITE-STATE.md) Phase D → **DONE — QA'd**, and
rewrite this handoff as the **Phase E briefing** (Overlays: rename VibeOverlay →
`GloomsOverlays`, mount the Overlays tab, route `/go` (+ keep `/vibe` as alias — open Q),
update `VibeOverlay.lua:155` to `GloomsHub:ResolveAssetPath` + the editor label at
`VibeOverlay_Editor.lua:464`, and RESKIN the whole editor/manager into LibGloomSkin in the
same phase; see SUITE-PLAN §5.E + §4.4 and CONTRACTS §2/§3/§4).

**If something fails:** BugSack error text FIRST. Debug within the shell-mount design.
Likely seams: the pinned 860×626 assumption (check CONTRACTS §2 vs Shell.lua constants), a
cold font pair missing from a warm list (CONTRACTS §4 lists who warms what), drawer strata/
parenting inside the container, the landing's bottom-anchored View All button.

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
- New files/assets → FULL CLIENT RESTART. Lua-only edits → /reload is enough (but cold-start
  font checks NEED a real restart).
- StoneTweaks stays installed until Phase F (GA no longer reads it, but users' saved texture
  paths may still point into it until they re-pick, and Overlays still resolves through it
  until E — retiring it early would silently blank those).
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of ANY session that moves the suite.
- Phase E is a ONE-REPO-plus-Hub phase but the folder MOVES: VibeOverlay lives directly in
  AddOns (not symlinked); renaming it to `GloomsOverlays` likely means creating the repo at
  `~/GloomsOverlays` + symlinking, matching the family convention. Plan that step with the owner
  at the start of the session.
