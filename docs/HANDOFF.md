# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases **A–E are DONE and QA'd.** All three tools now render
inside the one Suite window and consume LibGloomSkin. **Phase F is next: retire StoneTweaks.**
This file is a COLD-START briefing — a session that never saw the earlier conversations should
be able to execute Phase F from this file + the three docs it points to, alone.

## Orientation (read in this order)
1. This file.
2. [SUITE-STATE.md](SUITE-STATE.md) — the phase ledger + locked decisions + the polish backlog.
   **Update it at the end of any session that moves the suite.**
3. [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + phases. For F read §5.F.
4. [CONTRACTS.md](CONTRACTS.md) — §3 is the one that matters here (resolver/media + the shim).

---

## ★ Working agreements (learned the hard way — do not repeat these mistakes)

1. **QA as you go. Do NOT build a mountain and hand it over.** Phase E gate B was written in one
   uninterrupted stretch across three addons before the owner saw a single pixel, and he was right to
   call it out. Design check-ins are not verification. Get something on screen early, then
   iterate in small steps.
2. **GB is the UI reference for the suite, not GA.** When a pattern exists in both, copy Gloom's
   Bars. GA's tab is the one with known layout problems (polish backlog).
3. **One profile/preset mechanism everywhere** — `UI.profileBlock` (CONTRACTS §4). The owner: "for
   this mechanism … they should all be using the same thing."
4. **No self-arming "click twice" confirms.** Destructive actions use `UI.confirm`, which has a
   Cancel. GB's old "Sure?" button had no way out short of closing the addon.
5. **US spelling in all user-visible text** ("Favorites", "color") — matches the codebase.
6. The owner QA's ONE copy-paste step at a time; verify before claiming; **BugSack text first**.
   New files/assets → FULL CLIENT RESTART. Lua-only edits → `/reload`.

---

## Where Phase E landed (do NOT redo any of this)

- **`~/GloomsOverlays`** — the `overlays` tab (order 30): a 240 left rail (GO mark + wordmark ·
  shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, plus an
  in-tab footer (Save & Apply + status). The asset browser is a 360-wide docked drawer opened
  from the Texture field's **Browse…**; "Use This Texture" returns the pick. Bare `/go` toggles
  the tab; one slash router in `GloomsOverlays.lua`. Zero native chrome remains.
- **LibGloomSkin → MINOR 3**: added `UI.dropdown` + `UI.flyout`, `UI.nameDialog`, `UI.confirm`,
  `UI.profileBlock`. GB's and GA's private copies of those widgets are DELETED — GB's rail
  (profile + preset) and GA's profiles drawer both drive the shared block now.
- ★ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys
  SavedVariables off the addon FOLDER name; 23 save files were copied in place at gate A and
  **12 characters ride non-Default profiles** (`Goldset`, `Empty`). Renaming those globals
  silently resets all of it. Recorded in the Overlays TOC and its CLAUDE.md too.

---

## PHASE F — retire StoneTweaks (SUITE-PLAN §5.F)

**Why it's unblocked:** Overlays was the suite's last StoneTweaks consumer, and gate A moved it
to `GloomsHub:ResolveAssetPath`. Nothing in the suite reads ST data any more.

**The work, non-destructively — ST is DELETED LAST:**
1. Confirm nothing references ST: grep `~/GloomsBars`, `~/GloomsAuras`, `~/GloomsOverlays` and
   `~/GloomsHub` for `StoneTweaks`, `CatStoneTweaks`, `StoneTweaksDB`,
   `StoneTweaks_ResolveAssetPath`. The only expected hit is the Hub's deliberate compat shim
   (CONTRACTS §3).
2. **Disable** StoneTweaks in the addon list (do not delete the folder yet) → full restart.
3. Verify off the Hub alone: fonts still serve (DrukMedium), textures + graphics still resolve,
   the Media tab catalog still reads 1 font / 6 textures / 36 graphics, and **overlays still
   render** — including on a `Goldset` character (Gloomthorn).
4. The compat shim goes LIVE at this point (ST's real resolver is gone, so the Hub's global
   takes over). Confirm no "skipped — already registered" lines at login any more — those were
   ST's own code and should vanish with it.
5. Only after the owner signs off: the ST folder can be moved out of AddOns (mirror gate A's
   pattern — **move to the Desktop, don't delete**), and `~/Desktop/VibeOverlay-retired-2026-07-24`
   can be deleted too.
6. Decide the compat shim's lifetime (SUITE-PLAN §6 open question) — with ST gone it is either
   dead code or the safety net for anyone still running an old VibeOverlay copy.

**Then G** = packaging/release: `.pkgmeta`, embed LibGloomSkin as an external in each tool,
GitHub Releases, WoWup. The version string shows literally as `@project-version@` until then.

---

## Polish backlog — lives in SUITE-STATE, don't start it mid-phase
Currently: the **Auras tab layout rework** (its own session — kill the profile drawer for a
GB-style rail, the landing page, general pass against GB's language), and **Overlays' Width /
Height / X / Y should be sliders, not typed boxes** (the owner, gate B QA: "it just needs to happen").

## Other reminders
- The suite has ONE minimap launcher (the Hub's GS button) — do not add one per tool.
- Locked decisions (full list in SUITE-STATE): hard dependency with no fallback windows; Build
  Barn is OUT of the suite; never "v1"/"later phase" framing; GUI over slash.
- **macOS `sed` has no `\b`.** Verify identifier renames with a token count against the
  originals, and `luac -p` every touched file.
