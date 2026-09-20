# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-09-20, early morning (**the Unit Frames tab went two-column** — `UI.grid` /
`UI.popover` / `UI.cog` are Hub toolkit MINOR 9 — and **the delve measurements are done**: a
target's cast is secret in every part and the ring draws it anyway through the duration object's
percent evaluators (FINDINGS §18.10). Three latent cast-ring bugs surfaced on the owner's Rogue —
the first class with an interrupt — and were fixed (§18.11–12). Effects under an aura button in
combat are PARKED, not fixed (§20.5). **The owner ruled GU's account-wide config wrong: it goes
profile-based, item 14, before anything else.** ⚠ `GloomSuite/GloomsUnitFrames` still does NOT
exist on GitHub — three commits, local only. A frustrating session; start the next one clean.)
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

### 12 · Gloom's Unit Frames — what is left
**Repo:** `~/GloomsUnitFrames` (sixth tool, LOCAL git only) · **Size:** small pieces · **Evidence:** everything shipped is owner-QA'd, the delve pass 2026-09-20

**Done since the second session:** EUI's player/target frames are hidden and the owner lives on
these (2026-09-20) · the delve measurements — see FINDINGS §18.10 (cast), name/level readable in a
pull, interrupt recolour under secrecy.

**Left, in order:**
1. **The shield wash switching OFF** — still only ever seen on the probe square (§19). Watch for it
   the next time a shield lands in a fight.
2. **Aura filter classes** beyond timed-only and cast-by-you — same engine path, `UNTESTED`
   individually; whichever bites first gets checked then. Also `UNTESTED`: creating a container in
   combat (a Show-kind change mid-fight rebuilds one).
3. **The mid-cast tint and kick tick under secrecy** — they need the cast's real clock and stay off
   for an instanced target (the ring only recolours there). Design question, not a bug: is a
   secret-safe version wanted? `EvaluateRemainingPercent` on the KICK's duration could place the
   tick if the cast's total were known — it is not. Park unless he asks.
4. **Death Knight runes** — not a power type; the resource ring skips DKs. Only if he rolls one.
5. **Create the GitHub repo** `GloomSuite/GloomsUnitFrames` when he says (public, org-owned, private
   membership — Hub `CLAUDE.md` PRIVACY). Three sessions of work on one disk.
6. **The Gu mark** in the tab header is still the Hub's logo.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` · [FINDINGS.md](FINDINGS.md) §18 (the renderer, incl.
10–12), §19 (absorbs), §20 (aura buttons)

---

### 13 · The Unit Frames tab — the tidy pass after the compaction
**Repo:** `~/GloomsUnitFrames` (the tab) · **Size:** an hour, once he has a mock · **Evidence:** landed and owner-QA'd 2026-09-20 — "a little messy, we can clean up later"

The compaction shipped: every section body is a `UI.grid` (two cells per line), the deep clusters
sit behind `UI.cog` popovers (shield tint · interrupt colouring · effect settings · aura filters),
one-line conditionals appear inline under their switch (gradient end, drain shift, breakpoint), the
shortcode list is a popover that inserts on click. What is left is the LOOK — spacing, which pairs
sit together, label widths — and **the owner said he might make a mock**; ask for it before
touching anything. Do not redesign the mechanism.

**Read first:** `~/GloomsUnitFrames/GloomsUnitFrames_Tab.lua` (the header comment explains the
three tiers) · [CONTRACTS.md](CONTRACTS.md) §4 (`UI.grid` / `UI.popover` / `UI.cog`)

---

### 14 · Gloom's Unit Frames goes PROFILE-BASED ★ NEXT
**Repo:** `~/GloomsUnitFrames` (+ nothing in the Hub — `UI.profileBlock` exists) · **Size:** a session · **Evidence:** owner decision 2026-09-20

> "This should be a profile-based system, like it is for literally every other module in this
> suite. What an odd choice you made to do it this way." — the owner, on discovering his Warlock's
> "This spell" group running on his Rogue.

`GloomsUnitFramesDB` is ONE account-wide config (the first session copied Portraits). Rings are
arguably shared; aura groups, "This spell" and `[shards]`-style texts are class things, and the
owner wants the whole tool per-character like Bars / Auras / Overlays. What to build:
- `UI.profileBlock` in the rail (CONTRACTS §4), character-bound like GB: one profile per character,
  **New = the factory look, Copy = a full duplicate**, Rename, Delete (which prints where the
  character landed). Same `api` shape as GB's — read `~/GloomsBars/Config.lua`'s block for the
  plumbing and FINDINGS §11 for the login-binding trap GB hit.
- **Migration:** the existing account-wide config becomes the first profile (call it "Default"),
  bound to every character that logs in until he makes another — nothing he built is lost.
- The tab's `Cfg()` / `RingCfg()` / `TextList()` / `AuraList()` already go through `GU:Config(which)`,
  so the tab needs the block and little else; the engine's `db[which]` reads are the surface to
  re-point.

**Read first:** `~/GloomsUnitFrames/CLAUDE.md` (the Shape section) · `GU:Config` and the `db` setup
in `~/GloomsUnitFrames/GloomsUnitFrames.lua` · the `profileBlock` entry in [CONTRACTS.md](CONTRACTS.md)
§4 · GB's block in `~/GloomsBars/Config.lua` · [FINDINGS.md](FINDINGS.md) §11

---

### 15 · Effects under an aura button must ANIMATE in combat, not pause
**Repo:** `~/GloomsHub` (`Effects.lua`) · **Size:** a session, with GU as the test bed · **Evidence:** `TESTED` 2026-09-20 (FINDINGS §20.5)

