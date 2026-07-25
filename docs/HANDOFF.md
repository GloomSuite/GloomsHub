# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases A **and** B are **DONE and QA'd** — the Hub has live media
plumbing AND the working Suite window with the Media tab. **Next: Phase C — migrate Gloom's
Bars into a Bars tab. The make-or-break proof of the container-mount pattern.** This file is a
COLD-START briefing — a session that never saw the earlier conversations should be able to
execute Phase C from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — phase ledger + locked decisions + the two Phase B
   findings (font pre-warmer, window interleave). **Update it when Phase C completes.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases. For C read §2.5 (sizing the
   refactor), §3 (shell API + slash routing), §5.C (scope + QA).
4. [CONTRACTS.md](CONTRACTS.md) — §1 tokens (now authoritative in the Hub), §2 tab API
   (implemented exactly), §4 LibGloomSkin (Phase C pins its surface HERE).

## What exists now (Phases A+B shipped 2026-07-24)
- **GloomsHub is fully live:** `Core.lua` (DB, ST copy-migration done — `migratedFromST=true`
  on the owner's account —, dormant `StoneTweaks_ResolveAssetPath` shim, `/gh` probe), `Skin.lua`
  (suite tokens `GloomsHub.COLOR/.FONT` + `GloomsHub.UI` widget toolkit + `UI.WarmFonts`),
  `Shell.lua` (`GloomsSuiteWindow`: `RegisterTab/Open/FocusTab/ToggleWindow`, `/gloom`,
  lazy `build(container)`), `Media.lua` (LSM registration at PEW, resolver, `ListMedia`,
  `Media:Add*/Remove*`, the Media tab — accordion, previews, add/remove).
- TOC load order: Libs (LibStub, CallbackHandler, LSM) → Core → Skin → Shell → Media.
- Assets: `Fonts/` (8) `Textures/` (13) `Graphics/` (45) committed; `Media/fonts/` (Khand +
  GeneralSans ×5 from GB) + `Media/ui/caret.png`. No Hub logo art yet (TOC IconTexture dangles).
- **⚠ The font pre-warmer (Skin.lua `UI.WarmFonts`)**: WoW draws a cold (font file, size)
  pair BLANK the first time each session (QA-proven; /reload heals, next cold start re-breaks).
  `Media:RegisterAll` warms every pair the Hub UI uses at PEW. **Any new (font, size) pair a
  Phase C tab introduces MUST be added to the warm list** or its text will be blank on cold
  starts. GB's sections use sizes the Hub doesn't (12.5, 14, 17, …) — enumerate them
  (`grep -o 'FONT\.\w*, [0-9.]*' ~/GloomsBars/Config.lua | sort -u`) when swapping toolkits.
- Window interleave when the Suite window overlaps GB/GA/ST windows: pre-existing same-strata
  family quirk, ACCEPTED by the owner for the transition (gone once tools mount as tabs). The
  Suite window raises on show/click; do not add SetToplevel (it pins GB underneath, tried).
- GB, GA, VibeOverlay, StoneTweaks: still completely untouched.

## Locked decisions (do NOT reopen — full list in SUITE-STATE.md)
Base = GloomsHub (permanent path). **Hard dependency, no fallback** — each tool's config
renders ONLY in the Hub shell; the tool deletes its own window. StoneTweaks retires at Phase F
(keep installed). VibeOverlay → Gloom's Overlays (Phase E, reskin in one go). **Build Barn is
OUT.** Never "v1"/"later phase" framing. GUI over slash.

---

## ▶▶ PHASE C — migrate Gloom's Bars into the Bars tab (FIRST cross-repo phase: GB IS edited)

**Goal:** `/gb` opens the Suite window focused on a **Bars** tab that contains GB's entire
config UI (left rail, accordion, preview pane, footer controls) working exactly as before.
GB's standalone window and its local toolkit copy are deleted. `/gloom` shows Bars + Media.
**GA, VibeOverlay, StoneTweaks are NOT touched in Phase C.**

**Session setup:** start the session in `~/GloomsHub` (so this briefing loads) and add
`~/GloomsBars` as an additional working directory (`/add-dir ~/GloomsBars`, or launch with
`claude --add-dir ~/GloomsBars`) — Phase C edits both repos. Commit each repo separately.

### The work
1. **Formalize `LibGloomSkin-1.0`** from Skin.lua's body: register via LibStub (GloomsHub is
   the canonical shipper; the stateless toolkit + tokens). Pin the exact exported surface in
   CONTRACTS §4 as you do it. (`GloomsHub.UI/.COLOR/.FONT` can stay as the Hub-side aliases.)
