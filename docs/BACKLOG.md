# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-19 (two jobs, both owner-QA'd and shipped to master/main, nothing
released. GA: bars gained a **Pandemic Background** — the backdrop wears a second colour in the
DoT's pandemic window and reverts on refresh; the refresh signal had to be MEASURED, FINDINGS §15.
Hub: the owner's font drew in Friz on EllesmereUI's unit frames because the Hub registered media at
PLAYER_ENTERING_WORLD; registration now happens at the Hub's ADDON_LOADED, FINDINGS §16. **New item
11 is the next job the owner asked for: Gloom's Portraits, a fifth suite tool.** Before that, 09-08:
the login font-load warning fix, FINDINGS §5. Before that, 09-05: GB's hidden-button-count bug,
FINDINGS §13. Before that, 08-25: the shared SHAPE + EFFECTS migration into the Hub, FINDINGS §14.)

---

## Open items

### 1 · Finish GA's bar coverage — Corruption + UA, and confirm the UI route
**Repo:** `~/GloomsAuras` · **Size:** small · **Evidence:** `UNTESTED` (code written, never run)

The duration engine is **built and owner-QA'd** — Agony and Haunt drain correctly on 12.1 with
stack counts, and the whole Bar section exists in the Auras tab. What is left is coverage:

- **Corruption and Unstable Affliction have no bars at all.** They are texture displays.
- **The last change of the session was never tested.** `CDM:DisplaySpellID` now resolves a
  display's spell from its first TRIGGER when there is no `cfg.spellID`, which is the shape of
  every display built in the Auras tab. It is wired into five call sites (`AuraDuration:Attach`,
  `CandidateSpellIDs`, `BarSource`, `BarStackValue`, the `cd_dur` feed). **Before this, a bar
  created in the UI could never get a duration** — `/ga bar <spellID>` was the only working route,
  and the owner has said he will never use a command.

**The test:** + New Aura → Bar Aura → set its Aura Trigger to Corruption → cast it. The bar should
fill and drain with no slash command anywhere. Then the same for UA.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md` (the 2026-08-12 block) · [FINDINGS.md](FINDINGS.md) §1

---

### 2 · The rest of the 12.1 exposure sweep — now on LIVE
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

**12.1 went live 2026-08-11.** Everything below was written against the PTR.

- **Real instanced content** — dungeon / M+ / raid. Every test so far, across three sessions, has
  been open-world on a training dummy. Aura secrecy covers encounters, M+ and PvP, not just combat,
  and nobody has tested whether `AddAuraSlot` behaves the same under encounter secrecy.
- **GB's skinning hooks** — the *layout* hooks are proven alive (all 40, measured 2026-07-26). The
  skinning side is still untested.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).
- ~~Stacks under secrecy~~ — **SOLVED 2026-08-12.** See FINDINGS §1.

⚠ **The old "check the PTR addon list, it has drifted" warning is RETIRED.** FINDINGS §4 records
the truth: EllesmereUI **is** the owner's UI, the one colliding module has been off since July, and
telling him to disable things is how a session wastes his evening. Read §4 before touching the client.

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

### 3 · GA's `/ga probe` leaks frames on charge spells
**Repo:** `~/GloomsAuras` · **Size:** one small fix · **Evidence:** `TESTED`

`CDM.lua`'s charge-spell probe creates two fresh `CooldownFrameTemplate` frames per capture with no
`SetSize`/`SetDrawEdge`/`SetDrawBling`, so each click paints a screen-wide gold wedge and parks two
more frames. `_ProbeShadows` already pools correctly — copy it.

⚠ **The owner has explicitly deprioritised this** (2026-08-12): it is a dev diagnostic, it cannot
bite a Warlock, and he does not want to hear about it unless it affects normal play. Fix it silently
if you are in the file; do not raise it.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md`

---

### 4 · Why does `ApplyConfig` run so hot?
**Repo:** `~/GloomsAuras` · **Size:** unknown, probably small · **Evidence:** `OBSERVED`

