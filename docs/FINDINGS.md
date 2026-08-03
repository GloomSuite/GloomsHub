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

**Last updated:** 2026-07-30

---

## §1 — GA cannot read ANY aura detail in combat on 12.1 ★

### ▶ UPDATE 2026-07-30 — Blizzard's own 12.1 notes CONFIRM this, and REFRAME the size
Source: <https://warcraft.wiki.gg/wiki/Patch_12.1.0/API_changes> — read the aura and secret-value
sections before working this item.

**`TESTED` by Blizzard's documentation, not just by us.** APIs reaching aura data "via index, slot,
or instance ID will Lua error when called by addons while auras are secret". That is exactly the
call GA makes. Three things are WORSE than this finding originally recorded:

- Secrecy covers **combat, encounters, M+ and PvP matches** — not just "in combat".
- **`UNIT_AURA` now delivers a fully secret payload**; AuraData structs are "always fully secret".
- **Many healer auras lost never-secret status** — Rejuvenation, Power Word: Shield, Beacon of Light
  and numerous spec auras were removed from that list.

**★ But the blocker is NARROWER than "a migration", and that changes the estimate.** GA already owns
the sanctioned pass-through route and uses it today: `Displays.lua:298` hands a duration OBJECT
straight to `f.bar:SetTimerDuration`, and `CDM.lua:573` records that `SetCooldownFromDurationObject`
does not throw for one. **GA never needs to READ the number.** The single blocker is that
`GetAuraDurationObject` (`CDM.lua:38`) gates on two instance-ID calls before it can get the object.
This is the same principle GB already ships for cooldowns (its hidden proxy `Cooldown` widget).

**★ THE REMAINING QUESTION — narrow, and NOT as open as it first looks.** ⚠ Read the `TESTED` escape-
route table further down THIS finding before getting excited: **`GetAuraDataBySpellName`,
`GetUnitAuraBySpellID` and `GetCooldownAuraBySpellID` were all tested on 2026-07-25 and all return
`nil` for secret auras.** The spell-ID channel is open but declines to hand anything back — so there
is usually no object to pass through in the first place.

What is genuinely untested is one sibling: **`C_UnitAuras.GetPlayerAuraBySpellID`** (player-only,
never probed — the 2026-07-25 run used `GetUnitAuraBySpellID`, a different function). If it returns
an AuraData whose secret `duration`/`expirationTime` can be **fed to a widget** rather than read,
item 1 collapses to a patch.

**Honest prior: low.** Three sibling spell-ID channels already return `nil`. Test it because it is
cheap and it settles the item, not because it is likely.

⚠ **Do not settle this from the wiki either way.** That page states the `GetPlayerAuraBySpellID`
spellID parameter "requires non-secret aura access", which appears to contradict its own general
statement that spell-ID APIs still work. **Resolve it in-client on the PTR.**

### ⚠ 2026-07-30 — option 1 in "Three options" below may now be DEAD
The option list further down offers **`AuraContainer` / `AuraButton`** as "Blizzard's sanctioned
path". Blizzard's 12.1 notes undercut it:

- **"AuraButtons are now forbidden … APIs called on them via tainted code will Lua error … whenever
  auras are secret."** Addon code is tainted code. That is the whole styling surface.
- **"Addons are no longer allowed to reparent aura buttons"**, and child components "can no longer be
  re-parented once configured".
- Aura containers showing aura groups "will no longer receive OnSizeChanged updates".

`SUSPECTED`, not tested — but **price option 1 again before choosing it.** It was recorded as the
supported road, and the road may have been closed since.

**Possibly relevant, `UNTESTED`:** 12.1 adds `C_UnitAuras.GetHiddenGroupBuffs` /
`SetHiddenGroupBuffs` and `C_CooldownViewer.GetGroupBuffItems`. GA hides Blizzard's CDM icons by its
own means today; these may be the sanctioned replacement.

---

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

**★ `TESTED` 2026-07-26 — presence-only survival is now proven on the Hunter, both aura classes.**
See **§7**. This bounds §1: the broken thing is the *data* path, and a profile that never asks for
duration or stacks is untouched. The owner's MM profile is one of those; his Warlock profile is not.

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
- ~~**MM Hunter's auras.** Only SV's two auras were ever run.~~ **DONE 2026-07-26 — see §7.**
  Both structural classes tested; MM is safe.
