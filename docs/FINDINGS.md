# Gloom Suite — FINDINGS (provisional until tagged otherwise)

> **Everything in this file is DIAGNOSIS, not settled state.** That is the whole reason it is a
> separate file from [SUITE-STATE.md](SUITE-STATE.md): a guess written next to a fact inherits the
> fact's authority. Here, the default reading is *unproven*.
>
> ## Every claim carries an evidence tag. No exceptions.
> | Tag | Means | You may act on it? |
> |---|---|---|
> | `TESTED` | Established by a test. **Says how, when, and on what.** | Yes. |
> | `OBSERVED` | The symptom was seen. The cause is not proven. | No — test the cause first. |
> | `SUSPECTED` | Reasoning only. Nobody has run anything. | No. Test it, or state it as an assumption. |
> | `KILLED` | Disproved. Kept by name so it is not revived. | Never. Do not "just try it again." |
>
> **The rule that exists because it was nearly violated on 2026-07-26:**
> **you may not build a fix on an `OBSERVED` or `SUSPECTED` claim without establishing it first.**
> A GB session came within one step of building a fix for a bug that did not exist, because this
> file's ancestor recorded two suspicions in the same confident voice as its measurements. It
> re-tested instead, and both suspicions turned out to be false. Re-testing is the rule, not the
> heroism.
>
> **When a claim is disproved, strike it through and move it to the KILLED list under its finding.
> Never delete it** — a silently removed theory gets re-derived by the next session.

**Last updated:** 2026-07-26

---

## §1 — GA cannot read ANY aura detail in combat on 12.1 ★

**Repo:** `~/GloomsAuras` · **Status: `TESTED`** — 2026-07-25 on PTR 12.1.0.68914, via GA's own
`/ga capture` → `/ga probe`, on a Warlock with Agony / Corruption / Unstable Affliction / Haunt on a
training dummy.

**Mechanism.** In combat, 12.1 returns the aura instance ID as a **SECRET** value. GA passes that
secret into `C_UnitAuras.GetAuraDataByAuraInstanceID` / `GetAuraDuration` and **the call throws.**

```
frame:  IsShown=true IsActive=true | auraInstanceID=SECRET(number) present=true | expUnit=target
aura:   player[THREW] target[THREW] | dur player[THREW] target[THREW]
stacks: player[THREW] target[THREW]
```

**`TESTED` — the gate is combat.** Across 7 probes: out of combat → 51 secrets, **0 throws**; in
combat with real aura instances → **60 throws**. Two further in-combat probes threw nothing only
because that character had no target debuffs, so `noID` short-circuited before any call. The APIs
are all still present — they exist and then refuse.

**`TESTED` — what survives is PRESENCE ONLY.** A non-nil secret still proves the aura is there, so
`present=true` and `IsActive=true` are reliable. GA can know Agony is on the target; it cannot know
duration, stacks or expiry. That is Blizzard's stated intent.

**`TESTED` — the failure is SILENT.** The throws are inside `pcall`s. **BugSack stayed completely
clean while every DoT display failed to light up.** Do not treat a clean sack as a pass anywhere in
this work.

### `TESTED` — all three escape routes are closed
Via `SecretScan`, a small local diagnostic addon in the retail AddOns folder (extended 2026-07-25
with `byname`, `api` and `newapi` modes). **It is not in any repo.** Blizzard's exact wording names
the real gate: **`Auras cannot be accessed when secret while tainted by '<addon>'`** — the gate is
**taint**, not combat. Combat is merely when auras become secret.

| Channel tried, in combat, DoTs on target | Result |
|---|---|
| `GetAuraDataByIndex` (enumeration) | **THREW** — taint message above |
| `GetUnitAuras(unit)` / `GetUnitAuraInstanceIDs(unit)` | **THREW** — ★ these are the only way to OBTAIN an instance ID |
| `GetAuraDataBySpellName` | **nil** — channel open, declines to return secret auras |
| `GetUnitAuraBySpellID` / `GetCooldownAuraBySpellID` | **nil** |
| `GetAuraBaseDuration`, `GetAuraApplicationDisplayCount`, `DoesAuraHaveExpirationTime` | THREW — but fed a *spell* ID when they likely want an *aura instance* ID. **INCONCLUSIVE** |

**Why the inconclusive row does not matter:** those accessors need an aura instance ID, and the two
bulk accessors that produce instance IDs are taint-blocked. The entry point is closed, so the read
path is unreachable regardless.