2. **GB TOC: add `## Dependencies: GloomsHub`.** ⚠ Load-order trap: alphabetically GloomsBars
   loads BEFORE GloomsHub — without the Dependencies line, any `GloomsHub.*` reference at GB
   file scope is a nil error. The hard-dep line fixes load order AND is the locked design.
3. **GB `Config.lua`:** delete the standalone window chrome — `BuildPanel()`'s frame/title/
   drag/glow/edges (~3256-3415) and `C:Toggle()` (~3430) — and instead
   `GloomsHub:RegisterTab{ id="bars", title="BARS", order=20, build=function(container) … end,
   refresh=function() C:Refresh() end }`. The build body = the EXISTING rail/accordion/preview
   construction re-parented to `container` (section builders unchanged — that's the ~3200
   reusable lines). GB's footer controls (master Enable toggle, Move Bars, Highlight, Quick
   Keybind) move INTO the Bars container (per CONTRACTS §2 — NOT the shared footer).
4. **Toolkit swap:** GB's local `setFont/newText/flatButton/…` copies + `GB.COLOR/GB.FONT`
   → consume LibGloomSkin / the Hub's tokens. GB's own `Media\fonts\` copies can stay on disk
   for now (its non-config uses), but config text must use the Hub's paths so pairs are warm.
5. **Slash:** `/gb` config branch → `GloomsHub:ToggleWindow("bars")` (GB `Core.lua` router
   ~1226). EVERY `/gb` diagnostic subcommand (`debug`, `mask`, `shape`, …) stays untouched.
6. **Warm the new pairs:** extend the warm list for every (Hub font, size) the Bars tab uses
   (see the ⚠ above). Cleanest: let `UI.WarmFonts` accept additions from any addon and have
   GB register its sizes at load.
7. **Sizing check:** Suite content area is currently 860 × ~568 (shell 860×680 minus title 48,
   tab strip 34, footer 30). GB's three-pane body is 820 wide × 540 + its relocated footer
   row. If it doesn't fit, adjust the SHELL constants in Shell.lua (Hub-owned, no contract) —
   do not shrink GB's panes.

### ★ QA GATE for Phase C (the owner runs; ONE step at a time; verify before claiming)
New/changed files in TWO addons → **FULL CLIENT RESTART**.
1. Restart. BugSack clean.
2. `/gb` → Suite window opens focused on **BARS**; `/gloom` toggles; tabs = BARS + MEDIA.
3. Every GB section opens and edits live (shape picker, plate, text, glows, layout…);
   the right preview pane renders; profiles/presets rail works.
4. Footer controls INSIDE the Bars tab: master Enable, Move Bars, Highlight, Quick Keybind —
   each still works; Move mode still ends when the window closes.
5. No blank text anywhere in the Bars tab after a COLD start (the warm-list check).
6. `/gb debug` (and other diagnostics) still work from chat. `/ga`, `/vibe`, `/st` untouched.

**If it passes:** update [SUITE-STATE.md](SUITE-STATE.md) Phase C → done and rewrite this
handoff as the Phase D briefing (GA migration — same pattern + `CatStoneTweaks` →
`GloomsHub:ListMedia`).

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
- New files/assets → FULL CLIENT RESTART. Lua-only edits → /reload is enough (but cold-start
  font checks NEED a real restart).
- StoneTweaks stays installed until Phase F. The ST login "skipped — already registered"
  lines are the known artifact — not a bug.
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of ANY session that moves the suite.
- Cross-repo edits are expected from Phase C on (GB is `~/GloomsBars`, symlinked into AddOns);
  the Hub stays the home of record — cross-cutting facts live HERE.