In a fight, every layout write under an engine aura button is refused — `SetSize` proven, `SetPoint`
presumed, `SetRotation` unknown. Seven of the eight modules move or resize their texture per frame;
only Rim Flash is alpha-only. Tonight's stopgap PARKS a refused instance until regen and says so once
per module — honest, but the highlight goes still exactly when it matters. The fix: drive those
modules through engine **`AnimationGroup`s** (Scale for Breathe / Burst, Translation for Sheen,
Rotation for Shine / Marching / Radar) created and `:Play()`ed at wiring time, looping, so nothing
is called in combat. Keep the plain-host path (GB, GA) byte-for-byte — the "GB looks identical"
promise — by switching only hosts the "under a Blizzard AuraButton" block already detects.

**Read first:** the "Layout writes under a Blizzard AuraButton IN COMBAT" block and the "Hosts under
a Blizzard AuraButton" block in `~/GloomsHub/Effects.lua` · [FINDINGS.md](FINDINGS.md) §20 ·
[CONTRACTS.md](CONTRACTS.md) §8

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **"An absorb ARC on the health ring"** — **NOT POSSIBLE, measured 2026-09-19**, FINDINGS §19:
  no absorb-percent function exists, a curve refuses to evaluate a secret, and `UnitHealthPercent`'s
  flag does not include absorbs (34 / 34 with a 292K shield). What shipped is the shield WASH
  (presence via the plain-zero-then-secret alpha gate) and `[absorb]` as text. Reopen only on a new API.
- **"Start an aura icon's glow from the button's OnShow / from a child's OnUpdate"** — **NO**,
  FINDINGS §20: no script under an aura button ever fires and its `IsShown` is a secret boolean.
  Effects start at wiring time and live under the button; the Hub's modules verify their mask bind.
- **Class color + gradient on the health fill** — **mutually exclusive by the owner's call**
  (2026-09-19): a gradient wins, and the switch hides in gradient mode. Do not blend them.
- **A GA display as the "boss debuff on me" highlight** — **not the answer**: GA's displays are
  CDM-trackable auras; a boss debuff is not one. The GU "This spell" aura group is the tool for it.

- **"Draw the unit-frame rings with `SetGradient`, or hide an empty piece with alpha 0, or
  position anything with a secret"** — **NO, all measured 2026-09-19**, FINDINGS §18. A texture with
  `SetGradient` ignores a secret alpha; a secret alpha of exactly ZERO is ignored everywhere;
  `SetPoint` accepts a secret and drops it. The engine's gradient is a ramp *layer*, "empty" is
  geometry, and nothing is positioned by a value.
- **"A cast ring could use the Cooldown swipe"** — **never needed** (2026-09-20): the player's times
  are plain, and a target's fully secret cast draws through the duration object's percent
  evaluators on the ring's own curves (§18.10). Do not reach for the swipe.
- **"The cast ring hides when a target's total is secret"** — **KILLED 2026-09-20**, §18.10. The
  total is secret in every delve cast and the ring draws anyway.
- **Gloom's Unit Frames staying account-wide** — **RULED WRONG by the owner, 2026-09-20.** Item 14.
  Do not argue for it, and do not build any more GU features on the account-wide shape.
- **"Rings over 180° can be one piece"** — **NO.** Masks only subtract; two chunks, overlapped by a
  hard-edged start mask. §18.

- **"Show the 3D model of an enemy targeted mid-combat in an instance"** — **NOT POSSIBLE, measured
  2026-09-19** (FINDINGS §17). On a restricted map the game identifies ONE unit for an addon: the
  target, out of combat. Nameplate units and mouseover are secret even before the pull; `SetUnit`
  on any of them loads nothing. What ships is the ceiling: 3D out of combat, 3D for a mob targeted
  before the pull when tabbed back to (nameplate-matched, `SetCreature`), the correct 2D portrait
  otherwise, flipping back to 3D when combat drops. The owner called it "so fucking lame" and he is
  right; **do not re-chase it without a NEW API.** `UnitIsUnit("target","nameplateN")` being a real
  boolean in combat is the one door that is open, and it is already used.
- **A ROUND-BOTTOMED 3D bust (a mask on a PlayerModel)** — **IMPOSSIBLE on the current client**
  (2026-09-19). A `PlayerModel` is a live viewport into a rectangle, not a texture; `MaskTexture`,
  `SetClipsChildren` and alpha all act on textures or rectangles, and there is no render-to-texture
  for addons. A corner matte hides the world under the corners; slicing into clipped copies is
  jagged, heavy and the copies' idle animations drift apart. **Becomes a one-liner if Blizzard ever
  ships model-to-texture — that is the only trigger for reopening it.** The owner wants it; record
  the wish, not a hack.
- **The WoWup / GitHub-Releases distribution path** — **RETIRED by the owner, 2026-09-19.** He runs
  every suite addon as a SYMLINK for development; WoWup's GitHub install "doesn't work very well"
  (learned on Build Barn and Loot Advisor, both moved to CurseForge). Tags still cut a GitHub
  Release as a version marker, nothing more. **If the suite ever goes public it goes through
  CurseForge**, and he will say when. Do not frame changes as "so WoWup picks it up", do not verify
  `latest` for WoWup's sake, do not tell him to install from a release.
- **Gloom's Portraits keeping its own minimap button / floating panel / slash subcommands** — all
  **GONE with stage 2** (2026-09-19). The suite has ONE launcher; `/gp` opens the tab; the tab's
  open/close IS the lock. Reset lives in the tab's rail.

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