**`TESTED` — not affected:** cooldown data via `C_CooldownViewer` (the owner's SV Hunter auras ran
clean), and presence-only displays.

### Three options, none costed
1. **`AuraContainer` / `AuraButton`** — Blizzard's sanctioned path. The container gathers auras
   untainted; GA styles buttons and never touches data. Biggest rework, the supported road.
2. **Combat-log tracking** — derive DoT timers from `COMBAT_LOG_EVENT_UNFILTERED` plus known base
   durations, as addons did before instance IDs existed. `SUSPECTED` viable: CLEU is not on any 12.1
   restriction list, but that has not been verified, and pandemic refresh + haste scaling are real
   work. Would keep GA's current look exactly.
3. **Presence-only degradation** — keep the icon, drop the timer. Cheapest, and a real loss.

**Decide this in a GA session.** See [BACKLOG.md](BACKLOG.md) item 1.

---

## §2 — A missing font kills the whole GA display ✅ SOLVED

**Repo:** `~/GloomsAuras` · **Status: `TESTED` and FIXED** — 2026-07-26, owner-QA'd on live 12.0.7.
Kept here for its KILLED list and its two corrections; the full record is in [ARCHIVE.md](ARCHIVE.md).

**The mechanism was right.** `SetFont` **raises** on a missing asset — it does not return false.
Re-proven in-client 2026-07-26: `pcall(fs.SetFont, fs, "<dead path>", 14, "")` →
`false — Invalid font asset (…): file not found`. The guard at `Displays.lua:379` was written on the
opposite assumption, so the fallback never ran and `ApplyConfig` aborted mid-function.

**Fixed by `GA.SetFontSafe`** (`Core.lua`), used at all **three** sites that carried the same wrong
guard — `Displays.lua:379` (the aura label), `Displays.lua:238` (bar value text) and `Core.lua:66`
(`PreloadFonts`). Only the label path is `TESTED` end to end; the other two use bundled fonts that
ship with the addon and are **fixed by inspection**, which is as far as they can be taken.

### Two corrections to the original write-up

**★ The blast radius was UNDERSTATED, and this part is `TESTED`-by-structure, not observed at
runtime.** It is not "the display breaks entirely." `Displays.lua:151` sits *outside* the
`if not f then` create-branch, so `ApplyConfig` re-runs for **every** display on **every**
`GetOrCreate`; and `RefreshAll` is called unguarded at the very top of `CDM:Discover()`
(`CDM.lua:884`). One aura with a dead font therefore aborts Discover before a single display is
bound or hooked — **every aura in the profile goes dead, not just the one with the bad font.**
Established by reading the call chain. Nobody watched it happen, because observing it would mean
un-fixing the bug.

**★ Unlike §1, this failure is NOT silent.** None of the ~15 `Discover()` call sites are `pcall`-ed,
so it surfaces to BugSack.

### `KILLED` — do not revive either of these
- ~~*"The owner's config references three external addons, so uninstalling any of the three fires
  this."*~~ **FALSE.** His SavedVariables contains exactly **one** `["font"]` key —
  `NiceDamage\fonts\pepsi_modern.ttf`, on display `d18` ("Aimed Shot", in the
  `Gloomrift - Stormrage` profile). The `ArcUI` (×2) and `EnhanceQoL` references are **`.ogg`
  sounds**, which never reach `SetFont`. Only NiceDamage could ever have triggered §2.
- ~~*"Disabling the NiceDamage addon reproduces a missing font."*~~ **FALSE, and it cost a full
  client restart to learn.** Disabling an addon stops its Lua loading; it does **not** remove its
  files. `SetFont` reads fonts **by file path**, so the font kept resolving perfectly. To make media
  genuinely missing you must move or rename the folder on disk. Promoted to [LESSONS.md](LESSONS.md).

---

## §3 — GB's bars scattered / jumped to Blizzard positions ✅ SOLVED

**Repo:** `~/GloomsBars` · **Status: `TESTED` and FIXED** — `afd0957` on `main`, pushed, owner-QA'd
on live 2026-07-26. Kept here because its KILLED list is the most valuable thing in this file.