- **GB's ~40 `hooksecurefunc` calls** against the Forbidden Aspects lockdown. The bar-layout hooks
  are now proven ALIVE (measured 2026-07-26); the **skinning** hooks were never exercised beyond a
  normal login — **and §8 is the first real symptom out of that gap.**
- **Real instanced content** (dungeon / M+ / raid). All testing was open-world on a training dummy.
  Combat alone was enough to trigger §1, so instanced content is `SUSPECTED` to be no better — but
  "expected" is not "verified."
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

### PTR setup — done 2026-07-25, **and it has since DRIFTED**
`_ptr_` is **12.1.0.68914** (`wowt`); retail is 12.0.7.68887. `_ptr_/Interface/AddOns/` has the four
suite addons plus `!BugGrabber`, `BugSack`, `SecretScan`, and the three addons GA's config
references by path (`ArcUI`, `NiceDamage`, `EnhanceQoL` + its 15 modules — without them a font path
404s and trips §2). Live SavedVariables were copied across. TOCs deliberately left at `120007` —
"Load out of date AddOns" is enough.

**★★ `TESTED` 2026-07-26 — the client no longer matches the paragraph above, and it produced a
convincing false 12.1 bug.** Also installed: **`EllesmereUI`** (a full UI-replacement suite —
`ActionBars`, `UnitFrames`, `Nameplates`, `CooldownManager`, `BlizzardSkin`, `Basics`, ~20 modules)
and `CopyThat`. **The owner keeps most Ellesmere modules OFF on retail; the fresh PTR install turned
them ALL ON.** `EllesmereUICooldownManager` was fighting GA over the same four Cooldown Manager
viewers, and `EllesmereUIActionBars` sits alongside GB (that one he had already disabled).

**Read the addon list BEFORE attributing anything to 12.1 on this client.** Two of three symptoms in
the 2026-07-26 session had a competing addon sitting in the folder as a simpler explanation.

### `KILLED` — do not revive this
- ~~*"GA's 'hide Blizzard CDM icons' toggle is broken on 12.1 — it reverts on `/reload` and on
  acquiring a target, the same shape as §3's bars."*~~ **FALSE — it was an addon conflict.**
  `EllesmereUICooldownManager` re-lit the viewers; the owner disabled that module and the icons
  stayed hidden. GA's `ApplyBlizzardHide` works correctly on 12.1: it had dimmed all four viewers at
  login, and the fingerprint that gave it away was **`BuffBarCooldownViewer` still sitting at
  `alpha=0`** while the three viewers with visible content had been reset to 1 — Ellesmere left the
  empty one alone. `UpdateSystemSettingOpacity` still exists on 12.1 and GA's re-assert hook was
  installed on all four. **The analogy to §3 was seductive and wrong.**

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

### ✅ SOLVED 2026-07-26 — and the "low exposure" reasoning was WRONG

**`TESTED` — all three routes are closed.** Fixed by making `UI.setFont` `pcall` and return whether
the face applied (lib MINOR 5), plus `GB.SetFontSafe` for the bar engine. Owner-QA'd in-client the
same day: a deliberately broken catalog entry now warns by name, the media catalog still registers,
and a dead LSM font applied to GB's keybind text falls back visibly instead of raising.

### `KILLED` — do not revive this reasoning
- ~~*"The exposure is LOW; GB and the Hub store an LSM NAME, not a path, so a miss falls back to a
  valid bundled file — this is a tidy-up, not a bug."*~~ **FALSE, and it was the whole basis for
  deferring this item.** The premise is true of the *tools* and false of the *Hub*, which is the
  catalog OWNER and therefore the one component that builds paths out of saved data. Three live
  routes existed:
  1. **`Media.lua:79` → `WarmFonts` → `drawPair` → `UI.setFont`** — warm pairs built as
     `FONT_PATH .. entry.file` straight from `GloomsHubDB.fonts`. Warming runs BEFORE the
     registration loops and its PEW call site is not `pcall`-ed, so **one dead entry aborted
     `RegisterAll` and NO fonts and NO textures reached LSM at all.** Same blast-radius shape as §2.
  2. **LSM poisoning across repos.** `RegisterFont` registers a dead path under a friendly name and
     LSM does not verify files, so GB's `resolveFont` *succeeded* and returned a dead path — the
     `Fetch(…, true)` silent-nil fallback cannot help when the name really is registered. GB's four
     engine writes had **no guard at all**.
  3. **GA was still exposed through the shared toolkit** — `GloomsAuras/Config.lua:1833` passes
     `item.path`, a saved raw path, into the lib's `setFont`. `GA.SetFontSafe` never covered it
     because it is not GA's function.

