# Gloom Suite — STATE ledger

> **This is the single answer to "where are we?" Read it FIRST for any suite work.
> UPDATE it at the end of any session that moves the suite.** Home of record: this repo.
> Full design in [SUITE-PLAN.md](SUITE-PLAN.md). Shared contracts in [CONTRACTS.md](CONTRACTS.md).

**Last updated:** 2026-07-25i — **★★ 12.1 BREAKS GLOOM'S AURAS IN COMBAT — see the new
[12.1 readiness section](#-121-midnight-s2-ptr-readiness--opened-2026-07-25) below.** Proven on the
PTR: in combat 12.1 hands back aura instance IDs as SECRET values and every
`GetAuraDataByAuraInstanceID`/`GetAuraDuration` call **throws** — GA keeps aura *presence* but loses
duration, stacks and expiry entirely. It fails **silently** (the throws are `pcall`ed; BugSack stayed
clean while nothing rendered). Fixing it means migrating to Blizzard's new `AuraContainer` model —
a GA design session, not a patch. **GB is hit too, in THREE places that are probably ONE root cause
(its re-assert post-hooks appear dead on 12.1): bars scatter on Edit Mode entry, don't recover on
Edit Mode exit (FINDING 1), and jump on every COMBAT ENTRY (FINDING 4 — the most disruptive of the
lot).** Also FINDING 2: GA's font fallback is broken on live, unrelated to 12.1. **One fix has
shipped into the tree** — a ticker in `GloomsBars/Layout.lua` that restores bars after Edit Mode
exit, PTR-verified working and live-verified no-regression; it treats a symptom, not the root cause.
Everything else is diagnosis only. Before that: **★★ THE TO-DO LIST WAS EMPTY. The 7-phase plan is complete AND the
polish backlog is closed.** The last item (3, GB's modifier symbols) was **DROPPED by the owner on
2026-07-25** — reviewed, priced, and judged not worth the cost; no code changed, and it is not to be
re-proposed. **★ THE SAME SESSION SHIPPED A NEW GB FEATURE AND THE SUITE'S FIRST DRIFTED RELEASE:
`GloomsBars v1.1.1`** (base icon tint — Wash/Tint + strength, in Decoration layers; `v1.1.0` shipped it
with a per-preset bug the owner caught within minutes, fixed in `v1.1.1` — the record is in GB's
SESSION 17 PART C and the trap generalizes to every future preset field). The other three
addons stay at **`v1.0.1`**, which is the *intended* behaviour of the versions-may-drift decision
below, not an oversight. **Nothing in the Hub changed: no new widget, no MINOR bump (LibGloomSkin
stays at 4), no consumer gate moved.** Full record in HANDOFF's 2026-07-25h session record; the GB
detail lives in GB's own handoff (SESSION 17). Before that: **Overlays' SLIDERS were DONE and QA'd** (to-do item 2). That session also did two things
that were NOT on this list, both GO-only: the overlay engine now **recycles its live frames**
instead of building new ones on every apply, and the Layer section gained a numeric **Level**
(z-order within a strata) plus WoW's two missing stratas. Before that: **the MODAL SCRIM is DONE and QA'd** (the dialogs now dim what's
behind them), and **the whole housekeeping section of the to-do list is CLOSED**: the `test-remove`
graphic is out of the catalog, `BoordensStreet.otf` is deleted, and the repo-pages visibility
question was **accepted and closed — do not raise it again**. Before that: the **AURAS TAB LAYOUT
REWORK (to-do item 1) is DONE and QA'd**; see the to-do list below. And before that: **★★ PHASE G IS DONE AND THE 7-PHASE PLAN IS COMPLETE.** The owner
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
(items 1 and 2 are done; **only 3 remains**)
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
2. ~~**Overlays: Width / Height / X / Y → SLIDERS** · `~/GloomsOverlays`~~ — **✅ DONE, QA'd by the
   owner 2026-07-25.** Each is `UI.sliderRow` **plus a typed box** so exact values stay enterable;
   the nudge arrows stayed. **No `SKIN_NEEDS` bump**, exactly as predicted — the editor stays at
   MINOR 4 and nothing in the Hub was touched.
   ★ **The shape worth copying:** `UI.sliderRow` parks a read-only value FontString at its
   TOPRIGHT, so the tab passes a `fmt` that returns `""` and puts a `flatEditBox` in that slot —
   the box becomes the readout AND the input, with no lib change. Typed values clamp into the
   slider's range so the two can never disagree.
   ★ **A half-width slider means a half-width PARENT** — `sliderRow` always spans its parent with
   fixed 18px insets, so the tab lays out column frames (anchored to the pane's `TOP`, so they
   split whatever width the shell gives) rather than x offsets. Same trick puts the spin
   direction buttons beside the Spin slider instead of under it. The owner's steer, 2026-07-25:
   *"so much horizontal width available, no point in stacking everything."*
   ★ **A slider is a NEW performance surface, and it found a real bug.** `ApplyAll` rebuilt every
   live overlay frame on every value change — ~60×/second while dragging, and **WoW never reclaims
   a frame**, so a 3-second drag on a 19-overlay profile parked ~3,400 dead frames for the session
   (each with a unique global name). The owner asked for it fixed on the spot, citing general
   framerate concerns. Both halves landed: the engine now **reuses a pool of frames** (the Nth
   enabled overlay always draws through slot N; surplus slots are parked, not discarded), and
   size/position/strata/level re-apply **in place** via `GloomsOverlays_ApplyLayout` without any
   rebuild at all. ⚠ **A recycled frame carries its last occupant's settings** — everything set
   *conditionally* (the OnUpdate animation, texture, texcoord, rotation) must be reset explicitly
   at the top of the build, and shown with `SetShown`, not `Hide`.
   ★ **Also landed, unplanned (the owner asked whether 7 stratas was a Blizzard limit):** the tab
   now offers **all NINE** stratas — `WORLD` and `FULLSCREEN_DIALOG` were missing — plus a numeric
   **Level** row (0–1000) ordering overlays *within* a strata. Every overlay used to draw at the
   same level, so strata was the only separation there was. An overlay that has never set `level`
   still draws at WoW's natural default (read from a real frame, not assumed), so nothing moved.
3. ~~**Modifier symbols (⌘⇧⌃⌥) take no outline/shadow** · `~/GloomsBars`~~ — **✅ CLOSED 2026-07-25:
   DROPPED, WON'T DO** (the owner). *"Leave the glyphs untouched… juice isn't worth the squeeze. I can
   deal with no stroke/dropshadow on the glyphs."* **Do not re-propose it.** No code changed — the
   glyphs stay as unstyled inline PNGs. The full reasoning lives on **GB's handoff item (d)**, which is
   the home of record for it; in short: WoW can never style an inline `|T…|t` texture, and the approved
   fix (a second FontString in a glyph font) hid a **hard prerequisite nobody had written down** — a
   bundled font actually containing U+2318/21E7/2303/2325, which GB does not have, making it a new
   `.ttf` (the suite's one genuine restart case) plus a licensing question, on top of duplicating the
   entire keybind styling + re-assert surface. **No open GB bugs.**
   ★ **The lesson worth carrying:** the cost of a deferred item can be much higher than its handoff entry
   says. This one had read as "fiddly but approved" across three sessions; pricing it properly before
   coding is what closed it in one exchange instead of one session.

**Small / housekeeping**
4. ~~Remove the leftover **`test-remove`** graphic from the Media catalog~~ — **✅ DONE by the owner
   in the Media tab, 2026-07-25.** The StoneTweaks inheritance is out of the catalog.
5. ~~Open question: the stray **`BoordensStreet.otf`** — keep or drop?~~ — **✅ CLOSED: DROPPED**
   (the owner, 2026-07-25). *"OTF fonts don't work in game."* `Fonts/BoordensStreet.otf` deleted;
   **`BoordensStreet.ttf` sits beside it**, so no typeface was lost, and nothing referenced the file.
6. ~~The public repo PAGES expose `CLAUDE.md` + `docs/`~~ — **✅ CLOSED: ACCEPTED, and it is not to be
   raised again (the owner, 2026-07-25).** *"I don't care enough to go with any of the alternatives,
   so it's fine. You can stop mentioning it."* **Do not re-flag this, and do not propose a fix.**
   For the record, so nobody re-derives it: GitHub visibility is **per-repo, never per-path** — there
   is no setting, `.gitattributes` or equivalent that hides a tracked file from a public repo's web
   UI. The only real options were untracking the docs (which would cost SUITE-STATE, the home of
   record, its history and its only off-machine backup) or moving them to a separate private repo (a
   second clone to keep in sync + every `CLAUDE.md` pointer rewritten). Both cost more than the
   problem: the files are identity-clean after TASK 0 and are already excluded from the packaged
   zips, so no installer or friend ever receives them.
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
- ~~Dim the background behind `UI.nameDialog` / `UI.confirm`~~ — **DONE + QA'd by the owner
  2026-07-25.** Raised at the end of the Auras rework (the modals are plates in the same near-black
  navy as the panel they open over, so they read as part of the tab). One shared scrim in
  `Skin.lua` serves both: full-screen black, `FULLSCREEN_DIALOG` at the dialog's level −5, so it
  dims the shell (which sits on `DIALOG`) but never the dialog. **It also eats clicks — that is what
  makes the dialogs genuinely modal.** ★ Two calls worth keeping: clicking the scrim does **not**
  dismiss (the family answer is always an explicit OK / Cancel / ESC — a click-elsewhere that
  silently drops a typed name is the same trap as the retired self-arming "Sure?" button); and it
  hides via `HookScript("OnHide")` on both dialogs rather than from the button handlers, because
  that is **the only path that catches the `UISpecialFrames` ESC**, which never runs our own code.
  Alpha landed at **0.72** — 0.55 read as too subtle to the owner on the first pass.
  ★ **No MINOR bump:** internal behavior, no new API, so no consumer's `SKIN_NEEDS` gate moved.
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

## ▶ 12.1 (Midnight S2) PTR READINESS — opened 2026-07-25

**Status: DIAGNOSING ONLY. No code changed, nothing committed, no TOC bumped.** The PTR APIs are
still landing in pieces over the coming weeks, so fixing now means fixing twice. Record findings
here; act later.

**★★ THE OWNER'S DECISION, 2026-07-25: WAIT FOR LAUNCH, THEN TRIAGE. Do not re-litigate.** The PTR
is in flux, and he is **switching to Hunter for Season 2** — the Hunter/cooldown path is unaffected
by FINDING 3, so the Warlock aura work can wait until after 12.1 ships. No aura redesign before
launch.

**Two carve-outs he was told about and can take any time — neither is Warlock-specific:**
- **FINDING 2** is a live bug *today*, nothing to do with 12.1, one line.
- **FINDING 1** hits **every character** on patch day, not just casters — Edit Mode is class-agnostic.

**⚠ ONE THING TO TEST BEFORE SEASON 2 (starts ~2026-08-19):** "Hunter still works" was proven only
for **SV, with two auras**. **MM was never tested**, and Precise Shots / Spotter's Mark may be
buff-duration driven rather than cooldown driven — which would put them on FINDING 3's broken path.
Ten minutes on the PTR settles it; do it before the season, not during a key.

**The PTR is left set up and ready** (see Setup below) — symlinks, live SavedVariables and
`SecretScan` are all in place, so re-testing costs nothing but a launch.

**Setup (done 2026-07-25):** `_ptr_` is **12.1.0.68914** (`wowt`); retail is 12.0.7.68887.
`_ptr_/Interface/AddOns/` has the four suite addons plus `!BugGrabber`, `BugSack`, `SecretScan`, and
the three addons GA's config references by path (`ArcUI`, `NiceDamage`, `EnhanceQoL` + its 15
modules — without them a font path 404s and trips FINDING 2). Live SavedVariables were copied across
(account-level ×4, plus per-char Overlays for Gloomwick/Gloomrift); the PTR's fresh defaults are
backed up in the session scratchpad. TOCs deliberately left at `120007` — "Load out of date AddOns"
is enough to test.

**★★ GB IS THE EXCEPTION — IT IS NOT SYMLINKED TO ITS MAIN REPO (set up 2026-07-25).** Hub, GA and
GO all point at their normal repos on both clients, so an edit to those IS live on both. **GB does
not:**

| Client | Loads | Branch |
|---|---|---|
| retail (live) | `~/GloomsBars` | `main` |
| PTR | **`~/GloomsBars-ptr`** (a `git worktree`) | **`12.1-layout`** |

**All 12.1 GB work happens in `~/GloomsBars-ptr`.** `Libs/` there is a symlink to the main repo's
(it is git-ignored, and GB won't start without `LibStub`). Git refuses to check `12.1-layout` out in
the live folder, so the isolation is enforced, not remembered — verified. Unwind with
`git merge 12.1-layout` → `git worktree remove ~/GloomsBars-ptr` → repoint the PTR symlink back.

**PTR TESTING TRAP — cost an hour once already:** GB and GA both key profiles by **character + realm**,
and PTR copies live on **Anasterian** while every real profile says **Stormrage**. So both addons
auto-create *fresh empty* profiles on the PTR. For GB that means `layoutEnabled` is **off**, `ApplyAll`
is a no-op, and any layout test silently proves nothing. `Gloomwick - Anasterian` has been switched on;
verify before trusting any result. (GB's only profiles with layout on are `Gloomrift - Stormrage` and
`Gloomfury - Stormrage`.)

**When fixes do start:** feature-gate at runtime (`if C_UnitAuras.GetAuraDataByAuraInstanceID then`),
don't fork; `## Interface: 120007, 120100` supports both clients from one package. Work on a branch —
the owner's live client loads the working tree.

### FINDING 1 — GB's bars never recover from Edit Mode exit · `~/GloomsBars` · CONFIRMED
**`EDIT_MODE_LAYOUTS_UPDATED` no longer fires on Edit Mode exit in 12.1.** Owner-reproduced on the
PTR and **confirmed absent on live**, so this is a real 12.1 change, not a PTR artifact.

- Symptom: enter Edit Mode → bars scatter. Exit → they **stay** scattered. `/reload` fixes it; so
  does any other layout trigger.
- **★ CORRECTION 2026-07-25 — the entry-scatter is NOT "by design", as this entry first claimed.**
  [Layout.lua:34-40](../../GloomsBars/Layout.lua#L34-L40) suspends GB so it doesn't fight Blizzard's
  show-all, but suspending only stops GB re-asserting — it does not move anything. **On LIVE the bars
  stay exactly where GB put them when Edit Mode opens** (owner-verified). They scatter only because
  something on 12.1 actively re-lays them. Do not repeat the "expected, by design" framing.
- **Root cause is narrow, and two rival theories were killed by test:** `IsEditModeActive()` still
  reports correctly (it read "closed" after exit), and `ApplyAll()` works fine on 12.1. The owner
  grabbed a spell from the spellbook → `ACTIONBAR_SHOWGRID` → `queueApply()` → **bars snapped back
  and stayed back.** So GB is simply waiting on an event that never arrives.
- **Blast radius: GloomsBars ONLY.** Hub/GA/GO never register the event (grep-verified). GA's
  `EditModeManagerFrame` use at [CDM.lua:91](../../GloomsAuras/CDM.lua#L91) is *not* affected.
- **Fix shape (NOT yet written):** GB needs another exit signal. `IsEditModeActive()` is proven
  working, so a ticker started on Edit Mode open that watches for the true→false transition and
  fires `queueApply()` is the obvious candidate; `hooksecurefunc(EditModeManagerFrame, "ExitEditMode", …)`
  is the alternative but may collide with 12.1's protected-frame lockdown.

### ★★ FINDINGS 1 AND 4 ARE PROBABLY ONE ROOT CAUSE — read before fixing either
**Hypothesis (consistent with all evidence, NOT yet proven): GB's re-assert POST-HOOKS are dead on
12.1.** Blizzard has always re-laid the bars at various moments; GB hooks
`UpdateGridLayout` / `UpdateShownButtons` / `UpdateVisibility` / `ApplySystemAnchor`
([Layout.lua:485-494](../../GloomsBars/Layout.lua#L485-L494)) and re-asserts instantly, so on live
you never SEE a scatter. On 12.1 every observed symptom is "Blizzard re-laid the bars and GB did not
put them back": Edit Mode entry, Edit Mode exit, combat entry. That is precisely what the Forbidden
Aspects lockdown (`UntrustedScriptExecution` — addon script handlers on protected frames) would cause.

**Consequence: the FINDING 1 ticker fix treats a SYMPTOM, not the disease.** It restores the bars
after Edit Mode exit and is verified working — but it does nothing for combat entry, and it would be
unnecessary if the post-hooks fired. **Diagnose the post-hooks FIRST in any GB session**; a fix there
may retire both findings at once. Test shape: out of combat on the PTR, cause Blizzard to re-lay a
bar and see whether `Reassert` runs at all (the event-driven path is known to work — that is what the
spellbook/`ACTIONBAR_SHOWGRID` trick exercised — so the post-hook path must be tested separately).

### FINDING 4 ★ — GB's bars jump to Edit Mode positions on COMBAT ENTRY · `~/GloomsBars` · CONFIRMED
Owner-reproduced on the PTR 2026-07-25 and **confirmed ABSENT on live** — a real 12.1 change.
Practically the most disruptive finding so far: it fires on **every pull**, not on a rare UI action.

- Symptom: enter combat → all owned bars snap back to Blizzard/Edit-Mode geometry. Leave combat →
  they return to GB's layout on their own.
- **The recovery half is CORRECT, not a bug.** [Layout.lua:281](../../GloomsBars/Layout.lua#L281)
  sets `pending = true` and returns without touching geometry in combat; `PLAYER_REGEN_ENABLED`
  ([:82-83](../../GloomsBars/Layout.lua#L82-L83)) flushes it. That is GB's documented HARD WALL —
  all geometry applies out of combat only.
- **The bug is the trigger:** on 12.1 *something re-lays the bars when combat starts*, which never
  happened on live. GB's wall then means it cannot recover until combat ends.
- Suspects, none confirmed: GB's `vis` overrides (the owner's profile has 8 `hide` / 6 `show`) make
  Blizzard re-run its visibility + grid passes; and/or GB's re-assert post-hooks
  (`hooksecurefunc` on `UpdateGridLayout`/`UpdateShownButtons`/`UpdateVisibility`/`ApplySystemAnchor`)
  are being blocked by 12.1's protected-frame lockdown.
- **Fixing it may mean questioning the hard wall itself** — GB re-anchors *unprotected containers*,
  not secure buttons, and moving an unprotected parent in combat is normally allowed (hiding is the
  restricted operation). Whether the wall is broader than it needs to be is a real design question
  for a GB session, NOT a quick patch. Do not "just try it" without understanding why the wall
  was drawn where it was.

### FINDING 2 — a missing font kills the whole display · `~/GloomsAuras` · **NOT a 12.1 bug, affects LIVE**
Found incidentally during PTR testing 2026-07-25; nothing to do with 12.1, and worth fixing on its own.

[Displays.lua:379](../../GloomsAuras/Displays.lua#L379) reads
`if not f.label:SetFont(font, size, flags) then f.label:SetFont(fallbackFont, …) end`. That guard
assumes `SetFont` **returns false** on a bad asset — it does not, it **raises a Lua error**. So the
fallback never runs, `ApplyConfig` aborts mid-function, and `SetTextColor` / `SetText` / `SetPoint` /
`Show` / `ApplyGlow` are all skipped: the display breaks entirely, not just its text.

- Trigger: any aura whose text font points into an addon that isn't installed. The owner's config
  references **three** external addons — `ArcUI` (×2), `NiceDamage`, `EnhanceQoL` — so this fires the
  moment any of them is uninstalled.
- **This will hit friends/guildies the first time the suite is shared**, because their addon sets
  won't match the owner's. It is not a PTR-only concern.
- Fix (one line, NOT yet written): `pcall` the first `SetFont` and fall back on failure.

### FINDING 3 ★★ — GA cannot read ANY aura detail in combat · `~/GloomsAuras` · **CONFIRMED, the big one**
Proven 2026-07-25 on 12.1.0.68914 with GA's own `/ga capture` → `/ga probe`, on a Warlock with
Agony/Corruption/Unstable Affliction/Haunt on a training dummy. **This is the finding the PTR test
existed to get.**

**Mechanism.** In combat, 12.1 returns the **aura instance ID as a SECRET value**. GA passes that
secret into `C_UnitAuras.GetAuraDataByAuraInstanceID` / `GetAuraDuration` and **the call throws.**
Every DoT logged identically:

```
frame:  IsShown=true IsActive=true | auraInstanceID=SECRET(number) present=true | expUnit=target
aura:   player[THREW] target[THREW] | dur player[THREW] target[THREW]
stacks: player[THREW] target[THREW]
```

**The gate is combat, and it is proven, not assumed.** Across 7 probes: out of combat → 51 secrets,
**0 throws**; in combat with real aura instances → **60 throws**. Two other in-combat probes threw
nothing because that character had no target debuffs, so `noID` short-circuited before any call.
The APIs themselves are all still present (`ByInstanceID=true GetAuraDuration=true …`) — they exist
and then refuse.

**What survives: PRESENCE ONLY.** A non-nil secret still proves the aura is there, so `present=true`
and `IsActive=true` are reliable. GA can know Agony is on the target; it **cannot** know duration,
stacks, or expiry. That is exactly Blizzard's stated intent — display filtered aura sets, no access
to the underlying data.

**Why nothing appeared on screen:** the throws are inside `pcall`s, so the failure is SILENT —
**BugSack stayed completely clean while every DoT display failed to light up.** Do not treat a clean
sack as a pass anywhere in this work.

**Scale: this is a migration, not a patch.** Every duration/stack-driven display in GA is affected.
Blizzard's sanctioned replacement is the new `AuraContainer`/`AuraButton` frame types (presentation
control, no data access); lookups **by spell ID or name** remain available for non-secret spells and
are the other half of the answer. NOT yet designed, NOT started. This is the "deep design work inside
ONE tool" shape that earns its own session in `~/GloomsAuras`.

**Not affected:** cooldown data via `C_CooldownViewer` (the owner's SV Hunter auras ran clean), and
presence-only displays.

**★ THE ESCAPE ROUTES WERE TESTED AND ALL THREE ARE CLOSED** (2026-07-25, via `SecretScan` — a small
local diagnostic addon in the retail AddOns folder, extended this session with `byname`, `api` and
`newapi` modes; it is NOT in any repo). Blizzard's exact wording, worth quoting because it names the
real gate: **`Auras cannot be accessed when secret while tainted by '<addon>'`** — the gate is
**taint**, not combat. Combat is merely when auras become secret.

| Channel tried, in combat, DoTs on target | Result |
|---|---|
| `GetAuraDataByIndex` (enumeration) | **THREW** — taint message above |
| `GetUnitAuras(unit)` / `GetUnitAuraInstanceIDs(unit)` | **THREW** — same message. ★ these are the only way to OBTAIN an instance ID |
| `GetAuraDataBySpellName` | **nil** — channel open, declines to return secret auras |
| `GetUnitAuraBySpellID` / `GetCooldownAuraBySpellID` | **nil** |
| `GetAuraBaseDuration`, `GetAuraApplicationDisplayCount`, `DoesAuraHaveExpirationTime` | THREW — but fed a *spell* ID, and they likely want an *aura instance* ID, so this row is INCONCLUSIVE |

**Why the inconclusive row doesn't matter:** those display accessors need an aura instance ID, and
the two bulk accessors that produce instance IDs are taint-blocked. The entry point is closed, so
the read path is unreachable regardless. Everything works normally OUT of combat.

**Three options for GA, none costed yet:**
1. **`AuraContainer`/`AuraButton`** — Blizzard's sanctioned path. The container gathers auras
   untainted; GA styles buttons and never touches data. Biggest rework, but the supported road.
2. **Combat-log tracking** — derive DoT timers from `COMBAT_LOG_EVENT_UNFILTERED` application/refresh
   events plus known base durations, the way addons did before instance IDs existed. CLEU is not on
   any 12.1 restriction list. Real work (pandemic refresh, haste scaling) and unverified — but it
   would keep GA's current look exactly.
3. **Presence-only degradation** — keep the icon, drop the timer. Cheapest, and a real loss.

Decide this in a GA session, not here.

### The suspected cause class, for whatever comes next
12.1's headline addon change is a security lockdown: **"Forbidden Aspects"** on protected frames
blocking `UntrustedScriptExecution`, `EventRegistrations`, `ScriptedInput` and `QueryFocus`, plus
aura APIs by index/slot/instance-ID erroring **during combat/encounters/M+/PvP** (by spell ID or
name still works). GB carries ~40 `hooksecurefunc` calls ([Skin.lua](../../GloomsBars/Skin.lua),
[Glows.lua](../../GloomsBars/Glows.lua), [Layout.lua](../../GloomsBars/Layout.lua)) — that's the
exposure surface. **GA is the bigger unknown:** [CDM.lua](../../GloomsAuras/CDM.lua) calls
`C_UnitAuras.GetAuraDataByAuraInstanceID` in ~8 places and `GetAuraDuration` in 4, several already
`pcall`-wrapped against an older taint issue.

### ⚠ WHAT REMAINS UNTESTED
- **MM Hunter's auras** — the pre-season priority above. Only SV's two auras were ever run.
- **Real instanced content** (dungeon / M+ / raid). All testing was open-world on a training dummy.
  Combat alone was enough to trigger FINDING 3, so instanced content is expected to be no better —
  but "expected" is not "verified."
- **GB's ~40 `hooksecurefunc` calls** against the Forbidden Aspects lockdown. Only the Edit Mode
  path (FINDING 1) surfaced; the skinning hooks were never exercised beyond a normal login.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

Other 12.1 notes worth knowing: new interface texture filenames stop publishing to
`ManifestInterfaceData`; new `VectorGraphics` object type gives **SVG textures**; radial masking via
`SetRadialProgressBarPercent()`; `getglobal`/`setglobal` deprecated; `UIParentLoadAddOn` →
`LoadAddOnWithErrorHandling`. Community-projected release **~2026-08-11**, not Blizzard-confirmed.

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
Where the Overlays GO logo belongs inside the tab (NOT a splash — see the polish backlog).
(~~shared-footer contents~~ — CLOSED 2026-07-25: the footer lists every installed addon's version.
~~stray `BoordensStreet.otf`~~ — CLOSED 2026-07-25: **dropped**, see to-do 5.)
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
- ✅ **DONE + QA'd 2026-07-25.** ~~**Overlays: Width / Height / X / Y should be SLIDERS, not typed
  boxes (the owner, Phase E gate B QA 2026-07-24).**~~ "It just needs to happen." Shipped as
  `UI.sliderRow` + a typed box in the row's value slot, in two columns, with the nudge arrows
  kept — full record in to-do item 2 above.
- **★ GB is the UI reference for the suite, not GA (the owner, 2026-07-24).** When a pattern
  exists in both, copy Gloom's Bars. The two backlog items above are why.

## How to keep this honest
Any session that edits GB/GA/Overlays/Hub **for suite reasons** updates the relevant phase row
here before finishing. A phase is "DONE" only when its SUITE-PLAN QA gate has been met by the owner;
mark "in progress" until then.