**★★ NOT a 12.1 regression — a latent bug in shipped GB, reproduced on LIVE 12.0.7** on a character
whose bars still sat at Edit Mode default positions. The PTR only exposed it because copied
characters land on a fresh Edit Mode layout. **Do not describe this as a 12.1 issue.** The three
symptoms (scatter on Edit Mode entry, no recovery on exit, jump on every combat entry) were ONE bug.

**Root cause — `TESTED` by a `SetPoint`/`ClearAllPoints` write-trap that named the caller, not
inferred.** `EditModeActionBarMixin:UpdateVisibility` ends by calling
`EditModeManagerFrame:UpdateActionBarLayout(self)` → `UpdateBottomActionBarPositions()`, which
re-anchors **every** bottom-anchored bar in one pass. Two GB design facts turned that into the
symptoms: GB's re-assert post-hooks were **per bar**, so one bar's visibility pass silently moved
the others; and GB hung its grid off the **bar frame**, which Blizzard re-anchors and re-scales at
will, including in combat where GB's hard wall forbids answering.

### `KILLED` — do not revive any of these
- ~~*"GB's post-hooks are dead on 12.1 / Forbidden Aspects blocks them."*~~ **FALSE.** All 40 hooks
  installed and fired (`UpdateVisibility` fired 42× in one measured window). **This was the leading
  theory in the ledger and it was recorded as confirmed. It was wrong.**
- ~~*"GB's `vis` overrides provoke Blizzard's visibility + grid passes."*~~ **FALSE.** Reproduced on
  a profile with `vis=nil` on all ten bars.
- ~~*"`EDIT_MODE_LAYOUTS_UPDATED` no longer firing on Edit Mode exit is the cause."*~~ The event
  change is real and separately confirmed on 12.1, but it only ever explained the *recovery* half;
  the ticker (`80743ee`) already handles it.

### `TESTED` facts worth keeping
- `MainActionBar:IsProtected()` → **true**, so GB may never re-anchor a bar frame in combat.
  "React faster" was never on the table.
- `isInDefaultPosition` is written ONLY in `EditModeManagerFrameMixin:UpdateSystemAnchorInfo`,
  reachable only from Edit Mode's own drag/nudge/snap. There is no event-driven route, so an addon
  can only write it directly — which taints the loop that re-anchors every *other* bottom bar,
  meaning blocked actions in combat on bars GB never touched. **Rejected on that basis; do not
  "just try it".**

**Accepted remaining behaviour:** while Edit Mode is OPEN, Blizzard's grid pass re-anchors the
containers back onto the frame, so a default-position bar visibly returns to Blizzard's spot until
Edit Mode closes. GB stands down inside Edit Mode by design and restores on exit.

---

## §4 — 12.1 readiness: setup, traps, and what is still `UNTESTED`

**★★ The owner's decision, 2026-07-25: WAIT FOR LAUNCH, THEN TRIAGE. Do not re-litigate.** The PTR
APIs are still landing in pieces, so fixing a genuine 12.1 change now means fixing it twice.

**The one principle that overrides it:** *a bug the PTR merely EXPOSED is a live bug, and waiting
for launch buys nothing.* That is why §3 was fixed and shipped immediately.

### `UNTESTED` — the gaps
- **MM Hunter's auras.** Only SV's two auras were ever run. **The pre-season priority** — see
  [BACKLOG.md](BACKLOG.md) item 3.
- **GB's ~40 `hooksecurefunc` calls** against the Forbidden Aspects lockdown. The bar-layout hooks
  are now proven ALIVE (measured 2026-07-26); the **skinning** hooks were never exercised beyond a
  normal login.
- **Real instanced content** (dungeon / M+ / raid). All testing was open-world on a training dummy.
  Combat alone was enough to trigger §1, so instanced content is `SUSPECTED` to be no better — but
  "expected" is not "verified."
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

### PTR setup — done 2026-07-25, still in place
`_ptr_` is **12.1.0.68914** (`wowt`); retail is 12.0.7.68887. `_ptr_/Interface/AddOns/` has the four
suite addons plus `!BugGrabber`, `BugSack`, `SecretScan`, and the three addons GA's config
references by path (`ArcUI`, `NiceDamage`, `EnhanceQoL` + its 15 modules — without them a font path
404s and trips §2). Live SavedVariables were copied across. TOCs deliberately left at `120007` —
"Load out of date AddOns" is enough.