**The durable shape to check for is not "stores a path" — it is "builds a path from saved data."**
The catalog owner always does. Promoted to [LESSONS.md](LESSONS.md).

### `UNTESTED` — one question the fix deliberately leaves open
Warming now doubles as an existence probe (the only one the client permits — there is no filesystem
API). **Registration is deliberately NOT gated on it:** WoW indexes fonts at launch, so a font added
this session with a restart pending may fail the probe while being perfectly valid. Nobody has
tested which way that goes. Until someone does, the probe stays advisory — silently dropping a good
font would be worse than the bug this fixed. Pinned in [CONTRACTS.md](CONTRACTS.md) §4.

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

### ✅ CLOSED 2026-07-26 — no action, no consequence found

**`TESTED` — the strongest natural test available produced no symptom.** With a dead LSM font
selected for GB's keybind text, a dead path ran through `SetFontSafe` on **all 116 buttons** on every
skin pass — the same execution path as GB's ~40 `hooksecurefunc` calls and the protected bar frames,
i.e. the one place in the suite a force-taint could plausibly bite. Owner then fought a training
dummy using keybinds and stance swaps: **no blocked actions, no "Interface action failed because of
an AddOn", no errors.**

**What that is worth, and what it is NOT.** The fallback face demonstrably applied, so we know the
dead path was hit. We did **not** confirm the taint itself fired — that needs `taintLog`, which was
deliberately not enabled (it costs performance and floods the log; it is the tool for tracing a
symptom, not for discovering whether one exists). So the honest statement is: *even assuming the
force-taint fired, nothing was blocked.* That is enough to stop treating this as a live risk. It is
**not** a proof of inertness, and it must not be written up as one.

**Stop here.** Do not build anything on this, and do not re-raise it without a real symptom.

---

## §7 — MM Hunter is NOT affected by §1 ✅ SETTLED

**Repo:** `~/GloomsAuras` · **Status: `TESTED`** — 2026-07-26 on PTR 12.1.0.68914, Gloomrift
(Marksmanship, spec 254), 14 `/ga capture` probes at a training dummy, read from
`GloomsAurasDB.probeLog` on disk rather than from chat.

**The premise the backlog carried was wrong.** It assumed Precise Shots and Spotter's Mark might be
*duration*-driven and so land on §1's broken path. They are not. Every display in the owner's
**MM Hunter** group triggers on presence or cooldown readiness — `d19` Precise Shots `buff_active`,
`d20` Spotter's Mark `buff_active`, `d18` Aimed Shot `cd_ready`+`cd_ready`+`buff_inactive` — and
`CDM:EvalCondition` (`CDM.lua:213`) resolves those off the `buffActive` boolean table, never an
aura read.

**`TESTED` — the presence signal sets AND clears in combat.** Both structural classes, which is the
part that matters:

| Item | `hasAura` | Result |
|---|---|---|
| Precise Shots, Deathblow | `false` | on → **off** → on, clean each time |
| Spotter's Mark, Take Aim | `true` | four full on/off cycles |

`IsActive` came back a **plain boolean in both directions, never secret**, while the same probe line
showed `aura: player[THREW] target[THREW]`. §1 is fully reconfirmed on the Hunter — the *data* path
is just as dead as it is for the Warlock — but presence is intact and that is all this profile asks
for. **Owner confirmed the red Spotter's Mark texture drew on screen**, so this is end-to-end, not
signal-only.

**The `RepollBuffPresence` fallback is what carries it.** `CDM.lua:541` calls
`GetAuraDataByAuraInstanceID` inside a `pcall`; in combat that throws, `present` goes false, and
line 549 falls back to `frame:IsActive()`. ⚠ **The residual risk is line 550:** if `IsActive` ever
returns a *secret*, the code keeps the previous value and an expired buff stays lit forever. It
never did across 14 probes — but that is the failure mode to check first if this ever regresses.