`AuraDuration:ApplyStyle` was seen firing **dozens of times for a single user action**, and 600
deferrals accumulated in one short combat. A redundant-push guard now absorbs it, but the guard
treats the symptom — the underlying question of why `ApplyConfig`/`UpdateBar` re-run that often was
never established. Worth knowing before anything else expensive is hung off that path.

**Read first:** `~/GloomsAuras/docs/HANDOFF.md`

---

### 5 · Finish verifying GB's profile rework
**Repo:** `~/GloomsBars` (+ Hub's `Skin.lua`) · **Size:** ten minutes of clicking · **Evidence:** `UNTESTED`

The 2026-08-15 rework is **shipped and partly owner-QA'd**. Confirmed in game: the rail layout, the
factory look on a new character's first login, and no data loss across a reload. What was NOT
exercised:

- **The New button itself.** It calls the same `GB:DefaultPreset()` that Gloomhill's login proved
  works, so this is likely fine — but nobody has clicked it. Expect circles.
- **Rename with the name unchanged** — should now be a silent no-op, not "already exists".
- **A name typed with a leading/trailing space** — should be trimmed (this is in the Hub's shared
  `nameDialog`, so it affects GA and Overlays too).
- **Delete** — should print which profile the character landed on.

⚠ **One open DESIGN question the owner has not answered:** he said a new profile should look "like
the default UI", and what it produces is **GB's** default — circles. Blizzard's stock buttons are
square. Circles were kept (round icons are the addon's whole point) and it is a one-line change in
`GB:DefaultPreset()` if he wants otherwise. **Ask; do not change it unprompted.**

**Read first:** `~/GloomsBars/docs/HANDOFF.md` (the 2026-08-15 block) · [FINDINGS.md](FINDINGS.md) §11

---

### 6 · The "silent yes" — an untracked or untalented spell reports `cd_ready = true`
**Repo:** `~/GloomsAuras` · **Size:** small, but needs a trace FIRST · **Evidence:** `TESTED`

Unknown ⇒ READY turns "show when ready" into "show always" for a spell the CDM never bound. The
owner's Soul Fire display does it today. **He has a working workaround** (the `SPELL / TALENT KNOWN`
field) and chose it over an engine fix, so this is not urgent.

⚠ **Do not write the automatic known-check blind** — hero talents REPLACE spells, and if
`IsPlayerSpell` returns false for an overridden base spell it would hide auras that work today.
Trace that first.

**Read first:** [FINDINGS.md](FINDINGS.md) §12

---

### 7 · GA's PLAYER POWER load condition has never been run
**Repo:** `~/GloomsAuras` · **Size:** ten minutes of clicking · **Evidence:** `UNTESTED`

Built 2026-08-24; nobody has clicked it. **The test:** an aura with Power = Soul Shards, *at least*,
5 — hidden at 0-4, appears at 5, gone when you spend one. Works as a group load rule too.

⚠ Power is not secret, but the read stays `issecretvalue`-guarded per this repo's standing rule.

**Read first:** [FINDINGS.md](FINDINGS.md) §12

---

### 8 · `/ga debug` contradicts `/ga trace`
**Repo:** `~/GloomsAuras` · **Size:** one small fix · **Evidence:** `TESTED`

`CDM:Debug` keys off `cfg.spellID`, which is `nil` for every display built in the Auras tab, so it
reports `NOT FOUND` for all of them while `trace` resolves them fine. It sent a session down the
wrong path on 2026-08-24. Use `DisplaySpellID(cfg)` — the same fix `alertOff` already carries a
warning about.

**Read first:** `CDM:Debug` in `~/GloomsAuras/CDM.lua`

---

### 9 · An aura with no texture draws the magenta panel, not its spell's icon
**Repo:** `~/GloomsAuras` · **Size:** two lines, but the DESIGN question is the real work · **Evidence:** `TESTED`

`Displays:ApplyConfig` resolves its icon fallback with `C_Spell.GetSpellTexture(cfg.spellID or spellID)`.
For every display built in the Auras tab `cfg.spellID` is nil and `spellID` is the display KEY (a
string like `"d18"`), so the lookup fails and it draws the deliberate magenta "no art" panel.
Measured 2026-08-25; FINDINGS §14. **Same root cause as item 8**, and the same call fixes it:
`CDM:DisplaySpellID(cfg)`.

⚠ **Do not just make the change.** Wiring that resolver in IS the parked "auto-icon a new aura from
its first trigger" feature, which the owner has never decided on, and its open question is still
open: *does an explicit texture pick set `cfg.texture`, so the auto-icon only ever fills the unset
case?* **Ask before building.** On 2026-08-25 he pushed back on the premise itself — he did not want
a trigger's icon appearing as artwork he had not chosen. The workaround he actually wanted was
"Effects only", which shipped that day.

**Read first:** [FINDINGS.md](FINDINGS.md) §14 · the "Deferred" block in `~/GloomsAuras/docs/HANDOFF.md`

---

### 10 · `hgAnchor` exists twice, knowingly
**Repo:** `~/GloomsBars` (+ Hub's `Shapes.lua`) · **Size:** small, but it is GB's geometry engine · **Evidence:** `TESTED` (verified identical 2026-08-25)

The grown-rect anchor every shaped glow and effect depends on is defined in BOTH
`GloomsBars/Skin.lua` (local `hgAnchor`, 6 call sites) and `GloomsHub/Shapes.lua`
(`GloomsHub:GrowAnchor`). They were verified line-for-line identical by script when the second was
created, and ⚠ comments at both ends say they must not drift.

It was left duplicated deliberately: collapsing GB's into a delegation means editing its layout
geometry during a migration whose entire QA promise was "GB looks identical". That promise has been
kept and banked, so this is now safe to do as its own small change with its own test.

**Read first:** `GloomsHub:GrowAnchor` in `Shapes.lua` · `hgAnchor` in `~/GloomsBars/Skin.lua`

---

### 11 · Gloom's Portraits — bring `StoneModel` into the suite as a fifth tool ★ NEXT
**Repo:** NEW — `~/GloomsPortraits` under the `GloomSuite` org (+ Hub docs) · **Size:** stage 1 ~an hour, stage 2 a design session · **Evidence:** decided 2026-09-19

`StoneModel` is a single-file addon (~900 lines, `/sm`) already installed at
`…/Interface/AddOns/StoneModel/` — free-floating 3D full-body models or 2D circular portraits for
player and target, each placeable/sizeable/rotatable, with show conditions. It has no repo and no
project. **The owner wants it in the suite and chose the name "Gloom's Portraits."**

**Stage 1 — make it a suite member, no visual change:**
- New repo `GloomsPortraits` (`GloomsPortraits.toc`, namespace `GloomsPortraits`, SavedVariables
  `GloomsPortraitsDB`, slash `/gp`), `## Dependencies: GloomsHub`, `Author: Gloom` (the TOC currently
  says `Claude`). Copy `.pkgmeta`, `.gitignore`, the release workflow and a `CLAUDE.md` from a
  sibling — Overlays is the smallest template.
- **⚠ PRIVACY: the current name is NOT publishable — the Hub `CLAUDE.md` PRIVACY section says
  why, and the same rule already retired StoneTweaks' name. Neither the old filename, the `.bak`
  beside it, nor the old folder name may appear in any commit.** Start the repo from the renamed
  file only.
- **One-time copy-migration** of `StoneModelDB` → `GloomsPortraitsDB` so positions/sizes survive —
  the exact pattern `MigrateFromStoneTweaks` uses in the Hub's `Core.lua`. Never move, only copy.
- Symlink into the client, `/reload`, confirm the models appear where they were. Keep the existing
  `/sm` panel working (add `/gp` alongside).
- Create the GitHub repo under **GloomSuite** with private membership, push, cut `v1.0.0`.

**Stage 2 — make it look like one (its own session):** replace the control panel with a **Portraits
tab** in the Suite window on LibGloomSkin — rail + editor like GB, sliding switches, the shared
sliders/colour picker. Read `StoneModel.lua` properly before designing; stage 1 only skims it.

**Not the Hub (shared infra, not a tool) and not Overlays (a 3D model is not a textured overlay).**

**Read first:** `…/Interface/AddOns/StoneModel/StoneModel.lua` · the PRIVACY section of the Hub's
`CLAUDE.md` · `MigrateFromStoneTweaks` in `~/GloomsHub/Core.lua` · `~/GloomsOverlays/.pkgmeta`,
`GloomsOverlays.toc` and `.github/workflows/` as the packaging template · [CONTRACTS.md](CONTRACTS.md)
§1-§2 (the tab API) only when stage 2 starts

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **"GB's per-character profiles don't work / my alt looks wrong"** — **FIXED 2026-08-15**, FINDINGS
  §11. Login never loaded the bound profile. ⚠ The old bug already overwrote some saved presets;
  a character may look wrong ONCE after the fix, then stay stable. That is not a new bug.
- **GB profile New vs Copy** — **SETTLED 2026-08-15.** New = the factory look; Copy = a full
  duplicate of the active profile. GA and Overlays already worked this way; GB was the outlier and
  now matches. Do not "restore" New to snapshotting the current look.
- **GB's PRESET block being orange and at the bottom of the rail** — **the owner asked for it**
  (2026-08-15) so the two blocks stop reading as one control. Not a mistake, not a token drift.
- **GA duration bars on 12.1** — **BUILT and owner-QA'd 2026-08-12** via `AuraContainer`. Mechanism
  and traps in FINDINGS §1 and `~/GloomsAuras/docs/HANDOFF.md`. Do not redesign it.
- **The Tracked-Bar mirror** (`BarMirrorValues`, `StartMirror`/`StopMirror`) — **DELETED 2026-08-12.**
  It worked but needed a per-aura Blizzard config step. **Do not rebuild it**; FINDINGS §1.
- **A display not returning after a mid-combat `/reload`** — **CLOSED, not fixable through the
  presence mirror.** `TESTED` over 52 passes: the CDM never binds an already-applied aura to its
  item frame after a reload. Three fixes were attempted and all three failed. FINDINGS §1.
- **`GetValidAlertTypes` as a general "can this trigger fire?" oracle** — **NO.** It reports Agony
  as unable to do apply/remove, which is false. Only its *pandemic* column matches observation.
  FINDINGS §10.
- **How ArcUI does DoT timers** — **SOLVED**, FINDINGS §1. Do not reverse-engineer it again.
- **Combat-log / self-timed duration bars** — **do not build.** FINDINGS §1, option 2.
- **"GA is broken in combat on 12.1" / "the Warlock profile is broken"** — **FALSE**, FINDINGS §1.
- **`GetPlayerAuraBySpellID` as the deciding test** — **tested, returns `nil`**; player-only.
- **The damage-meter Lua error storm** — **NOT OUR BUG** (FINDINGS §9). Do not re-diagnose.
- **Quick Keybind Mode "blocked by GB's skin"** — **CLOSED, not a GB bug** (FINDINGS §8).
- **GB's per-action icon overrides (`GB.Icons`)** — **SHIPPED and owner-QA'd.** No config UI wanted.
  **Do not build tooling to find icon art.** ⚠ `IconsHD/` is git-ignored and `IconsManifest.lua`
  ships EMPTY — the mechanism ships, the owner's art does not. **Never commit a populated manifest.**
- **GB's icon zoom applying to every preset** — **FIXED and owner-QA'd 2026-07-26.**
- **GA telling GB to glow a real action button** — **RULED OUT by the owner, 2026-08-25.** It was
  offered twice as the exact fix for "make the Cataclysm button glow" (perfect shape, perfect
  alignment, follows the bars automatically). He declined both times: *"I don't really want an aura
  telling GB what to do — that's a level of complexity that I suspect would introduce more problems
  than it solved."* **He is content aligning an aura over a button by hand.** Do not re-offer it.
- **"GA's shape/animation does nothing"** — check WHICH shape and WHICH texture before believing it.
  Measured against the icon rect, `roundsq1` crops **1.2%**, `roundsq2` 4.7%, `circle` 21.4%,
  `diamond` 50.1%. A rounded square over soft-edged art is a legitimately invisible change.
  Animations additionally need a Shape set — with none they are skipped by design. FINDINGS §14.
- **Distribution to friends/guild** — not ready; the owner will say when.
- **The user's own media shipping in the addon** — FIXED and purged. **Never re-track them.**
- **The colour picker** — **FULLY owner-QA'd.** IN USE holds the USER's colours; it is not modal.
- **GB's empty-button collapse hiding the CONTAINER** — **MOVED to the alpha path 2026-08-24**,
  FINDINGS §13. Blizzard re-shows containers and GB is combat-gagged, so the hide could never hold.
  **Do not reinstate `cont:SetShown(false)` for empties**; comments at both ends say so.
- **"Gloom's Hub says my fonts did not load, but they work"** — **FIXED 2026-09-08**, FINDINGS §5.
  The probe read its own first cold draw as the verdict, so it accused every drop-in catalog font on
  every cold client start and never on `/reload`. It now re-checks ~2s later and reports only what
  fails twice. ⚠ **The warning is still worth having** — a real typo or a deleted `.ttf` fails both
  passes. **Do not gate font REGISTRATION on it**; that reasoning is unchanged and is what kept the
  owner's fonts working throughout.
- **"Buttons past the bar's count reappear in combat"** — **FIXED 2026-09-05**, FINDINGS §13 (see
  the AMENDED block). Same mechanism as the empty-slot case, in the count path that was left behind.
  Out-of-grid containers are now alpha-0 AND parked off-screen. ⚠ **The trigger is HOVERING the bars
  in combat** — without that it will not reproduce, which is not the same as being fixed. **Do not
  "simplify" the parking away**: alpha alone leaves an invisible button clickable on top of live
  ones.
- **`C_Spell.IsSpellUsable` being simply banned** — **QUALIFIED 2026-08-24**, FINDINGS §12. Still
  invalid ALONE; valid ANDed with the cooldown mirror, and it is the only signal that sees a proc.
  GA's `CASTABLE` trigger state is built on that pairing.
- **Sourcing the "comes off cooldown" sound from events only** — **TRIED and WRONG**, FINDINGS §12.
  `CooldownFrame_Clear` is not reliably fired; the polled reconciler is sometimes the only witness.
  Judge the transition's DURATION, not which writer noticed. Do not re-split by source.
- **A settle/debounce timer on the ready sound** — **REMOVED**, it swallowed real sounds.
  `CDM:PlaySound`'s 1s per-display throttle already handles duplicates.
- **"The owner has stale Hunter auras"** — **FALSE.** Those live in OTHER CHARACTERS' profiles.
  ⚠ `GloomsAurasDB`/`GloomsBarsDB` hold one profile per character and display IDs restart in each
  (`d18` exists several times). **Any script reading them must be profile-aware** — grabbing the
  first regex match produced two confidently wrong diagnoses on 2026-08-24.
- **Reporting EllesmereUI's font-cache bugs upstream** — **DECLINED by the owner, 2026-09-19.**
  FINDINGS §16 names both bugs; the Hub-side fix makes them moot for us. Do not draft the report.
- **"Make the bar FILL change colour in the pandemic window"** — **NOT BUILT, by design** (2026-09-19).
  The fill is the engine's Blizzard button and cannot be restyled in combat (FINDINGS §1, §15); the
  owner chose the BACKDROP and it shipped. Do not re-offer the fill.
- **Immolate's pandemic sound firing every ~21s** — **NOT A BUG** (measured 2026-08-24: ~7 in 4.5
  minutes). A Destruction rotation refreshes into the pandemic window constantly and the alert fires
  each time; the spurious falloff one is separately suppressed (FINDINGS §12). Raised with the owner;
  **he did not ask for anything.** Do not build a rate limit unprompted.