**GB's separate PTR checkout is RETIRED (2026-07-26).** Once §3 proved to be a *live* bug, the fix
belonged on `main` and the split lost its purpose. **All four suite addons now point at their normal
repos on BOTH clients**, so an edit is live on both — remember that before editing during PTR work.
Re-split with a fresh `git worktree` if genuinely 12.1-only code ever becomes necessary.

### ⚠ PTR TESTING TRAP — cost an hour once already
GB and GA both key profiles by **character + realm**, and PTR copies live on **Anasterian** while
every real profile says **Stormrage**. Both addons auto-create *fresh empty* profiles on the PTR.
For GB that means `layoutEnabled` is **off**, `ApplyAll` is a no-op, and any layout test silently
proves nothing. `Gloomwick - Anasterian` has been switched on; **verify before trusting any result.**
(GB's only profiles with layout on are `Gloomrift - Stormrage` and `Gloomfury - Stormrage`.)

### When fixes do start
Feature-gate at runtime (`if C_UnitAuras.GetAuraDataByAuraInstanceID then`), don't fork.
`## Interface: 120007, 120100` supports both clients from one package. Work on a branch — the
owner's live client loads the working tree.

### Other 12.1 notes
New interface texture filenames stop publishing to `ManifestInterfaceData`; a new `VectorGraphics`
object type gives **SVG textures**; radial masking via `SetRadialProgressBarPercent()`;
`getglobal`/`setglobal` deprecated; `UIParentLoadAddOn` → `LoadAddOnWithErrorHandling`.
Community-projected release **~2026-08-11**, `SUSPECTED` only — not Blizzard-confirmed.

---

## §5 — The same false `SetFont` guard survives in the Hub and GB

**Repo:** `~/GloomsHub` + `~/GloomsBars` · Found 2026-07-26 while fixing §2.

**`TESTED` — the guard is wrong wherever it appears.** §2 established that `SetFont` raises. The
identical `if not fs:SetFont(...)` construction is still live in:

| Where | What it is |
|---|---|
| `~/GloomsHub/Skin.lua:70` — `UI.setFont` | **the shared `LibGloomSkin` helper** every tab's text flows through |
| `~/GloomsBars/Config.lua:190`, `:220` | the font flyout rows and the font-picker button |
| `~/GloomsBars/Skin.lua:976`, `:1052`, `:1140` | `SetFont(resolveFont(...))` with **no guard at all** |

**`SUSPECTED` — the exposure is nonetheless LOW, and this is the part to establish before writing
anything.** GA was uniquely vulnerable because it stores the **raw font path** in SavedVariables
(`"Interface\\AddOns\\NiceDamage\\fonts\\pepsi_modern.ttf"`). GB and the Hub instead store an **LSM
name** and resolve at call time — `lsm:Fetch("font", name, true)` with the silent flag returns `nil`
for an unregistered font, and both then fall back to a **bundled** path. An addon that isn't
installed never registered its font, so the lookup misses and the fallback is a *valid* file.

**So the dangerous shape is not the guard — it is storing a resolved PATH rather than a NAME.** That
is the thing to check for elsewhere.

**Untested route worth one look:** whether any caller can hand `UI.setFont` a path that came from
saved config rather than from `FONT.*`. If none can, this is a tidy-up, not a bug.

**Also unchecked:** GA's three `.ogg` sound paths into `ArcUI` and `EnhanceQoL` — the same
"points into an addon that may not be installed" shape, through a different call. `PlaySoundFile` is
believed to return false rather than raise, but that is `SUSPECTED`, not tested.

---

## §6 — A missing font asset force-taints the execution path

**Repo:** unknown · **Status: `OBSERVED`** — 2026-07-26, live 12.0.7, in the same `/run` that proved
§2's mechanism.

Calling `SetFont` with a dead path printed, alongside the expected error:

```
Lua Taint: *** ForceTaint_Strong ***
```

**`pcall` catches the error. It does not undo taint.** So §2's fix stops the crash and leaves this
untouched: on a machine genuinely missing the font, every `Discover()` would still force-taint GA's
execution path.

**No consequence has been demonstrated, and none should be assumed.** GA rarely touches protected
calls, so this may be entirely inert. It is recorded only because the suite leans so heavily on
taint behavior elsewhere (§1's secret values, GB's ~40 `hooksecurefunc` calls, protected bar frames)
that an unexamined force-taint is worth a deliberate look rather than a shrug.

**Do not build anything on this.** Establish a real symptom first — per this file's own rule.