**Blizzard mislabels Spotter's Mark** — `selfAura=true` / `expUnit=player` for an aura the tooltip
puts on the target. Moot in combat: both `player[]` and `target[]` throw, so the fallback bypasses
unit resolution entirely and `CDM.lua:417`'s workaround is not load-bearing here.

### `KILLED` — do not revive this
- ~~*"`GetSpecialization` is gone on 12.1, so GA's spec-gated groups fail closed (`CDM.lua:291`
  returns false on a nil specID) and the whole MM Hunter group renders nothing."*~~ **FALSE.**
  Raised because the probe header printed `spec=?`. Tested directly in-client:
  `GetSpecialization` → `function`, index `2`, `GetSpecializationInfo` → `254`. The globals are
  alive and the gate works. **The `spec=?` was the probe's own bug** — `CDM.lua:1455` reads the
  *second* return (the name), which is empty on 12.1 while the ID is fine. A cosmetic fault in the
  instrument, misread for two minutes as a fault in the thing measured.

---

## §8 — Quick Keybind Mode cannot bind over a button's centre ✅ CLOSED — not a GB bug

**Repo:** `~/GloomsBars` · **Status (2026-07-26): NON-REPRODUCIBLE on both clients · the recorded
mechanism is `KILLED` · cause UNKNOWN · GB exonerated of blocking the binding.**

**★ But the investigation found a DIFFERENT, real GB bug — the gold square itself — and it is
FIXED.** See "the gold overlay is NOT innocent" below. The owner spotted it; three replies in a row
had dismissed it as cosmetic noise.

**Symptom (was real, is gone).** In Quick Keybind Mode the owner saw Blizzard's faint gold highlight
on every button and could not assign a binding while the pointer was over one; the button's edge
bound normally. Seen on PTR 12.1.0.68914 with `/fstack` readings recorded.

### `TESTED` 2026-07-26 — it stopped reproducing on the PTR too, mid-investigation
Same client, same GB code, Quick Keybind Mode entered, gold overlays visible as before — and the
binding **assigns through the centre**. The owner is confident the original symptom was real, and
the recorded readings support that; what is gone is any way to observe it.

### `TESTED` 2026-07-26 — it does NOT reproduce on live, and that disproves the cause
Owner ran `/fstack` on **live**, Quick Keybind Mode ON, pointer on the centre of `ActionButton4`.
The marked frame is `ActionButton4.TextOverlayContainer` at **56**, the button at **52**, gold
`QuickKeybindHighlightTexture` present at 52 — **the exact stack the PTR session blamed** — and
**the binding assigns normally**. So the raised container cannot by itself be what blocks binding.

### `KILLED` — "`/fstack` named the caller"
The PTR session read `/fstack`'s `-->` arrow as *mouse focus*. It is not; it is the **topmost frame
under the cursor**, mouse-enabled or not. Proof from the same live pass: on the button's EDGE the
arrow marks `ActionButton2.88c996040` at level 54 — GB's own decor frame, created at
`Skin.lua:1290`. **`Skin.lua` contains no `EnableMouse` call at all** (grepped whole repo,
2026-07-26) and frames are mouse-disabled by default, so that frame cannot be a mouse focus.

Everything built on that reading falls with it: we have **no evidence `TextOverlayContainer` is even
mouse-enabled**, and none that Quick Keybind's hover is being intercepted.

**Still true and still deliberate.** `Skin.lua:1378` raises `TextOverlayContainer` to
`btn:GetFrameLevel() + 4` so hotkey and count text clear GB's skin layers (plate `+1`, decor `+2`,
glow `+3`); intent documented at `Skin.lua:790`. **Do not lower it** — see `~/GloomsBars/docs/HANDOFF.md`.

### ~~The gold overlay is innocent~~ `KILLED` 2026-07-26 — it was a real bug, now FIXED
`QuickKeybindHighlightTexture` is innocent of *blocking the binding* — it sits at the button's own
level 52. **That is not the same as being fine, and it was recorded as if it were.** It was the ONE
button-state texture GB's skin never adopted: not retextured, not masked, not fitted, so it drew
Blizzard's square art at Blizzard's size, standing proud of a shaped icon.

