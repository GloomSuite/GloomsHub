# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-26 (late — Quick Keybind CLOSED as not-a-GB-bug; the gold square it
exposed FIXED; per-action icon overrides SHIPPED)

---

## Open items

### 1 · GA loses all aura detail in combat on 12.1 ★ the big one
**Repo:** `~/GloomsAuras` · **Size:** a migration, not a patch · **Evidence:** `TESTED` (2026-07-25)

In combat 12.1 returns aura instance IDs as SECRET, and every read call throws. GA keeps aura
*presence* but loses duration, stacks and expiry. Fails silently — BugSack stays clean while
nothing renders. Three escape routes were tested and all are closed.

**Deferred by the owner (2026-07-25): wait for 12.1 launch, then triage.** He is switching to
Hunter for Season 2 and the cooldown path is unaffected, so this does not block him. Do not
re-litigate the timing.

**★ The pressure is OFF, and this is `TESTED` (2026-07-26) — see [FINDINGS.md](FINDINGS.md) §7.**
His own MM Hunter profile is **unaffected**: every display in it triggers on aura *presence*, which
survives. This is still a real defect for duration/stack displays — the Warlock profile is genuinely
broken — but it no longer threatens the spec he is playing into Season 2.

**Read first:** [FINDINGS.md](FINDINGS.md) §1 · `~/GloomsAuras/CLAUDE.md` ·
`~/GloomsAuras/docs/API-NOTES.md`
**Shape:** deep design work inside one tool — the one case that genuinely earns a session of its own.

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

- **Quick Keybind Mode "blocked by GB's skin"** — **CLOSED, not a GB bug** (FINDINGS §8). It does
  not reproduce on live, and it stopped reproducing on the PTR mid-investigation. The `/fstack`
  evidence that named GB was a **misreading** and is struck. **Do not re-raise without a fresh,
  reproducible symptom** — and if one appears, measure with `GetMouseFoci()`, never `/fstack`.
- **GB's per-action icon overrides (`GB.Icons`)** — **SHIPPED and owner-QA'd 2026-07-26**, including
  the owner authoring his own icons end to end. Deliberately NOT built: a config UI in the Bars tab
  (slash + manifest is enough), and the optional folder watcher, which is written
  (`tools/install-icon-watcher.sh`) but **not installed** — the owner's call, not a task.
  **One real gap, only raise it if he does:** `Find Icon.command` resolves **spells** only; item
  icons (healthstones, trinkets) must still be found by hand. `/gb icon key` cannot substitute —
  the client has no filename for packed assets. See `~/GloomsBars/docs/HANDOFF.md`.
- **GB's icon zoom applying to every preset** — **FIXED and owner-QA'd 2026-07-26.** Per-bar preset
  context was missing from three loops. **The rule and the audit that catches a repeat are in
  `~/GloomsBars/docs/HANDOFF.md` — this class has bitten twice.** Not a task; do not re-raise.
- **GA's "hide Blizzard CDM icons" toggle failing on the PTR** — **NOT OUR BUG.** It was
  `EllesmereUICooldownManager` re-lighting the viewers; disabling that module fixed it, owner-
  confirmed 2026-07-26. GA's hide works correctly on 12.1. See FINDINGS §4's `KILLED` list.
- **MM Hunter auras on 12.1** — **TESTED and SAFE**, 2026-07-26 (FINDINGS §7). Do not re-test.
- **GB's modifier symbols (⌘⇧⌃⌥) take no outline** — **DROPPED by the owner**; do not re-propose.
- **The public repos expose `CLAUDE.md` + `docs/`** — **ACCEPTED**; do not re-flag.
- **Distribution to friends/guild** — not ready; the owner will say when. Don't push it.
- **The false `SetFont` guard** — FIXED, owner-QA'd 2026-07-26. It was NOT a tidy-up: FINDINGS §5's
  `KILLED` list has why that reasoning was wrong.
- **`ForceTaint_Strong` on a dead font path** — CLOSED, no action (FINDINGS §6). **Do not re-raise
  without a real symptom.**
- **The user's own media shipping in the addon** — FIXED 2026-07-26; `Fonts/`, `Textures/`,
  `Graphics/` are gitignored and purged from history. **Never re-track them** (`.pkgmeta` says why).
- **General Sans's redistribution terms** — **CLOSED by the owner 2026-07-26** without the Fontshare
  terms being read; the attribution ships in `Media/fonts/FONT-LICENSES.md`. Not a task.
- **The colour picker** — **FULLY owner-QA'd 2026-07-26; nothing outstanding.** Two settled decisions
  not to re-propose: the IN USE palette holds the USER's colours, never the suite's design tokens,
  and it is deliberately **not modal**. Full record in [ARCHIVE.md](ARCHIVE.md).
