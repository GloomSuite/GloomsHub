# Gloom Suite — BACKLOG

> **The single answer to "what's open?"** Read this at the start of every session and offer the
> owner the list. Nothing else needs reading until he picks.
>
> **Closed items do not live here.** They move to [ARCHIVE.md](ARCHIVE.md) the moment they close.
> If this file grows past ~80 lines, something is being kept that should have been archived.

**Last updated:** 2026-07-26 (late — MM Hunter PROVEN safe on 12.1; Quick Keybind traced to GB)

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

### 2 · Quick Keybind Mode is blocked by GB's skin ★ has a real symptom
**Repo:** `~/GloomsBars` · **Size:** likely one line, then QA · **Evidence:** `TESTED` cause,
`UNTESTED` on live

The owner cannot bind a key while the pointer is over a button's centre; its edge works. Cause is
established and named by `/fstack`: GB's skin raises `TextOverlayContainer` above the button, and
that mouse-enabled container steals the focus Quick Keybind listens for.

**★ Do this FIRST: does it reproduce on LIVE?** GB is symlinked into both clients, so this code
already runs on retail. §3 had exactly this shape and turned out to be a latent live bug the PTR
merely exposed. **If it repros on live it gets fixed now, not after launch** — thirty seconds
in-client answers it, and it decides whether this is even a 12.1 item.

**Read first:** [FINDINGS.md](FINDINGS.md) §8 · `~/GloomsBars/docs/HANDOFF.md` (the frame-level
stack, and why lowering the container is the wrong fix)

---

### 3 · The rest of the 12.1 exposure sweep
**Repo:** mostly `~/GloomsBars`, some Hub · **Size:** testing, then triage · **Evidence:** `UNTESTED`

- **GB's skinning hooks** — item 2 is the first real symptom out of this gap. The *layout* hooks are
  proven alive (all 40 installed and firing, measured 2026-07-26); the skinning side is still only
  as tested as item 2 makes it.
- **Real instanced content** — dungeon / M+ / raid. All testing so far was open-world on a dummy.
- **Overlays and the Hub shell** got a smoke test only (tabs open, window renders).

**⚠ Before trusting ANY result from this sweep, check the PTR addon list.** The PTR client has
drifted from what FINDINGS §4 records — a full competing UI suite (`EllesmereUI`, 20+ modules) is
installed and defaults to all-modules-on. It already produced one convincing false 12.1 bug.

**Read first:** [FINDINGS.md](FINDINGS.md) §4

---

### 4 · GA's `/ga probe` diagnostic has two self-inflicted bugs
**Repo:** `~/GloomsAuras` · **Size:** two small fixes · **Evidence:** `TESTED`

Dev-tool only, no user impact — but this probe is the instrument the whole 12.1 investigation runs
on, and it has already caused one false alarm. A screen-wide cooldown sweep plus a frame leak on
every CAPTURE click (`CDM.lua:1567`), and `spec=?` in every header (`CDM.lua:1455`).

**Read first:** `~/GloomsAuras/docs/HANDOFF.md` — both diagnosed there, with the fix for each.

---

## Not open — recorded so nobody re-raises them

> Full records in [ARCHIVE.md](ARCHIVE.md). Only what a session might realistically re-raise.

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
- **v1.2.0 release cut** — DONE. **A packaging failure on `repos.wowace.com` is an outage — re-run,
  don't debug.**
- **General Sans's redistribution terms** — **CLOSED by the owner 2026-07-26** without the Fontshare
  terms being read; the attribution ships in `Media/fonts/FONT-LICENSES.md`. Not a task.
- **The colour picker** — **FULLY owner-QA'd 2026-07-26, every path; nothing outstanding.** Two
  settled decisions inside it: the IN USE palette holds the colours the USER put on their own
  elements, **never** the suite's design tokens (it shipped that way first and was wrong), and it is
  deliberately **not modal** because it edits a live element. Don't re-propose either.