**Fixed 2026-07-26, owner-QA'd.** Hand shape → suppressed, with a shaped inner-only gold glow
carrying the state (`Glows.lua`, `keybind` trigger); SDF fallback → Blizzard's art, anchored to the
icon like its three siblings. Full record in [ARCHIVE.md](ARCHIVE.md); GB-side reasoning in
`~/GloomsBars/docs/HANDOFF.md`.

⚠ **The lesson is the dismissal, not the bug.** "It is not the culprit" was restated three times as
though it settled the question. The owner had to raise the gold square a fourth time, saying *"you
don't say anything about it"*, before anyone looked at it. **Ruling something out as a CAUSE does
not rule it out as a DEFECT.**

**`EnableMouse(false)` on the container was the `SUSPECTED` fix. It was never written and must not
be** — its premise is the dead reading above, and there is no longer a symptom for it to fix.

### What the cause probably is — `SUSPECTED`, and deliberately not chased
The PTR carries a full competing UI suite (§4), which has already manufactured one convincing false
12.1 bug. The owner disabled several of its modules between the original observation and the
re-test, which fits the timing. **But its action-bars module was already disabled when the symptom
first appeared**, so no specific module is implicated and the cause is genuinely unknown.

**Not chased on purpose.** Reproducing it would mean re-enabling modules one at a time across a
20+ module suite, to chase a PTR-only annoyance with a working sidestep (bind from the edge, or from
the Keybindings list). The owner's time is better spent elsewhere. **If it returns, start here —
with `GetMouseFoci()`, not `/fstack`.**

### The durable lesson
`/fstack` answers *"what is drawn on top here?"* — **never** *"what has mouse focus?"* Two sessions'
worth of diagnosis, a named mechanism, a table of frame levels and a proposed one-line fix all rested
on that one substitution, and GB was very nearly changed to fix a bug it never had. Mouse focus is
`GetMouseFoci()` and nothing else.

---

## §9 — Blizzard's damage meter breaks under ANY addon taint ✅ CLOSED — not our bug

**Repo:** none of ours · **Status: `TESTED` 2026-07-30 on LIVE 12.0.7 build 68887**, by the owner's
own addon bisect. **Nothing to do. Do not re-diagnose.**

**Symptom.** In combat, `Blizzard_DamageMeter` throws hundreds of errors per refresh, and the meter
displays **wrong player names and class icons** — the owner saw them mismatched across rows after a
dungeon. Not cosmetic: the first failure aborts `UpdateName`, and because `ScrollBoxListView`
recycles row frames, rows keep the previous occupant's name and class.

**Cause — Blizzard's.** Their code compares secret values directly at two sites:
`DamageMeterEntry.lua:87` (`sourceDisplayType`) and `DamageMeterSessionWindow.lua:930`
(`durationSeconds`). Those comparisons are only legal on an untainted path. **Any loaded addon
taints paths** — that is what addons do — so the meter is broken for essentially every addon user.

**`TESTED` — three unrelated addons, each as the ONLY non-Blizzard addon loaded besides BugSack:**
LiteMount (a mount manager), Plumber (a UI utility), TextureAtlasViewer (a texture browser). None of
them interact with the damage meter. With them disabled, no errors and correct display.

**★ ALL FOUR GLOOM ADDONS were loaded throughout the entire bisect and produced nothing.**

### ⚠ SECRET VALUES ARE LIVE ON 12.0.7 — our docs framed them as a 12.1 concern
This is the correction that matters beyond the bug. Backlog item 2 is still titled "the 12.1
exposure sweep", and §1 reads as a future problem. **Part of that exposure is already shipping on the
live client the owner plays every day.** Weigh that when planning the sweep.

### `KILLED` — "addons that use Blizzard's shared ScrollBox machinery are the ones that taint it"
A scan showed LiteMount (26 uses), Plumber (7) and, as a negative control, EllesmereUI (0, and it did
NOT trigger the bug) — five-for-five, presented as a mechanism. **TextureAtlasViewer then triggered
it with a score of zero**, using only the old `ScrollFrameTemplate`. The correlation was an artifact
of a tiny sample. **There is no known code pattern that predicts which addons trigger this**, which
is itself consistent with the plain reading: almost anything taints.

**Owner is filing it with Blizzard** — the repro is unusually clean (single addon + error catcher,
exact file and line), so it has a real chance of a hotfix.
