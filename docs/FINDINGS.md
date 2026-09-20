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

**Last updated:** 2026-09-19, evening (new §17 — what the game will and won't identify for an addon
on a restricted map, measured `/dump` by `/dump` in a delve for Gloom's Portraits. Earlier the same
day: §15 — a DoT REFRESH fires no reliable CDM alert; §16 — the owner's font drew in Friz on EUI's
unit frames. All `TESTED`, all fixed, all owner-QA'd.)
---

## §1 — GA cannot READ aura duration/stacks on 12.1 — but CAN display them via `AuraContainer` ★

### ▶▶▶ SHIPPED 2026-08-12 — this is BUILT and owner-QA'd. Read this block first.
**GA has working duration bars and stack counts on 12.1.** `TESTED` on screen by the owner, live
client, Warlock on a training dummy: Agony and Haunt fill and drain, follow target swaps, show a
live stack count, and coexist with ArcUI loaded. Implementation is `~/GloomsAuras/AuraDuration.lua`
+ `AuraDuration.xml`; the mechanism is the ANSWERED block below and it held up in practice.

**Four things this build established that the 2026-08-03 record got wrong or did not know:**

1. **`TESTED` — stacks are recoverable, from a channel nobody had tried.** A CDM item frame keeps
   `frame.auraDataCached`, a plain NON-secret table whose `.applications` is a SECRET number.
   Reading a field off it is not an instance-ID call and does not throw, and `SetText` renders the
   secret directly. GA's `BarStackValue` had been using the throwing instance-ID call, which is why
   stacks looked as dead as durations. **This closes the "stacks under secrecy" line in the sweep.**

2. **`TESTED` — `AuraContainer` does NOT follow target swaps by itself.** ~~The ANSWERED block below
   claims it does, "since the container is per-unit and Blizzard does the tracking".~~ **FALSE.** A
   target container only reacts to its own unit's `UNIT_AURA`, so a target-debuff bar goes stale
   until the new target happens to fire one. ArcUI carries a `PLAYER_TARGET_CHANGED` →
   `UpdateAllAuras()` workaround for exactly this, and GA now does too. This matters for every one
   of the owner's DoTs, which are all target debuffs.

3. **`TESTED` — the engine does NOT overwrite styling pushed onto its own region.** Read back with
   `GetStatusBarTexture():GetTexture()` immediately before each overwrite: the value always returned
   what GA last set. Styling survives; what does NOT survive is combat, because the button is a
   forbidden object whenever auras are secret. Pushes therefore defer to `PLAYER_REGEN_ENABLED`.

4. **`UNTESTED` — whether an `AuraContainer` can be CREATED in combat is still unknown.** GA now
   attempts it under `pcall` rather than assuming (the "hard Lua error" claim came from a comment in
   ArcUI, never from our own measurement). It has not yet been exercised: after a mid-combat
   `/reload`, creation succeeded while `InCombatLockdown()` was still false, in the window before
   combat re-registers. `/ga auradur` prints `containers created IN COMBAT` if it ever happens.

### ▶ `TESTED` 2026-08-12 — the CDM does not recover an already-applied aura after a `/reload`
**This is a Blizzard limitation, not a GA bug, and it is NOT fixable through the presence mirror.**
Measured over **52 re-poll passes** after a mid-combat reload with four DoTs live on the target:
`frame.auraInstanceID` was **never** bound for any of them, and `frame:IsActive()` returned a plain,
non-secret `false` throughout. There is nothing to read — GA is faithfully mirroring a Cooldown
Manager that has no record of the aura. The display recovers the instant the aura is re-applied,
which is when the CDM finally binds it.

**Three fixes were attempted in `RepollBuffPresence` and all three failed**; the code now carries a
comment saying so. ⚠ **If this is ever worth solving, the route is NOT that function** — Blizzard's
`AuraContainer` DOES repopulate correctly after a reload (its countdown came back when the CDM
mirror could not), so the engine's own slot is a working presence oracle.

**Related, and shipped:** the engine's button is a child of the AuraContainer, not of GA's display,
so hiding a display used to leave a countdown drawing over empty screen. `AuraDuration:SetSlotActive`
now parks the slot's filter when a display hides, which makes the engine release the button.

### ▶▶ ANSWERED 2026-08-03 — the mechanism (still accurate, except point 2 above)
**The route is `AuraContainer`. Everything under "Three options" is settled and the option list is
struck. The 2026-07-30 framing below ("one PTR test decides patch vs migration") is spent — that
test was run and came back negative, and the answer arrived from somewhere else entirely.**

`TESTED` 2026-08-03, PTR 12.1.0.68914, Warlock (Gloomwick, Affliction), training dummy, owner at
the keyboard. Two independent instruments: GA's own `/ga probe` (extended this session) and direct
on-screen observation.

**1 · The data path is dead, and that part of the old record holds.** Every instance-ID call
(`GetAuraDataByAuraInstanceID`, `GetAuraDuration`, stacks) `THREW` for all four DoTs and for
Nightfall. Re-confirmed today, not assumed.

**2 · The DISPLAY path is alive, and nobody had tested it.** The old escape-route table only ever
asked *"can we READ this value?"*. It never asked *"will a SINK accept it?"* — which is the question
that decides the item. Measured, with a plain-number control through the identical call:

| Sink | plain number | SECRET number |
|---|---|---|
| `Cooldown:SetCooldownDuration` | **ok** | **refused** |
| `Cooldown:SetCooldown` / `SetCooldownFromExpirationTime` / `…FromDurationObject` | refused¹ | **refused** |
| **`StatusBar:SetValue`** | **ok** | **★ ok** |
| **`StatusBar:SetMinMaxValues`** | **ok** | **★ ok** |

¹ those three want a different shape (object / timestamp), so their "no" is uninformative — see the
`KILLED` list for why that mattered.

**3 · The widgets hold the value.** A CDM item frame's `GetCooldownFrame()` returns a Cooldown
widget whose `GetCooldownDuration` / `GetCooldownTimes` / `GetCooldownDisplayDuration` all hand back
`SECRET(number)` **without throwing** and without touching any index/slot/instance-ID API.
⚠ **But all three are the TOTAL, not the remaining** — `TESTED` twice by mirroring each to a live
bar: it pins full and never drains. **The icon frame cannot drive a countdown.**

**4 · A Tracked-Bar item frame's `.Bar` CAN.** `GetValue()` → `SECRET(number)`,
`GetMinMaxValues()` → `SECRET/SECRET`, and mirroring both into GA's own StatusBar produced a
correct, accurate, right-to-left draining bar — owner-observed. **Cost: the aura must be in
Blizzard's "Tracked Bars" list**, which is a per-user config step and takes the aura *out* of
Tracked Buffs. This works but is the inferior route; see 5.

**5 · ★ THE ANSWER — `AuraContainer`, read out of ArcUI's working implementation.**
ArcUI shows accurate DoT timers on this exact client with **`rawReads=0`** (its own `/arcsec`
diagnostic) — it reads no aura data at all. Mechanism, from `ArcUI/Bars/ArcUI_BarDuration.lua` +
`.xml`:

- `CreateFrame("AuraContainer", name, UIParent, "CustomAuraContainerTemplate")`, one per unit.
  **Out of combat ONLY** — in-combat creation is a hard Lua error. Then `SetUnit`, `SetEnabled(true)`,
  `Show()`; it must be shown and enabled to self-register `UNIT_AURA`.
- `container:AddAuraSlot(key, filter, { candidateFilters = { includeSpellIDs = {…} },
  templateNames = {…}, initializeFrame = fn })`, then `container:UpdateAllAuras()` so
  already-active auras are picked up immediately rather than on the next `UNIT_AURA`.
- **Inside `initializeFrame` and nowhere else** — the only window in which the button is not a
  forbidden object — call `button:SetDurationBar(<region>, {interpolation, direction})` and
  `button:SetDurationText(<region>, {formatter})`, then anchor the button over your own frame.
  **After that window, ANY API call on the button Lua-errors while auras are secret.**
- ★ **The regions must be owned BY THE BUTTON**, declared in an XML template
  (`<StatusBar parentKey="…"/>`, `<FontString parentKey="…"/>`). **An addon-created frame is
  rejected.** GA ships no XML today, so this route requires adding one.
- The engine renders the drain and the countdown text into those regions. The addon never obtains a
  duration, which is exactly why it survives secrecy — and why it follows target swaps correctly,
  since the container is per-unit and Blizzard does the tracking.

**What this costs GA:** an XML template, container lifecycle (out-of-combat creation, per-unit),
one slot per tracked spell, and strict `initializeFrame` discipline. Bounded work with a complete
reference implementation to copy from. **No Tracked Bars, no CDM dependency, no combat log.**

### ▶ SUPERSEDED 2026-07-30 — Blizzard's own 12.1 notes CONFIRM this, and REFRAME the size
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

~~What is genuinely untested is one sibling: **`C_UnitAuras.GetPlayerAuraBySpellID`**…~~
**`TESTED` 2026-08-03 — it returns `nil`.** Probed against a LIVE, active player aura (Nightfall,
`IsActive=true`, `present=true`, secret instance ID) in combat: `playerAura: nil` on every capture.
It does not throw; it declines, exactly like its three siblings. **The low prior was right.**

⚠ **And this test could never have sized the item anyway** — `GetPlayerAuraBySpellID` is
**player-only**, while the broken case was always *target* DoTs. Calling it "the one test that
decides patch vs migration" was wrong on its own terms. The answer came from `AuraContainer`.

**Also `TESTED` 2026-08-03 and worth recording:** `C_UnitAuras.GetAuraDurationRemaining` — a
*different* function from `GetAuraDuration`, and the one ArcUI's code calls — **does not exist on
this build** (`absent` on every probe). ArcUI guards it with an existence check, so it never runs.

⚠ **Do not settle this from the wiki either way.** That page states the `GetPlayerAuraBySpellID`
spellID parameter "requires non-secret aura access", which appears to contradict its own general
statement that spell-ID APIs still work. **Resolve it in-client on the PTR.**

### ~~⚠ 2026-07-30 — option 1 in "Three options" below may now be DEAD~~ `KILLED` 2026-08-03
**FALSE, and it was the single most expensive wrong belief in this finding.** It was `SUSPECTED`
from reading patch notes, and it steered two sessions away from the one route that works. ArcUI
uses `AuraContainer` + `AuraButton:SetDurationBar` **successfully on PTR 12.1.0.68914** — the same
client this was written on. The patch-note lines quoted below are real, but they describe the
*discipline the API requires* (all button access confined to `initializeFrame`; regions owned by
the button; no reparenting) — **not a closure.** Read the ANSWERED block at the top of §1.
Original reasoning kept below so nobody re-derives it:

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

### `TESTED` — all three escape routes are closed ⚠ **for READING only — see the caveat**
⚠ **2026-08-03: this table is true and it is NOT the whole question.** Every row asks *"can we read
the value?"*. None asks *"will a sink accept it?"* — and the answer to the second question is YES
for `StatusBar:SetValue`. A table like this reads as exhaustive and is not; it tests one family.
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

### ~~Three options, none costed~~ — RESOLVED 2026-08-03, the list is closed
1. **`AuraContainer` / `AuraButton`** — ★ **THIS IS THE ANSWER.** Proven working on 12.1 by a
   reference implementation on the owner's own client. Details in the ANSWERED block at the top.
2. ~~**Combat-log tracking**~~ — **not needed, and don't build it.** It was the fallback for a wall
   that turned out not to exist. It would also be strictly worse: a self-timed bar cannot know about
   pandemic refreshes or haste scaling, so it drifts from the real remaining time. ArcUI ships this
   shape as a separate "timer bar" feature (user-supplied `customDuration`); it is **not** what
   drives its DoT bars.
3. ~~**Presence-only degradation**~~ — moot. Presence already works and now so can duration.

**A fourth route exists and is `TESTED` working, but is inferior:** mirror a Tracked-Bar frame's
`.Bar` via `GetValue`/`SetValue` (point 4 above). Keep it only as a fallback — it costs the user a
Blizzard-side config step per aura and steals the aura out of Tracked Buffs.

### `KILLED` 2026-08-12 — struck during the build
- ~~*"`AuraContainer` follows target swaps by itself."*~~ **FALSE** — recorded in this very finding
  on 2026-08-03 and disproved by the reference implementation, which carries a
  `PLAYER_TARGET_CHANGED` workaround. See point 2 in the SHIPPED block.
- ~~*"The engine re-asserts its own fill texture, so a custom bar texture can never survive."*~~
  **FALSE.** Proposed to explain a texture that appeared to do nothing; disproved by reading the
  texture back before each write — it always returned what GA last set.
- ~~*"The texture push is being wiped because `UpdateAllAuras()` re-acquires the button."*~~
  **FALSE.** Re-ordering the paint after the attach changed nothing.
- ~~*"Bar styling doesn't apply."*~~ **FALSE, and it cost three theories.** It applied correctly
  every time. The editor preview forces GA's own bar to `SetValue(0)` on attach, and out of combat
  there is no live aura for the engine to draw — so the user was styling an invisible bar. Nudging
  a slider "fixed" it only because `MakeSlider` fires an extra `ReapplySelected` afterwards which
  re-fills the bar. **Three separate mechanisms were blamed before anyone checked what was on
  screen belonged to which widget.**
- ~~*"`buffActive == nil` is the right gate for seeding presence after a reload."*~~ **FALSE.** The
  login pass runs before the CDM is ready and writes a confident `false`, so the gate never fired.
  Moot anyway — see the 52-pass result above.
- ~~*"ArcUI's `ArcUI_BarDuration.lua` header describes its current design."*~~ **FALSE.** The header
  documents a two-slot player/target model the code abandoned; it creates one slot routed by the
  caller. **The most authoritative-looking comment in that file is out of date.**

### `KILLED` 2026-08-03 — do not revive any of these
Struck by name. All were stated confidently in earlier sessions or in this one; all are false.

- ~~*"GA loses ALL aura detail in combat on 12.1."*~~ **FALSE at the headline.** Presence is intact
  and the owner's Warlock displays work end to end in combat — icons light on application, follow
  target swaps, and clear on expiry. `TESTED` on screen 2026-08-03.
- ~~*"His Warlock profile is genuinely broken."*~~ **FALSE.** It was repeated in both this file and
  GA's own HANDOFF. Every display in that profile triggers on presence; the profile works.
- ~~*"The residual risk is `CDM.lua:550` — if `IsActive` returns a secret, an expired buff stays lit
  forever."*~~ **Did not occur.** `TESTED` on the Warlock's target debuffs (the structurally harder
  case than §7's player buffs): displays cleared correctly on expiry and on target swap.
- ~~*"Aura timers are impossible on 12.1."*~~ **FALSE** — asserted mid-session on the strength of an
  exhaustive-looking sink sweep that had never tried `StatusBar:SetValue`. See LESSONS.
- ~~*"ArcUI must be self-timing its bars from a configured duration."*~~ **FALSE.** ArcUI's timer-bar
  feature does work that way, but the owner has **zero** of them configured (`timerBarConfigs`
  absent from its SavedVariables). Finding *a* mechanism in an addon is not finding *the* one in use.
- ~~*"The aura must be in Blizzard's Tracked Bars for GA to show a duration."*~~ **FALSE as a general
  claim.** True only of the mirror route. `AuraContainer` needs no CDM configuration at all.
- ~~*"`C_UnitAuras.GetAuraDurationRemaining` may work where `GetAuraDuration` throws."*~~ **Moot —
  the function does not exist on 12.1.0.68914.**

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

~~**★★ `TESTED` 2026-07-26 — the client no longer matches the paragraph above…** The owner keeps most
Ellesmere modules OFF on retail; the fresh PTR install turned them ALL ON.~~
**★ CORRECTED 2026-08-03 — this is now stale and misleading. Do not act on it.**

**`EllesmereUI` IS the owner's UI.** He has since replaced **EnhanceQoL and Leatrix Plus** with
Ellesmere modules; EQoL is retired. A PTR client with Ellesmere loaded is therefore **representative,
not contaminated** — do not try to get to a "clean" client by switching it off, and never propose
disabling the suite wholesale.

**Only ONE module ever collided with GA: `EllesmereUI Cooldown Manager`** (it re-lit the four CDM
viewers — see the `KILLED` entry below). **He disabled it in July and it is still off**, verified
2026-08-03 from his own addon list. `ActionBars`, `ResourceBars` and `QoL` merely *read* cooldown
info for their own display and do not own the viewer frames, so they cannot skew a measurement.

⚠ **Do NOT tell him to disable `EnhanceQoL`, `ArcUI` or `NiceDamage` either.** GA's saved variables
point at media files inside all three (`NiceDamage\fonts\pepsi_modern.ttf` is his Hunter display
font; `ArcUI\Sounds\*.ogg` and `EnhanceQoL\Sounds\...\Bell.ogg` are display sounds). WoW resolves
those paths off disk, so *disabling* is harmless — but **deleting the folders is not**, and a
missing font takes the whole display down (§2).

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

### ✅ ANSWERED 2026-09-08 — and the answer was a THIRD thing, not either option

**`TESTED`.** The open question was whether a present-but-not-yet-indexed font would fail the probe.
It does — but not for the reason assumed, and the trigger is not "added this session". **The probe
was reading its own warm-up draw as the verdict.**

**Symptom (owner):** on every COLD client start, both of his drop-in catalog fonts were named as
"missing or misnamed". Never on `/reload`. The fonts worked the whole time.

**Evidence, in order:**
1. Both files present in `Fonts/`, byte-exact filenames vs. the catalog entries, valid TrueType
   (sfnt `0x00010000`), and `FONT_PATH` correct. So not a typo, not a format the client refuses.
2. `SetFont` on the same path at the probe's own size, run manually after login, returned **`true`**
   for the drop-in font AND for a bundled one. The face was fine.
3. **Confirmed by prediction:** the owner was asked whether `/reload` warns. It does not — the pairs
   are warm by then. Cold start warns, warm reload does not, every time.

**Mechanism.** This file's own section header records that *"the first draw of a cold pair can render
blank text: cold start → blank catalog names; `/reload` in the same session → fine, because the pairs
were warm by then."* The probe judged the font on exactly that first, unreliable draw — **the very act
warming exists to perform was the act it was reading as evidence.** The Hub's bundled faces never
tripped it because its own UI has already touched them; a user's drop-in font is stone cold.

**Fix (lib MINOR 8):** a failed first draw is now only a CANDIDATE. `UI.WarmFonts` takes an optional
`onVerified` callback and re-draws the failures ~2s later, and only what fails the SECOND pass is
reported. A genuinely missing or misnamed file fails both, so the real signal survives. Owner-QA'd
on a cold restart, 2026-09-08: no warning, fonts working. Pinned in [CONTRACTS.md](CONTRACTS.md) §4.

⚠ **The registration is still NOT gated on the probe, and must not be** — that reasoning is
unchanged and is what kept these fonts working throughout.

### `KILLED` — do not revive this reasoning
- ~~*"A probe that draws the font is the cheap existence check the client permits."*~~ **Half true.**
  Drawing is the only check available, but the FIRST draw is not evidence — it is the operation being
  fixed. Any self-check routed through the mechanism it is checking will lie the first time.

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
line 549 falls back to `frame:IsActive()`. ~~⚠ **The residual risk is line 550:** if `IsActive` ever
returns a *secret*, the code keeps the previous value and an expired buff stays lit forever.~~
**`TESTED` 2026-08-03 — it does not happen, and this was checked on the HARDER case.** The Warlock's
four *target debuffs* (structurally worse than this section's player buffs) were watched on screen
through application, target swap and natural expiry: every display cleared correctly, every time.
The risk was `SUSPECTED` and was predicted out loud again on 2026-08-03 before the test; it did not
occur. Keep it only as the first thing to check if presence ever does go sticky.

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

---

## §10 — The CDM alert events are 12.1's secret-safe timing signal ✅ `TESTED`

**Repo:** `~/GloomsAuras` · **Status: `TESTED`** — 2026-08-03, PTR 12.1.0.68914, Warlock, ~30s at a
training dummy, captured with the new `/ga alertlog` diagnostic (records every event as it ARRIVES,
before any of GA's own filters, so a missing sound can be told apart from a missing event).

Blizzard's Cooldown Manager fires `TriggerAlertEvent` on each item frame with a **plain, readable
enum** computed in its secure context. `CDM.lua:848` hooks it. In 27 arrivals:

| Event | Count |
|---|---|
| `PandemicTime` | 20 |
| `OnAuraApplied` | 16 |
| `OnAuraRemoved` | 12 |
| `Available` | 4 |
| `OnCooldown` | 2 |

**All of them fire in combat, on secret auras, readable.** This is the only timing signal GA gets on
12.1 that is not a widget, and it is what any trigger/sound work should be built on.

**`TESTED` — the 15 `drop:frameKind` entries are NOT a bug.** Every event arrives **twice** because
a spell in two viewers has two hooked frames; `CDM.lua:854` keeps the primary copy and discards the
other. Working exactly as its comment describes. **Do not "fix" this.**

### Two real consequences for the owner's own config
- **`TESTED` — Unstable Affliction emits no `PandemicTime`.** 44s of uptime, zero pandemic events,
  while Agony and Haunt both produced them. **The owner's explanation: UA stacks, so it has no
  pandemic refresh window to alert on.** His UA display has a sound set to `pandemic`, so **that
  sound can never fire.** Not a bug — a trigger wired to an event the spell does not emit.
- **`OBSERVED` — a spurious `PandemicTime` arrives at the same timestamp as `OnAuraRemoved`** (Agony,
  twice). Anything keyed on pandemic must tolerate one at expiry or it will flash.

### ▶ SHIPPED 2026-08-12 — but only the pandemic half, and here is why
The Auras tab now greys out "Pandemic window" and refuses the pick on a spell that cannot emit it,
plus a red warning when a display is ALREADY set to an impossible timing. Owner-QA'd: dimmed on
Unstable Affliction, all three available on Agony.

⚠ **`TESTED` — `GetValidAlertTypes` is NOT a general oracle for "can this trigger fire?"** Measured
per display with a temporary `/ga alerts` dump:

| Display | API says | Reality |
|---|---|---|
| Agony | `[PANDEMIC]` only | apply and wear-off sounds work fine |
| Haunt | `[ready, PANDEMIC, oncd]` | — |
| Corruption | `[PANDEMIC]` | — |
| Unstable Affliction | `[]` (empty) | matches: no pandemic |

**Trusting the apply/remove columns would have greyed out working options on Agony** — silently
removing function, which is worse than offering a control that does nothing. The *pandemic* column,
however, matches this section's observed events exactly across all four DoTs. So the gate is
pandemic-only, deliberately, and the broader "flag any impossible trigger" idea is **not buildable
on this API**.

⚠ **Also `OBSERVED`: `ValidAlerts` can return different answers for the same spell** depending on
whether it resolved via a bound CDM frame or via the category registry — a spell maps to more than
one cooldown entry and they disagree. Only pandemic agreed across both paths. Anyone extending this
beyond pandemic has to settle which entry is authoritative first.

⚠ **`TESTED` — a display built in the Auras tab has NO `cfg.spellID`.** Its spell lives in
`trigger.conditions[1].spellID`. This silently disabled the whole feature for Unstable Affliction
and Corruption, and it is the same root cause that stopped UI-built BARS from ever getting a
duration. `CDM:DisplaySpellID` now resolves it; anything keyed on `cfg.spellID` must use it.

---

## §11 — GB's per-character profiles were never LOADED at login ✅ FIXED 2026-08-15

### ▶ `TESTED` 2026-08-15 — the bug, and the fix, both confirmed against real saved data

**`GloomsBarsDB` is ACCOUNT-wide, and `GB.db`'s visual fields ARE the live working copy.** The
login path bound a character to its profile and then **never called `LoadPreset`** — there was no
call site anywhere in the login sequence. So:

1. The look that rendered on any character was whatever the **last character played** left behind.
2. `PLAYER_LOGOUT` then snapshots the working copy into **this** character's edit preset — so the
   stale look was written over that character's own saved one, every logout.

Per-character profiles were therefore bookkeeping only: they stored, they never applied, and they
quietly corrupted each other over time.

**How it was proven.** The static half is certain — `grep` for `LoadPreset` returns four call sites
(DeleteProfile fallback, SetActiveProfile, DeletePreset fallback, SwitchPreset) and **none** in the
`PLAYER_LOGIN` branch. The behavioural half was confirmed in game: with the fix in, logging into
**Gloomhill-Stormrage** (a character with no prior binding) produced the FACTORY look — circles.
Before the fix it would have rendered Gloomrift's `Wides` look, because that was the working copy
sitting in the account-wide db.

**The fix:** the `PLAYER_LOGIN` branch now ends with `GB:LoadPreset(bound.edit or …)` for every
character, newly-created or already-bound.

⚠ **The damage is already in the owner's saved data and the fix does not undo it.** Presets that
were overwritten still hold whatever look was live at that character's last logout. Each character
will load its own stored preset from now on — which may look wrong ONCE, then stay stable. Do not
diagnose that as a new bug.

### ▶ `TESTED` 2026-08-15 — a preset builder MUST supply every field

`LoadPreset` **skips `nil` fields** (`if snap[k] ~= nil`), deliberately, for forward-compat with
presets saved before a field existed. That means any code building a preset from scratch must
supply **all 39** `GB.PRESET_FIELDS`, or the new profile silently inherits the OLD profile's value
for whatever it missed — and it looks like the new profile "didn't apply".

Three fields are **not** in `DB_DEFAULTS` and must be supplied explicitly: `styleData` (derived from
the chosen style template), `handShape` (derived from the legacy `shape`), `triggers` (derived from
the glow/state fields). `GB:DefaultPreset()` handles all three; verified on Gloomhill's real
generated profile — 8 trigger records, `styleData` present, **zero missing fields**.

⚠ **Do not "fix" this by adding those three to `DB_DEFAULTS`.** The defaults-fill loop runs BEFORE
the migration, so seeding `handShape` there would pre-empt the legacy-shape derivation and change
what upgraders get.

### ▶ `OBSERVED` 2026-08-15 — `DeleteProfile`'s fallback is arbitrary

Deleting a profile reassigns every character bound to it with `next(db.profiles)` — arbitrary table
order, not oldest or alphabetical. The owner's live data shows **four characters** (Gloomriven,
Gloomfury, Gloombuck, Gloomthorn) bound to `Gloomrift - Stormrage` while three of them have their
own unused profile, which is consistent with this fallback having already fired — **but he may
simply have switched them by hand, and that was not established.** Do not treat the cause as known.
The delete path now at least *reports* where the character landed.

---

## §12 — Cooldown "ready" is not one signal, and three of its sources lie ✅ `TESTED` 2026-08-24

Everything below was measured on **live 12.1** via `/ga alertlog`, which the owner ran four times
across two talent builds. Timestamps are quoted from those logs; they are the evidence, not
illustration.

### ▶ `TESTED` — `C_Spell.IsSpellUsable` is a trap ALONE, and the only proc oracle we have

API-NOTES has banned it since 2026-07-08: *"ignores cooldown AND charges … NOT a valid availability
signal; do not use it."* **That ban is correct and it stays.** But it was being read as "never
touch this", and that is too strong.

**What it DOES see is everything `cd_ready` cannot** — resource cost, target requirements, and the
procs that waive them. Shadowburn is the case: it is usable only below 20% target health *unless a
proc lifts that*, so its cooldown mirror reads ready for the whole of combat while the spell cannot
be cast. Owner's two traces, dummy above 20%, `cd_ready = true` in both samples:

| | `cd_ready` | `IsSpellUsable` |
|---|---|---|
| no proc | `true` | **`false`** |
| proc up | `true` | **`true`** |

**The proc is visible through that call.** So GA's new `cd_castable` trigger state is
`cd_ready AND IsSpellUsable`: the trap's failure mode is being *over*-permissive about cooldowns,
and ANDing can only ever NARROW a cooldown answer GA already trusts. Using it alone is still wrong.

⚠ **It does NOT check whether the player knows the spell.** An untalented Soul Fire returns
`usable = true` — see the silent-yes finding below.

### ▶ `TESTED` — Blizzard links Malevolence's CDM entry to Summon Infernal

`InfoMatchesSpell` deliberately accepts `overrideSpellID` and `linkedSpellIDs`, which is what makes
hero-talent replacements work. Malevolence's cooldown entry links Summon Infernal, so Infernal bound
to **Malevolence's** cooldown widget and mirrored its 60s cooldown instead of its own ~120s. The log
shows both spells' `avail` flipping on the *identical* timestamp, three cycles running
(`30038.77`, `30101.12`, …), and Infernal's ready-sound firing on Malevolence's timer.

**Fixed by preferring an EXACT `info.spellID` match**: a spell that has its own entry binds to that
entry; the loose match remains the fallback for spells that only ever appear via an override.
Confirmed gone — `31956.78` Infernal and `31960.28` Malevolence, 3.5s apart, separate sounds.

### ▶ `TESTED` — Blizzard emits a SPURIOUS `PandemicTime` adjacent to `OnAuraRemoved`, and the order is NOT stable

A display set to "Pandemic window" also announced the DoT *falling off*. The cause is a second
`PandemicTime` alert landing within ~0.15s of the removal — **on either side of it**:

```
run 1:  removed 30002.80 -> pandemic 30002.87    (0.07s AFTER)
run 2:  pandemic 30417.33 -> removed 30417.47    (0.14s BEFORE)
        pandemic 30466.35 -> removed 30466.36    (0.01s BEFORE)
```

⚠ **A one-sided guard catches only one of those, and the first attempt at this fix did exactly
that.** The genuine pandemic arrives many seconds clear of any removal, so both sides can be guarded
safely: an after-check on a timestamp, and a before-check by deferring the sound 0.3s so an imminent
removal can cancel it.

**2026-09-19:** the same cleaned-up signal now also drives a bar's **Pandemic Background** (the
backdrop, deliberately not the fill). Clearing it needed a *refresh* signal the alerts do not give —
see **§15**.

### ▶ `TESTED` — `CooldownFrame_Clear` is NOT reliably fired; the polled reconciler is sometimes the only witness

This one cost two failed fixes, and the lesson generalises well beyond sounds.

`CDM.available` has two kinds of writer: **events** (`CooldownFrame_Set`/`Clear`, the charge
shadow's `OnShow`/`OnHide`) and **reconcilers** (`SyncCooldowns`, which reads
`frame.isOnActualCooldown` off the 0.2s visibility poll; `SeedAvailability`; Discover's re-seeds).

- Letting **every** writer fire a sound double-fired: the poll and the hooks disagree by a second or
  two around a cooldown ending.
- The obvious correction — **"only real events may speak"** — was **WRONG**. Malevolence cast at
  `30805.80` came off cooldown at `30866.45`, exactly 60.65s later, and the **only** witness was the
  reconciler. `CooldownFrame_Clear` never fired at all. Silencing reconcilers silenced a real
  completion, and the owner heard nothing.

**★ The durable rule: judge the TRANSITION, not the source.** A cooldown that lasted 60s is real
whoever noticed it; one that "ended" 0.0s after it started is a cast-time flicker whatever fired it.
GA now requires ≥2s on cooldown before a completion can be announced. Casting Malevolence produced
`true → false → true` in a single timestamp, settling to `false` only ~0.9s later — that flicker is
what a duration test rejects and a source test cannot.

⚠ **A settle/debounce timer was tried and REMOVED.** It swallowed real sounds: Infernal came up at
`30929.64` and was cast 0.22s later, so the window closed on `false` and said nothing.
`CDM:PlaySound`'s own 1s per-display throttle already absorbs duplicates.

### ▶ `TESTED` — an UNTRACKED or UNTALENTED spell answers `cd_ready = true` ("the silent yes")

`EvalCondition`'s documented default is *unknown ⇒ assume READY*, which is reasonable for a tracked
spell sitting idle. For a spell the CDM never bound — or one the player has not talented — it turns
"show when ready" into "show always", silently. Soul Fire is the live example: not talented,
`avail = nil`, `usable = true`, trigger permanently true, aura fires at every pull.

**Workaround that works today:** the display's `SPELL / TALENT KNOWN` visibility field
(`IsSpellKnown` / `IsPlayerSpell` — both *do* respect talents).

⚠ **The engine fix is NOT safe to write blind.** Hero talents *replace* spells (the owner's own
"Immolate/Wither" display is one), and if `IsPlayerSpell` reports `false` for a base spell that was
overridden rather than removed, an automatic known-check would silently hide auras that currently
work. That needs a trace before anything is built on it. Backlog item 6.

### ▶ `UNTESTED` — player power is readable, but GA's power gate has never been run

Nothing in the 12.1 notes, API-NOTES or this file restricts `UnitPower`; secrecy is aura-side
(`UNIT_AURA` payloads, AuraData, aura instance IDs, AuraButtons). `EllesmereUIResourceBars` reads
`UnitPower("player", SOUL_SHARDS)` live on the owner's client. GA's new PLAYER POWER load condition
was built on that and **guarded with `issecretvalue` per this repo's standing rule** — but the
owner never exercised it in game. **Do not record it as working.** Backlog item 7.

### `KILLED` — do not revive these

- ~~"GA's `/ga debug` and `/ga trace` agree, so either can diagnose a display"~~ — **FALSE.**
  `debug` keys off `cfg.spellID`, which is `nil` for **every** display built in the Auras tab, so it
  prints `NOT FOUND` for all of them. It sent a session down the wrong path on 2026-08-24. Use
  `trace`. Backlog item 8.
- ~~"An untracked spell is why Shadowburn's aura was always visible"~~ — **DISPROVED by the trace**:
  `avail = true`, bound, no `<not bound>` marker. The real cause was that `cd_ready` means the
  cooldown, and Shadowburn's gate is execute range, not its cooldown.
- ~~"Shadowburn is only usable below 20% target health"~~ — **the owner corrected this**; a proc
  waives it. Do not model a spell's castability from its tooltip when he plays the class.

---

## §13 — GB: Blizzard re-shows button containers in combat, where GB is gagged ✅ `TESTED` 2026-08-24

**Symptom (owner):** with a bar set to hide its empty buttons, hovering the bars *in combat* brought
the empty buttons back — dimmed, and they stayed for the rest of the fight.

**Mechanism.** Two features were fighting. The per-bar collapse (`c.showEmpty == false`) hid the
*container* with `cont:SetShown(false)`; the global Empty-slots treatment sets the *button's* alpha.
Blizzard's `ActionBarMixin:UpdateShownButtons` re-shows the container of every in-range slot
regardless of whether it holds an action:

```lua
local showButtonContainer = showButton or (not self.noSpacers and i <= self.numButtonsShowable);
actionButton.container:SetShown(showButtonContainer);
```

…revealing the button underneath at the global dim alpha. And `Layout:ApplyAll()` is a **hard no-op
in combat** (`if InCombatLockdown() then pending = true; return end`), so nothing could put it back
until the fight ended.

**Confirmed by prediction:** the owner was asked whether the buttons vanish on leaving combat
without touching anything. They do — `pending` flushes on `PLAYER_REGEN_ENABLED`.

**★ This was the FOURTH instance of one pattern**, and the first three are recorded as comments in
`Layout.lua`'s event watcher: a timewalking dungeon un-hid three "Hidden" bars mid-run; Hidden bars
reappeared after Edit Mode; 12.1 stopped firing `EDIT_MODE_LAYOUTS_UPDATED` on exit. **Each was
fixed by registering one more event, and that could not work here** — in combat the geometry wall
gags us no matter which event fires.

**★ AMENDED 2026-09-05 — THE FIRST FIX WAS ONLY HALF THE STORY.** Two code paths hid containers,
and only one was converted. The per-bar **button COUNT** (`c.count`, "show 8 of 12") kept its
`cont:SetShown(false)` in `Layout.lua`, so a bar dropped to 8 had the identical bug: buttons 9-12
came back mid-fight and stayed. The owner hit it on bars 1 and 2, and his workaround — bump to 12,
clear slots 9-12, drop back to 8 — worked only because Blizzard will not draw an EMPTY button even
when it re-shows the container.

**The confirmed trigger is HOVERING the bars in combat** (reproduced twice, 2026-08-24 and
2026-09-05). Nothing appears without something making Blizzard re-run `UpdateShownButtons` during
the fight, which is why it looks intermittent and why it can seem to "stop happening". ⚠ **A bar
that will not reproduce is usually missing the trigger, not fixed** — this cost time on 09-05.

The count path needed the alpha treatment **plus one thing the empty path did not**: the containers
are **parked off-screen** while out of combat. An alpha-0 button is still CLICKABLE, and unlike a
collapsed empty (which keeps its own hole in the grid) an out-of-grid container sits at STALE
coordinates — dropping 12 -> 8 re-centres the eight that remain and changes the row stride, so 9-12
can land on buttons still in use. Invisible-and-clickable over a live button is worse than the bug.
Parking is geometry, so it happens out of combat only, which is enough because it happens once.
Safe because both positioning branches re-anchor every in-grid container on every pass, so raising
the count un-parks them (owner-verified 12 -> 8 -> 12, 2026-09-05).

**Fix: the collapse is an ALPHA treatment now**, answered in `Skin.lua`'s `applyEmptyAlpha` and no
longer by hiding the container. Alpha is not geometry, is not combat-restricted, and rides the
per-button Update post-hook that already runs mid-fight — so it re-asserts itself. This is the
"pure-skin wall" doctrine `Skin.lua` was built on: `SetAlpha(0)`, never `Hide()`.

⚠ **Do not reinstate the container hide.** Comments at both ends say so.
⚠ Two knock-ons, both accepted: an invisible empty button is still **clickable** (identical to the
long-shipped global `Hidden` mode, so consistent rather than new), and the collapse now respects the
master layout switch — turning GB's layout off releases it, so a stale `showEmpty` cannot strand
buttons invisible with no way back.

---

## §14 — GA's shape + effects work: what was measured, and the one real bug ✅ `TESTED` 2026-08-25

The session that moved the silhouette catalog and the eight animation modules into the Hub. Three
things here look like bugs and are not, and one thing does not look like a bug and is.

### A rounded square removes almost nothing — `TESTED`
Measured directly from the art, counting pixels with alpha > 127 inside the icon reference rect:

| shape | keeps | crops |
|---|---|---|
| `square` | 100% | 0% |
| `roundsq1` | 98.8% | **1.2%** |
| `roundsq2` | 95.3% | 4.7% |
| `roundsq3` | 91.7% | 8.3% |
| `circle` | 78.6% | 21.4% |
| `hexagon` | 65.0% | 35.0% |
| `diamond` | 49.9% | **50.1%** |

**So "I picked a shape and nothing happened" is the EXPECTED result for a rounded square**,
especially over art that is already soft-edged. It cost this session a round trip because the test
shape suggested was `roundsq1` — the single most invisible entry in the catalog. **Use `diamond` to
prove a mask is live; use the rest to style.** ⚠ This is a crop and nothing else: it never adds an
outline, a border or a glow.

### The suite's shape art is HALF margin — `TESTED`
Every `-base.png` is 512×512 (portraits 512×768) with the silhouette occupying the central **half**
— a 128px transparent margin all round. A mask therefore has to be anchored to a rect **twice** the
icon's size for the shape to land ON the icon, which is exactly what `GloomsHub:GrowAnchor(t, r, 0)`
produces. `SetAllPoints` draws the shape at half size inside a transparent border and looks like a
sizing bug. GB has always done this via its own `hgAnchor`; that is what it was for.

### Effects re-`Start` on a hot path go INVISIBLE, not just slow — `TESTED`
Every module primes its textures to `PRIME_ALPHA` (0.02) and reveals them one frame later, because
`AddMaskTexture` silently fails on a never-rendered texture. `Displays:ApplyConfig` runs dozens of
times per user action (§ backlog item 4), so calling `mod:Start` from it unguarded leaves an
animation flickering or effectively invisible. GB never met this because `Anims:Reconcile` skips
when the winning trigger is unchanged. GA now carries an equivalent guard keyed on module + shape +
every merged param. **A redundant-push guard here is a correctness fix, not an optimisation.**

### THE REAL BUG: a texture-less aura draws the magenta panel — `TESTED`
`Displays:ApplyConfig` falls back to `C_Spell.GetSpellTexture(cfg.spellID or spellID)`. For any
display built in the Auras tab, `cfg.spellID` is nil and `spellID` is the display KEY — a string
like `"d18"` — so the lookup returns nil and it draws the deliberate magenta "no art" panel. With a
red Recolor over it that renders as flat red (0.9×1, 0.2×0, 0.6×0), which is how it was found.

**Same root cause as backlog item 8** and as the warning already on `alertOff`: *`cfg.spellID` is
nil for everything built in the tab, and `CDM:DisplaySpellID(cfg)` is the resolver.* That is now
**three** separate sites that made the same mistake — treat any new `cfg.spellID` read as suspect.

⚠ **Not fixed, on purpose.** See backlog item 9: the fix is the parked auto-icon feature and the
owner has not decided it.

### KILLED by this session
- ~~"The shape mask is not attaching / the crop does nothing"~~ — **KILLED.** It was `roundsq1`
  (1.2%) over a texture whose corners measure 0–30 alpha out of 255. `diamond` on the same aura cuts
  it visibly in half. The mask was working the entire time.
- ~~"The animation's direction and speed sliders do not work"~~ — **KILLED.** Those were MOTION's
  Rotate controls, which drive `f.tex` via `SetChildKey("tex")` while "Effects only" hides exactly
  that region. An animation's own speed lives in its Settings popup. They now grey out when there is
  no artwork to turn.

---

## §15 — A DoT REFRESH fires no reliable CDM alert; the player's own cast is the signal ✅ `TESTED` 2026-09-19

**Why it came up.** GA's bars gained a **Pandemic Background** — the backdrop wears a second colour
while the tracked DoT is in its pandemic window. Setting it was free: it rides the same double-guarded
`PandemicTime` path as the pandemic sound (§12). Clearing it on a *refresh* was the problem, because
the first build keyed the clear on `OnAuraApplied`, and the owner reported the bar **staying red after
a refresh**.

### ▶ `TESTED` — what Blizzard actually fires on a refresh (`/ga alertlog`, Rogue, two fights)

```
fight 1  17104.49  Garrote  OnAuraApplied      first cast
         17121.57  Garrote  PANDEMIC (clean)   backdrop red, 17s in
         17123.12  Garrote  avail false→true   ← REFRESH cast here (cooldown restarts)
                   — no alert of any kind —
         17145.56  Garrote  PANDEMIC (clean)   red again, 22s later
         17152.50  Garrote  OnAuraRemoved      fell off; cleared correctly

fight 2  17286.04  Garrote  cast → OnAuraRemoved + OnAuraApplied (both!)   ← refresh, this time WITH alerts
         17277.03  Envenom  cast → nothing     (buff refresh, 3 of 3 refreshes silent)
         17288.05  Rupture  cast → nothing     (bleed refresh, silent)
```

**Conclusion.** A refresh *sometimes* fires a Removed+Applied pair and *usually* fires nothing —
one refresh in five across three spells produced an alert. **`OnAuraApplied` means "a fresh aura
instance", not "the aura was (re)applied".** The CDM.lua comment that said the latter was half right:
it is exactly what makes it immune to target-swap re-fires, and exactly why it cannot mark a refresh.

Two other candidates were probed on the item frame and rejected: **`RefreshData` fires on every
tick of every tracked spell** (useless as a signal), and **`OnAuraInstanceInfoSet` fired only with
the Removed+Applied pair** (so it is the same unreliable event under another name).

**What landed on EVERY refresh, all three spells, both fights: `UNIT_SPELLCAST_SUCCEEDED` for the
spell itself** — a plain event with a plain spellID, nothing secret. So "you cast it" is the clear.
Matched through `AuraDuration:CandidateSpellIDs` (spell + override + linked) because a DoT's cast id
and its aura id can differ. **Owner-QA'd 2026-09-19:** flips at the genuine pandemic point, never at
the falloff, reverts the instant a refresh lands, plain on a fresh cast.

### Why the BACKDROP and not the fill — `TESTED` by construction, not by measurement

On 12.1 a duration bar's visible fill belongs to the engine's Blizzard `AuraButton` (§1), a forbidden
object whenever auras are secret — so every fill restyle queues to `PLAYER_REGEN_ENABLED`, and a
pandemic window happens nowhere but combat. The backdrop is GA's own texture on GA's own frame,
already written in combat every fight (the stack count sits on the same frame). The owner also
pointed out the design reason: *by the pandemic point the bar is mostly drained, so the backdrop is
most of what is on screen.* Whether `SetStatusBarColor` **alone** would throw on the engine's region
in combat remains **`UNTESTED`** — nobody measured it, and nothing now depends on the answer.

### Accepted gap
A cast that does **not land** (dodge/miss) clears the colour while the DoT is still in its window,
and the alert cannot re-fire for that instance, so the bar stays plain until the next real refresh.
Cosmetic, rare, self-correcting.

### `KILLED` — do not revive these
- ~~*"`OnAuraApplied` fires on a genuine (re)application, so it marks a refresh."*~~ **KILLED** by the
  logs above. It marks a fresh *instance*. Four of five refreshes fired nothing.
- ~~*"Hook `OnAuraInstanceInfoSet` / `RefreshData` on the item frame for the refresh."*~~ **KILLED** —
  probed the same day; one is the same unreliable event, the other fires constantly.
- ~~*"Recolour the FILL at the pandemic point"*~~ — not killed, **never attempted**: it would queue to
  end of combat by the engine's own rules (§1), which is never. The backdrop was chosen instead.

---

## §16 — The owner's font rendered in Friz Quadrata on EllesmereUI's unit frames ✅ `TESTED` 2026-09-19

**Symptom.** A Hub-registered LSM font, selected as EUI's global font, showed correctly everywhere in
EUI — dropdown, options preview, every other module — **except the live player/target unit frames,
which drew Friz Quadrata.** EUI's own bundled fonts worked on those frames.

### ▶ `TESTED` — the mechanism, read out of both codebases and confirmed by two predictions

1. **Load order:** every `EllesmereUI…` folder loads before `GloomsHub` (alphabetical). EUI's
   Unit Frames module resolves its font path at its own `ADDON_LOADED` and again when it builds the
   frames at `PLAYER_LOGIN`.
2. **The Hub registered media at `PLAYER_ENTERING_WORLD`** — after both of those moments. The timing
   was inherited from StoneTweaks ("LSM is fully up by then"), never chosen.
3. **LibSharedMedia's `Fetch` answers an UNKNOWN name with the type's DEFAULT** unless told
   `noDefault`. The font default is **Friz Quadrata TT**. EUI asked without `noDefault`, got a real
   path back, and **cached it** — in its core's `_smFontPaths`, its memo cache, *and* the Unit
   Frames module's private `cachedFontPath`.
4. EUI's core **does** listen for `LibSharedMedia_Registered` and corrects the first two caches when
   the Hub finally registers. **The Unit Frames module's private copy is refreshed only by a frame
   rebuild** — so the live frames kept Friz, while the options preview (built later from the corrected
   core cache) showed the right font. Every observed detail fits.

**Prediction 1, confirmed by the owner:** changing *any* unit-frame setting (which rebuilds the frames)
snapped the live frames to the correct font, no reload. **Prediction 2, confirmed:**
`/run print(LibStub("LibSharedMedia-3.0"):Fetch("font","<name>",true))` printed the file path.

**Fix (Hub, `Core.lua` + `Media.lua`):** registration moved to the Hub's own `ADDON_LOADED` — the
earliest moment `GloomsHubDB` exists, and before EUI's `PLAYER_LOGIN` frame build. The font
load-CHECK (`WarmFonts`, §5) deliberately stayed at `PLAYER_ENTERING_WORLD`, where its two-pass timing
was proven; `RegisterAll` was split into `RegisterAll` + `VerifyFonts`. **Owner-QA'd on a fresh
login:** correct font on the live frames, no load warning, the "Registered…" line now among the
load-time chat messages.

**EUI's side** has two real bugs (Fetch without `noDefault`; a private font cache with no
registration listener). **The owner declined to report them** — it works for us now. Recorded so
nobody drafts the report unasked.

### `KILLED` — do not revive these
- ~~*"Register at PLAYER_ENTERING_WORLD — LSM is fully up by then."*~~ **KILLED.** LSM is usable from
  file load; registering late is what poisoned another addon's caches with the library default.
- ~~*"The lookup FAILS before registration, so the frame falls back to the default."*~~ **KILLED** in
  its wording: the lookup *succeeds with the wrong answer*. That is why the symptom was Friz (LSM's
  default) and not Expressway (EUI's own fallback) — the fallback path never ran.
- ~~*"A companion addon named to sort before EllesmereUI is needed."*~~ **KILLED** — not needed. EUI's
  late-registration listener makes "before PLAYER_LOGIN" sufficient, and the Hub's own ADDON_LOADED
  meets that.

---

## §17 — Which units the game will identify for an addon on a restricted map ✅ `TESTED` 2026-09-19

**Why it matters.** Gloom's Portraits draws a 3D `PlayerModel` of the target. In a delve, targeting a
friendly (Valeera) worked; targeting a mob did not — and worse, friendly → clear → mob showed the
FRIENDLY model again. The 2026-09-05 note in the engine said "UnitGUID is secret in instances; no
workaround" and had been written from one measurement whose combat state was never recorded.

### ▶ `TESTED` — every line is a `/dump issecretvalue(…)` the owner ran in a delve, on a hostile mob

| Question | Out of combat | In combat |
|---|---|---|
| `UnitGUID("target")` | **false** (readable) | **true** |
| `UnitName("target")` | **false** | — |
| `UnitGUID("nameplateN")` (the mob's own plate) | **true** | — |
| `UnitGUID("mouseover")` (cursor on the mob) | **true** | — |
| `UnitIsUnit("target", "nameplateN")` | — | **a real boolean** — one plate `true`, the rest `false`, none secret |

Corollaries, also `TESTED` the same evening:
- **`Model:SetUnit` on a secret unit loads NOTHING** — `GetDisplayInfo()` stays 0 at 0, 0.5 and 2
  seconds and `OnModelLoaded` never fires. It also does not clear what was there, which is the
  stale-model symptom.
- **`ClearModel()` on a `PlayerModel` did not clear it either** — `OBSERVED`: the symptom survived
  a code path that called it. Cause not established; the fix does not depend on it (the frame is
  hidden while blocked).
- **`SetPortraitTexture(tex, "target")` renders the correct face for a secret hostile in combat.**
  It is engine-side and on no guarded list. That is the 2D stand-in.
- **`SetCreature(npcID)`** takes a plain number and is not guarded; the ID is read from the GUID
  while the target is identifiable and recorded against the plate it stands under.

**So the rule is:** on a restricted map the game identifies **exactly one unit** for an addon — the
**target, out of combat**. Everything else you can point at is secret before the pull, and the
target goes secret at the pull. The one thing that survives into combat is *sameness*: which
nameplate the target is. **Shipped on that basis** (GloomsPortraits, master): 3D out of combat; 3D
for a mob targeted before the pull when tabbed back to; the correct 2D portrait otherwise, in its
own 2D layout; a re-ask on `PLAYER_REGEN_ENABLED` so the stand-in yields to 3D by itself.

**Two working-practice traps from the same evening,** both now in LESSONS: a `/run` pasted into chat
is silently truncated at **255 characters** and then does nothing at all (two probes were lost to
this before the diagnostic moved into the addon as `/gp plates`); and **secrecy differs by TOKEN
and by combat state** — test the exact token the code will use, in the state it will use it.

### `KILLED` — do not revive these
- ~~*"UnitGUID is secret in instances; there is no addon-side workaround."*~~ **KILLED in its
  generality** (the 2026-09-05 engine comment). It is secret **in combat**; out of combat the target
  is fully identifiable, which is what the pre-pull path and the nameplate cache are built on.
- ~~*"Record the whole pack from its nameplates as it comes into view."*~~ **KILLED** — plate units
  are secret on the map, combat or not; a model of one never loads.
- ~~*"Sweep the cursor over the pack to identify it."*~~ **KILLED** — `mouseover` is secret too.
- ~~*"Read the display ID off a model after SetUnit and replay it with SetDisplayInfo."*~~ **KILLED**
  for secret units (nothing loads, so there is no ID to read); untested for identifiable ones,
  and unnecessary — the GUID's creature ID plus `SetCreature` needs no model at all.

---

## §18 — Drawing a circular unit frame from 12.1's secret values ✅ `TESTED` 2026-09-19

**The question** was whether a health ring is even possible once the number is secret. It is, and
Gloom's Unit Frames is built on what this section records. Every line below is a `/dump`, a probe
panel (`/gloomprobe`, a throwaway that lived in the Hub for the day) or an on-screen result the
owner reported, all on the live 12.1 client the same day.

### ▶ `TESTED` — health is a SECRET number for EVERY unit, everywhere
`issecretvalue(UnitHealth(u))` is **true** for `player` and `target` on a training dummy, in a
delve out of combat, and in the same delve in combat. `UnitHealthMax("player")` is the only plain
one; the target's max is secret. So is a target's `UnitPowerMax` and `UnitPowerPercent`. **No Lua
arithmetic on health is ever possible** — `angle = health / max × span` cannot be written. The old
backlog wording "secret in instances" was too kind; it is secret on a dummy.

### ▶ `TESTED` — what a secret number can be handed to (the sink table)
Measured with a real secret from `UnitHealthPercent(unit, true, curve)`:

| Sink | Result |
|---|---|
| `Texture:SetRotation(secret)` · `MaskTexture:SetRotation(secret)` | **works, visibly** (a 45° diamond at full health, ~30° at two-thirds) |
| `SetRotation(secret, pivot)` — the optional normalized rotation point | **works**, texture and mask, about a point outside the region (probe K) |
| `Texture:SetAlpha(secret)` | **works for non-zero values** (a grey square at 68%) |
| `Texture:SetAlpha(secret that evaluates to 0)` | **ACCEPTED AND IGNORED** — the layer keeps its last opacity. Rendered on screen as the gate curve's text: `gate 0.00`, sliver still drawn. A secret may not decide visibility. |
| `SetAlpha(secret)` on a texture carrying `SetGradient` | **ACCEPTED AND IGNORED** at any value (probe J: two gradient squares fully opaque at 30% health) |
| `Texture:SetPoint(…, secret, 0)` | **ACCEPTED AND IGNORED** — the region lands at 0,0 |
| `Texture:SetTexCoord(0, secret, 0, 1)` · `StatusBar:SetValue(secret)` | work |
| `Texture:SetWidth(secret)` · `Cooldown:SetCooldownDuration(secret)` · `Animation:SetDegrees(secret)` | **refused** ("Secret values are only allowed during untainted execution") |
| `SetVertexColor` with secret channels · `SetFormattedText("%d", secret)` | work (EUI relies on both) |

★ **Three of those say "ok" and do nothing.** `pcall` succeeding is not evidence for a secret sink;
only the picture is. LESSONS has the general form.

### ▶ `TESTED` — the curve API is the bridge
`C_CurveUtil.CreateCurve()` + `AddPoint(x, y)` (x is the 0..1 percent) and
`UnitHealthPercent(unit, true, curve)` / `UnitPowerPercent(unit, type, true, curve)` return the
curve's value at the secret percent — still secret, evaluated engine-side. A per-piece curve is how
a wedge, an alpha gate, a resource segment's window and a colour blend are all expressed without
Lua ever touching the number. `CurveConstants.ScaleTo100` gives the percent as text-ready 0–100.
Duration objects have the same door: `d:EvaluateRemainingDuration(curve, default)` (x = remaining
seconds), which is what drives the interrupt-return tick.

### ▶ `TESTED` — the drawing technique (the engine header in `GloomsUnitFrames.lua` is canonical)
1. **Ring art never moves.** Two HALF-PLANE masks sit on it — one fixed at the arc's start, one
   rotated by the secret sweep angle from a curve. Their intersection is the wedge.
2. **Masks only subtract**, so one pair carves at most 180°; a wider span is two "chunks" (the
   owner's question "does it HAVE to be two pieces?" — yes). A 360° ring adds a hard 3° cap over
   the closing point, gated above ~99.6%.
3. **Two half-planes never intersect to NOTHING.** Rotating "past empty" wraps the overlap round to
   the far side — the floating chunk seen on the first build. Empty must be GEOMETRY: no mask
   overshoots its far end, so an empty chunk is a hairline. (Alpha cannot hide it — zero is ignored.)
4. **Seams.** Two anti-aliased edges on one line each draw at 50%, and 50 over 50 is 75%: a bleed on
   an opaque fill, invisible on a 12% track. So the fill's following chunk OVERLAPS the previous by
   1.5° with a HARD-edged mask (a soft edge drawn in two layers — base + ramp — leaves a residual of
   the base colour along it, a line over solid colour; a hard edge between identical pixels is
   invisible), while track chunks meet exactly. The rotating mask is soft on its leading edge and
   hard on its trailing one, because at spans ≥ ~358° the trailing edge lands inside the overlap.
5. **Thickness** is a third mask, a hole cut from a solid disc (`CLAMP` wrap so it is opaque
   forever outward; a zero-size mask hides everything, so a solid disc parks the hole off to the
   side). **A texture takes at most THREE masks** — measured by the error, `AddMaskTexture(): Texture
   already has the maximum number of mask textures (3)` — which is why the gradient ramp has its
   shape baked in as a companion image rather than masked by the art.
6. **Gradient** = a second layer (the ramp companion, alpha 0→1 across the disc) tinted with the
   end colour, aimed by rotating its TEXTURE COORDINATES (`SetTexCoord` with rotated corners). Not
   `SetRotation` on the texture: a rotated texture is clipped by its masks half a pixel tighter than
   an unrotated one — a fringe of the base colour along every mask edge. Not `SetGradient`: see the
   sink table.
7. **Shift** (colour drains toward mid/low) and the resource breakpoint and the cast ring's
   mid-cast tint are all extra LAYERS whose alpha is a curve — mid opaque by 50%, low fading in
   below it, so 50% shows exactly the mid colour. "Off" is 0.4% alpha, never 0 (rule 3).
8. **Round ends** are the band itself cut by a disc mask plus the hole (so the cap has the arc's own
   edges — a separately drawn disc read as "bulging"); the moving end's mask pivots about the ring's
   centre by the sweep curve. The arc is pulled in by half a cap so the cap's far edge lands where
   the flat end would have been.
9. **Stacking** is by FRAME LEVEL, one child frame per chunk, one band of eight levels per ring:
   ARTWORK sublevels did not guarantee order across textures carrying different masks (the
   boundary spoke), and two rings on the same levels interleave their pieces.
10. **The player's cast** is PLAIN — `UnitCastingInfo` name/start/end, the duration object's total
    and remaining — so the cast ring is clock arithmetic per frame. **A TARGET's cast on a
    restricted map is SECRET in every part — name, start, end AND the duration object's total**
    (`TESTED` in a delve, 2026-09-20, via `/gu casttrace`). The ring still draws it: the duration
    object evaluates a curve over its own 0..1 FRACTION engine-side —
    **`d:EvaluateElapsedPercent(curve)`** (a cast filling) / **`d:EvaluateRemainingPercent(curve)`**
    (a channel draining) — so the very percent curves `UnitHealthPercent` takes serve unchanged and
    no total is ever needed. (OPie's cooldown spiral uses the same door; EUI's cast bar gets it for
    free through `StatusBar:SetTimerDuration`, which a masked arc cannot use.) Owner-verified: the
    ring fills in step with EUI's nameplate bar, and the interrupt-state RECOLOUR works under
    secrecy (`notInterruptible` goes through `EvaluateColorValueFromBoolean`). What does NOT work
    there is the mid-cast tint and the kick tick — both need the cast's real clock to place a mark,
    and `KickExtras` keeps its `st.plain` guard. Name and level text stayed readable in a pull.
11. **The evaluators' optional second argument is validated to 0..1.**
    `d:EvaluateRemainingDuration(curve, 0.004)` passes; `d:EvaluateRemainingDuration(curve, 4.79)`
    (an angle in radians as the "default") is **"bad argument #3"** (`TESTED` 2026-09-20 — 73× on
    the kick tick's first outing on a class with an interrupt; the Warlock had none, so it never
    ran). A rotation evaluation takes NO second argument; alpha evaluations may keep theirs.
12. **`Texture:SetVertexColor(r, g, b, 1)` lands the 4th value as the layer's OPACITY** on 12.1
    (`OBSERVED` 2026-09-20 via `/gu debug target`: after the cast ring's per-tick recolour, the
    EMPTY second chunk's base read `alpha=1.000` while its grad/mid/low sat at the gate's 0.004 —
    the one layer recoloured per frame was the one lit, and its 1.5° lead overlap drew as an orange
    slice at the chunk boundary). `arc:SetColor` now passes three values, and `CastTick` recolours
    BEFORE the geometry pass so the gate is the last writer; the slice is gone (`TESTED`). The
    ordering fix and the argument fix landed together, so which one alone would have sufficed is
    not established — keep both.

### `KILLED` — do not revive these
- ~~*"Health is secret in instances"*~~ (backlog item 12's old wording) — **KILLED**: secret on a
  dummy, for the player. There is no plain-number path anywhere.
- ~~*"Hide an empty chunk with alpha 0."*~~ **KILLED** — a secret zero is ignored (measured with the
  gate value rendered as text).
- ~~*"`pcall` said ok, so the sink took the secret."*~~ **KILLED** three times over (SetPoint,
  SetAlpha-on-gradient, SetAlpha-to-zero).
- ~~*"Explicit ARTWORK sublevels fix the overlap order."*~~ **KILLED** — they changed the arbitrary
  order into a different arbitrary order; frame levels are absolute.
- ~~*"The seam is the mask art."*~~ Half true, once: the first 182° mask was a shifted half-plane,
  not a wedge (the polygon never passed through the centre) — measured by sampling the PNG by
  angle. Fixed; the remaining seams were the alpha rules above.
- ~~*"A cast ring must be a Cooldown swipe (full circle from 12 o'clock)."*~~ **KILLED** for the
  player — times are plain. ~~*Still the only fallback for a fully secret target cast.*~~ **KILLED
  2026-09-20** — the duration object's percent evaluators (point 10) draw the secret cast on the
  ring's own curves. The swipe is never needed.
- ~~*"If even the target's TOTAL is secret the ring must hide."*~~ **KILLED 2026-09-20** — the total
  IS secret in a delve, and the ring draws anyway (point 10). The hiding was a guess about the API.
- ~~*"The slice at the chunk boundary is the seam work coming undone."*~~ **KILLED 2026-09-20** — the
  gate held on three of four layers; the fourth was being re-lit by the per-tick recolour (point 12).

### ▶ AMENDED 2026-09-19 (late) — three more sinks, all `TESTED` on the live client
| Sink | Result |
|---|---|
| `AbbreviateNumbers(secret[, cfg])` | **works** — "845K" / "14M", and "845.3K" with a one-decimal breakpoint config. It is Blizzard's, engine-side; EllesmereUI's 845K is this. |
| `FontString:SetFormattedText("%s", secret)` with a secret STRING (`UnitName`) or a secret non-integer (`UnitEffectiveLevel`) | **works** — the text system in Gloom's Unit Frames is one `SetFormattedText` per piece, every shortcode an argument |
| **`Frame:SetAlpha(secret)`** — a FRAME, not a texture | **works, and the zero rule holds**: a plain `SetAlpha(0)` followed by `SetAlpha(secret)` leaves the frame visible iff the secret is non-zero (probe `/gu gate`: three squares, A and B on with a shield, C — gated by a secret that IS zero — never drawn) |
| `C_CurveUtil` curve `:Evaluate(secret)` | **refused** — "Secret values are only allowed during untainted execution for this argument" |

The last two are the whole basis of §19.

---

## §19 — Absorbs on 12.1: no arc is possible, but presence is ✅ `TESTED` 2026-09-19

**The question.** Gloom's Unit Frames wanted an absorb ARC on the health ring the way Blizzard's and
EUI's bars show a shield. Every straight bar gets it for free — `StatusBar:SetMinMaxValues(0, max)`
+ `SetValue(absorb)` both take secrets and the engine sizes the fill — but an arc needs an ANGLE,
and the only door from a secret to an angle is a percent function evaluating a curve engine-side.

### ▶ `TESTED` — every door to an absorb ANGLE is shut (the owner ran each on the live client)
1. **No absorb-percent function exists.** `for k,v in pairs(_G) … k:find("Absorb")` lists exactly
   two functions: `UnitGetTotalAbsorbs`, `UnitGetTotalHealAbsorbs`. Both return a SECRET number for
   the player (`issecretvalue` → true, in a city, out of combat).
2. **A curve object will not evaluate a secret itself.** `curve:Evaluate(0.5)` → 0.5;
   `curve:Evaluate(UnitGetTotalAbsorbs("player"))` → refused (the §18 amendment above). So even the
   player's PLAIN max health cannot be turned into a curve over the secret absorb amount.
3. **`UnitHealthPercent`'s second argument does not fold absorbs in.** With a 292K shield on 845K
   health and health at ~34%: `with 34 / without 34` (rendered as text at the top of the screen —
   the first attempt at full health read `100 / 100` and proved nothing, because a with-shield
   percent would clamp there).

**So an absorb arc has no honest source on this client.** The shield is available as a NUMBER
(`[absorb]` on any text piece, abbreviated by `AbbreviateNumbers`) and as PRESENCE (below). **Do not
re-chase the arc without a new API** — a `UnitGetTotalAbsorbsPercent`-shaped function, or a curve
that evaluates secrets, is the only thing that would reopen it.

### ▶ `TESTED` — the PRESENCE gate (shipped as the health ring's "shield wash")
A secret alpha of ZERO is ignored (§18) — but "ignored" means "keeps its last opacity". So:
`frame:SetAlpha(0)` (plain) then `frame:SetAlpha(UnitGetTotalAbsorbs(unit))` (secret, clamped to 1
when large) leaves the frame **visible iff shielded, and no number ever reaches Lua.** Measured with
`/gu gate` (three squares; the one gated by a secret zero — heal-absorbs — never appeared). Shipped
as a copy of the health arc carrying only the gradient-ramp layer, under a gate frame and an
opacity frame, its fade fitted to the arc's chord (`Media/art/disc-ramp-10…90.png` are the ramp at
narrower fade widths; the disc shape is baked in, so width cannot be a texcoord). ⚠ `OBSERVED` only:
the wash switching OFF on the ring itself — the owner is permanently shielded (Soul Leech), so the
off state was seen on probe square C, not on the ring. The mechanism is the same call.

### `KILLED` — do not revive these
- ~~*"`UnitHealthPercent(unit, true, curve)` — the `true` means predicted/with absorbs."*~~ **KILLED**:
  34 / 34 with a third of max health in shield.
- ~~*"Evaluate the curve in Lua for the player, whose max health is plain."*~~ **KILLED**: the curve
  refuses the secret argument.
- ~~*"Read the absorb off a StatusBar the engine sized."*~~ Never tried and not needed: reading a
  driven bar back would be reading the secret. Not a door.

---

## §20 — Aura GROUPS on a unit frame: what an aura button's children can and cannot do ✅ `TESTED` 2026-09-19

**Context.** §1 built GA's per-spell duration bars on `AuraContainer` SLOTS. Gloom's Unit Frames
needed the LIST form — a unit's buffs/debuffs as icons — which is `AddAuraGroup` with the engine's
flow layout. EllesmereUI's `AuraKit` is the reference for that form; the notes below are what
building it against our own frames established, all on the live client, owner at the keyboard.

### ▶ `TESTED` — the group API as it works on 12.1
- `C_AddOns.LoadAddOn("Blizzard_AuraContainer")`, then `CreateFrame("AuraContainer", nil, parent,
  "CustomAuraContainerTemplate")`, `SetSize(1,1)` (the engine resizes it), flow layout via
  `SetFlowLayoutAnchorPoint(point)`, `SetFlowLayoutGrowthDirection(h, v)` — **ENUMS**
  (`AnchorUtil.FlowDirection.Right/Left/Up/Down`), a string is "horizontalDirection must be valid"
  — and `SetFlowLayoutMaximumLineSize(px)` (a SIZE, not a count). Then
  `AddAuraGroup(key, filterString, { maxFrameCount, candidateFilters, sortMethod, sortDirection,
  initializeFrame, layout = { elementWidth, elementHeight, elementSpacing, lineSpacing } })`, and
  **`SetUnit(unit)` LAST** (event registration is evaluated then and needs the group in place),
  then `UpdateAllAuras()`.
- Filter vocabulary that works: tokens in the string (`HELPFUL|PLAYER`, `HARMFUL|CROWD_CONTROL`,
  `RAID`, `RAID_IN_COMBAT`, `RAID_PLAYER_DISPELLABLE`, `BIG_DEFENSIVE`, `EXTERNAL_DEFENSIVE`,
  `CANCELABLE`, negated with `!`), booleans in `candidateFilters` (`isFromPlayerOrPlayerPet`,
  `isBossAura`, `isRoleAura`, `isPriorityAura`, `isStealable`, `canApplyAura`), sets
  (`includeDispelTypes`, `excludeDispelTypes`, `includeSpellIDs`, `excludeSpellIDs`) and
  `maxDuration = math.huge` for "has a duration". **Owner-verified: `maxDuration` drops permanent
  buffs**; `PLAYER` narrows to own casts (the target group). The rest go through the identical path
  and are `UNTESTED` individually.
- Sorting: `sortMethod = Enum.UnitAuraSortRule.ExpirationOnly` (4) with `sortDirection`
  `Normal` (0) = soonest-expiring first, `Reverse` = last. **Owner-verified.** (BigWigs' aura plugin
  documents the numbers.)
- A group's filter string is FIXED at declaration; a filter change is a fresh container. Creation
  in combat is legal per EUI (build 68914+) — **`UNTESTED` by us.**
- A TARGET container still needs `UpdateAllAuras()` on `PLAYER_TARGET_CHANGED` (§1 point 2 holds).

### ▶ `TESTED` — what lives under the button is half ours
Inside `initializeFrame` we create the icon texture, a `Cooldown` (`CooldownFrameTemplate`), a
carrier frame with two FontStrings, and a host frame, all children of the button, and bind them
with `SetIcon`, `SetDurationCooldown`, `SetApplicationCount`, `SetDurationText`. Afterwards:
1. **`IsShown()` / `IsVisible()` on a child FRAME of the button return a SECRET boolean** — a
   boolean test on it errors ("attempt to perform boolean test on a secret boolean value"). The
   same for the container's children. "Is this aura showing" is aura data.
2. **No script on a child frame ever runs.** `OnShow`, `OnHide` and even `OnUpdate` set on the host
   from `initializeFrame` fired **zero** times across many show/hide cycles of the button. The
   engine does not tell addon frames under its button anything. (Whether `SetScript` is refused or
   the handler is skipped was not distinguished; the effect is the same.)
3. **Region WRITES stay legal**: `AddMaskTexture` on our icon, `SetSwipeTexture` on our Cooldown,
   `SetVertexColor`/`SetAlpha` on our textures — all fine at any time, which is what §1 said.
4. **`GetNumMaskTextures()` on our texture is PLAIN**, which is what makes a verified mask bind
   possible under the button.

5. **Layout writes under the button are REFUSED while auras are secret** — `SetSize` on our
   texture from an effect driver in a delve fight: *"Attempt to access forbidden object from code
   tainted by an AddOn"*, 2,000+ times a fight (`TESTED` 2026-09-20, Breathe). This is §1's
   forbidden window reaching our own children: `SetAlpha` / `SetVertexColor` (point 3) survive,
   `SetSize` does not, `SetPoint` presumably not (`SUSPECTED` — same class of write; Sheen has not
   been run there), `SetRotation` unknown (`UNTESTED` — the Park helper announces it if it fails).
   **Consequence:** `Effects.lua` PARKS an instance whose layout write is refused until
   `PLAYER_REGEN_ENABLED` and says so once per module per session — the effect pauses for the
   fight instead of storming BugSack. The real fix is engine `AnimationGroup`s for the size /
   position modules (Hub BACKLOG). Also measured: a Hub effect was being started on EVERY button of
   a Buffs/Debuffs group carrying a stale `effect` field (six Breathe instances); effects are now
   This-spell only, as designed.

**Consequences shipped:** the shape mask and the Hub effect are started AT WIRING TIME with no
trigger and simply live under the button, which the engine hides and shows; the Hub's
`Effects.lua` modules now treat a secret `IsShown` as shown and VERIFY their deferred mask bind
through `GetNumMaskTextures`, retrying every 0.5 s while active (the "Hosts under a Blizzard
AuraButton" block; behaviour on a plain visible host is unchanged). The icon's own shape mask does
the same. The `/gu auras` diagnostic reports counts only — it may not test a child's `IsShown`.

### `KILLED` — do not revive these
- ~~*"Hook the button's OnShow to start the glow."*~~ **KILLED** — a button call after the window,
  and even our own child frame's scripts never fire.
- ~~*"Poll `host:IsVisible()` from outside."*~~ **KILLED** — secret boolean.
- ~~*"Use `OnUpdate` on the host as the show signal, since it only runs while visible."*~~ **KILLED**
  — it never ran at all under the button.
