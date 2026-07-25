# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24 (second session that day).** Phases A + B are DONE and QA'd.
**Phase C — Gloom's Bars migrated into the Bars tab — is CODE-COMPLETE but NOT QA'd.**
The make-or-break proof of the container-mount pattern is built and parse-checked; **the next
action is the owner running the QA gate below.** This file is a COLD-START briefing — a session
that never saw the earlier conversations should be able to run (or debug) the Phase C gate
from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — phase ledger. Phase C row = exactly what was built.
   **Update it when the gate passes (C → DONE) or when anything changes.**
3. [CONTRACTS.md](CONTRACTS.md) — §4 is now the PINNED LibGloomSkin-1.0 surface (MINOR 1);
   §1 notes GB's engine-font exception; §2 the tab API (unchanged, implemented exactly).
4. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases (for D read §5.D + §4.4).

## What Phase C changed (built 2026-07-24, parse-checked, NOT in-game-verified)

**GloomsHub repo:**
- `Skin.lua` is now the body of **`LibGloomSkin-1.0`** — registered via LibStub (MINOR 1),
  `GloomsHub.COLOR/.FONT/.UI/.MEDIA` are aliases. Absorbed three GB-only widgets
  (`sliderRow`, `colorSwatch`, `dirRow`) and grew **`UI.RegisterWarmPairs`** (tools queue
  font pairs at file load; they warm with the Hub's PLAYER_ENTERING_WORLD batch).
  `makeSection` is deliberately NOT in the lib (each tab keeps its accordion — CONTRACTS §4).
- `Media.lua`: catalog fonts now warm at 11/13/14 (Media-tab preview + the tools' font pickers).
- `Shell.lua`: title bar now shows the **GS monogram** (`Media/ui/logo.png`) — the owner's new
  Gloom Suite logo (2026-07-24). `Media/ui/minimap.png` (64×64) fills the TOC IconTexture
  that used to dangle. **New art files ⇒ full client restart required.**

**GloomsBars repo (`~/GloomsBars`):**
- TOC: **`## Dependencies: GloomsHub`** (fixes load order — alphabetically GB loads first —
  AND is the locked hard-dep design; GB without the Hub now fails loudly in the addon list).
- `Config.lua`: the ~290-line local toolkit copy is DELETED — it consumes LibGloomSkin
  (local names unchanged, so the ~2900 lines of section builders are untouched). The
  standalone window (`BuildPanel` chrome, `GloomsBarsConfig`, `C:Toggle`, its
  UISpecialFrames entry) is DELETED; `BuildTab(container)` builds the same rail/accordion/
  preview INSIDE the shell's container, plus the tab's OWN footer row (master Enable ·
  Move Bars · Highlight-preset · Quick Keybind — per CONTRACTS §2). Registered via
  `GloomsHub:RegisterTab{ id="bars", title="BARS", order=20, refresh=C:Refresh }`.
  Move mode ends on the container's OnHide (window close AND tab switch). Flyout catchers
  parent to the container. Quick Keybind hides `GloomsSuiteWindow`. The middle pane absorbs
  the shell's extra width (accordion tracks the scroll's live width — no shell coupling).
- `Core.lua`: `GB.COLOR` now aliases the lib's table (dup deleted). **`GB.FONT` deliberately
  stays on GB's own font files** — bar text rasterizes per (path, size); swapping paths
  would cold-start every user's bar keybinds/counts (files are byte-identical anyway).
  `PreloadFonts` warms GB paths at 11 + 14 (font-picker sizes). `/gb` (and `config`/`ui`)
  → `GloomsHub:ToggleWindow("bars")`. **Every diagnostic subcommand untouched.**
- `MinimapButton.lua`: click → `GloomsHub:ToggleWindow("bars")`.
- Warm pairs GB registers (via `RegisterWarmPairs`, Config.lua top): title 17/18 ·
  head 12/13 · body 9.5/10/12.5 · label 10/10.5/11.

Both repos are committed separately. GA, VibeOverlay, StoneTweaks: completely untouched.

## Locked decisions (do NOT reopen — full list in SUITE-STATE.md)
Base = GloomsHub (permanent path). **Hard dependency, no fallback** — config renders ONLY in
the Hub shell; GB's own window is deleted (do not resurrect it "temporarily" while debugging).
StoneTweaks retires at Phase F (keep installed). VibeOverlay → Gloom's Overlays (Phase E).
**Build Barn is OUT.** Never "v1"/"later phase" framing. GUI over slash.

---

## ▶▶ NEXT: run the ★ QA GATE for Phase C (the owner runs; ONE step at a time; verify before claiming)

Files changed in TWO addons + NEW ART FILES in the Hub → **FULL CLIENT RESTART** (not /reload).

1. Restart the client. BugSack clean at login. (Known artifact that is NOT a bug: ST's
   "skipped — already registered" lines.)
2. `/gb` → the Suite window opens focused on **BARS**; the title bar shows the GS monogram;
   tabs = BARS + MEDIA; `/gloom` toggles; addon list shows the GS icon for Gloom's Hub.
3. Every GB section opens and edits live (shape picker, plate, text, glows, animations,
   cast, cooldown, empty slots, bar layout…); the right preview pane renders and its state
   chips work; the left profiles/presets rail works (dropdowns, new/copy/rename/delete).
4. Footer controls INSIDE the Bars tab: master Enable, Move Bars, Highlight, Quick Keybind —
   each works; Move mode ends when the window closes AND when switching to the Media tab;
   Quick Keybind closes the Suite window and opens Blizzard's flow, reskinned.
5. No blank text anywhere in the Bars tab after the COLD start (the warm-list check —
   includes rail headers, slider values, group titles, the preview caption, dialog titles).
6. `/gb debug` (and the other diagnostics) still work from chat. `/ga`, `/vibe`, `/st`
   untouched and their windows still work.
7. Minimap button (if shown) toggles the Suite window on Bars.

**If it passes:** update [SUITE-STATE.md](SUITE-STATE.md) Phase C → **DONE — QA'd**, and
rewrite this handoff as the **Phase D briefing** (GA migration — same pattern as C: hard dep,
toolkit swap to LibGloomSkin, Auras tab + in-tab footer, `/ga` reroute, warm-pair enumeration
— PLUS flip GA's `CatStoneTweaks` → `GloomsHub:ListMedia("graphics")` + relabel "StoneTweaks
Graphics" → "Suite Graphics"; see SUITE-PLAN §4.4 + §5.D and CONTRACTS §3).

**If something fails:** BugSack error text FIRST. Debug within the shell-mount design (the
old window is gone by locked decision — never re-add it as a workaround). Likely seams:
load order (the TOC Dependencies line), a cold font pair missing from the warm lists
(CONTRACTS §4 lists who warms what), flyout strata inside the container, move-mode/OnHide.

---

## Reminders
- The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
- New files/assets → FULL CLIENT RESTART. Lua-only edits → /reload is enough (but cold-start
  font checks NEED a real restart).
- StoneTweaks stays installed until Phase F. Its login "skipped — already registered" lines
  are the known artifact — not a bug.
- The window-interleave quirk (Suite window vs GA/ST windows at same strata) remains ACCEPTED
  for the transition; GB's standalone window is gone now, so one interleave source is too.
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of ANY session that moves the suite.
- Cross-repo sessions: start in `~/GloomsHub`, add `~/GloomsAuras` for Phase D
  (`claude --add-dir ~/GloomsAuras`); commit each repo separately. The Hub stays the home of
  record — cross-cutting facts live HERE.
