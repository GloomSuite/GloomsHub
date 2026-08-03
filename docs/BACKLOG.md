# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-30 (Blizzard's 12.1 API notes digested — item 1 REFRAMED and now hinges on
one PTR test; the damage-meter taint storm traced and closed as Blizzard's bug)

---

## Open items

### 1 · GA loses all aura detail in combat on 12.1 ★ the big one — SIZE IS NOW UNKNOWN
**Repo:** `~/GloomsAuras` · **Size:** ONE TEST decides between a patch and a migration
**Evidence:** `TESTED` (2026-07-25) · **confirmed by Blizzard's own 12.1 notes** (2026-07-30)

Aura APIs reached **by index, slot or instance ID Lua error** while auras are secret. GA keeps aura
*presence* but loses duration, stacks and expiry, and fails **silently** — BugSack stays clean while
nothing renders.

**★ NEXT SESSION STARTS HERE — one PTR test sizes the whole item.** Can a duration object, or a
secret `duration`/`expirationTime`, be obtained **without any index/slot/instance-ID API** and still
be fed to a widget? The only untested channel is `C_UnitAuras.GetPlayerAuraBySpellID`.

**Patch if yes** (GA already owns the pass-through machinery); **migration if no**, and the options
then need re-pricing because 12.1 may have closed the one recorded as "Blizzard's sanctioned path".

⚠ **Read FINDINGS §1 before running anything** — it holds the full reasoning, the 2026-07-25
escape-route table showing three sibling channels already return `nil`, an **honest prior of LOW**,
and what 12.1 changed. Do not re-derive any of it here.

**Deferred by the owner (2026-07-25): wait for 12.1 launch, then triage.** Do not re-litigate the
timing. **Pressure is OFF** — his MM Hunter profile is `TESTED` unaffected (§7). The Warlock profile
is genuinely broken.

**Read first:** [FINDINGS.md](FINDINGS.md) §1 · `~/GloomsAuras/CLAUDE.md` ·
`~/GloomsAuras/docs/API-NOTES.md` · **Blizzard's 12.1 API changes:**
<https://warcraft.wiki.gg/wiki/Patch_12.1.0/API_changes> (the aura + "secret value" sections)

---

### 2 · The rest of the 12.1 exposure sweep
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

- **GB's skinning hooks** — the *layout* hooks are proven alive (all 40 installed and firing,
  measured 2026-07-26). The skinning side got one real result on 2026-07-26: the Quick Keybind
  investigation turned up a genuine gap — `QuickKeybindHighlightTexture` was the one button-state
  texture the skin never adopted — which is now fixed. **That was found by eye, not by the sweep**,
  so the sweep itself is still untested.
- **Real instanced content** — dungeon / M+ / raid. All testing so far was open-world on a dummy.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

**⚠ Before trusting ANY result from this sweep, check the PTR addon list.** The PTR client has
drifted from what FINDINGS §4 records — a full competing UI suite (`EllesmereUI`, 20+ modules) is
installed and defaults to all-modules-on. It already produced one convincing false 12.1 bug.

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

### 3 · GA's `/ga probe` diagnostic has two self-inflicted bugs
**Repo:** `~/GloomsAuras` · **Size:** two small fixes · **Evidence:** `TESTED`

Dev-tool only, no user impact — but this probe is the instrument the whole 12.1 investigation runs
on, and it has already caused one false alarm. A screen-wide cooldown sweep plus a frame leak on
every CAPTURE click (`CDM.lua:1567`), and `spec=?` in every header (`CDM.lua:1455`).

**Read first:** `~/GloomsAuras/docs/HANDOFF.md` — both diagnosed there, with the fix for each.

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

- **The damage-meter Lua error storm (2026-07-30)** — **NOT OUR BUG, nothing to do.** Blizzard's
  built-in damage meter compares secret values on paths any addon taints; rows then show wrong names
  and class icons. `TESTED`: reproduced with LiteMount, Plumber and TextureAtlasViewer each as the
  only non-Blizzard addon loaded. **All four Gloom addons were loaded throughout and produced
  nothing.** Owner is filing it with Blizzard. Full record + the `KILLED` theory in
  [FINDINGS.md](FINDINGS.md) §9. **Do not re-diagnose this.**
- **Quick Keybind Mode "blocked by GB's skin"** — **CLOSED, not a GB bug** (FINDINGS §8). It does
  not reproduce on live, and it stopped reproducing on the PTR mid-investigation. The `/fstack`
  evidence that named GB was a **misreading** and is struck. **Do not re-raise without a fresh,
  reproducible symptom** — and if one appears, measure with `GetMouseFoci()`, never `/fstack`.
- **GB's per-action icon overrides (`GB.Icons`)** — **SHIPPED and owner-QA'd 2026-07-26**, including
  the owner authoring his own icons end to end. Deliberately NOT built: a config UI in the Bars tab
  (slash + manifest is enough), and the optional folder watcher, which is written
  (`tools/install-icon-watcher.sh`) but **not installed** — the owner's call, not a task.
  **Do not build tooling to find original icon art.** A spellID→file script was written and DELETED
  the same day — he looks the spell up on Wowhead, whose results list the icon name, and that is
  faster. `/gb icon key` cannot substitute: the client has no filename for packed assets.
- **GB's icon zoom applying to every preset** — **FIXED and owner-QA'd 2026-07-26.** Per-bar preset
  context was missing from three loops. **The rule and the audit that catches a repeat are in
  `~/GloomsBars/docs/HANDOFF.md` — this class has bitten twice.** Not a task; do not re-raise.
- **GA's "hide Blizzard CDM icons" on the PTR** — **NOT OUR BUG**; it was
  `EllesmereUICooldownManager`. GA's hide works on 12.1 (FINDINGS §4 `KILLED`).
- **MM Hunter auras on 12.1** — **TESTED and SAFE** (FINDINGS §7). Do not re-test.
- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner**; do not re-propose.
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**; do not re-flag.
- **Distribution to friends/guild** — not ready; the owner will say when. Don't push it.
- **The false `SetFont` guard** — FIXED. NOT a tidy-up; FINDINGS §5's `KILLED` list says why.
- **`ForceTaint_Strong` on a dead font path** — CLOSED (FINDINGS §6). No action without a symptom.
- **The user's own media shipping in the addon** — FIXED; `Fonts/`, `Textures/`, `Graphics/` are
  gitignored and purged from history. **Never re-track them** (`.pkgmeta` says why).
- **General Sans's redistribution terms** — **CLOSED by the owner**; attribution ships. Not a task.
- **The colour picker** — **FULLY owner-QA'd; nothing outstanding.** Don't re-propose either settled
  decision: the IN USE palette holds the USER's colours, never design tokens, and it is **not modal**.
