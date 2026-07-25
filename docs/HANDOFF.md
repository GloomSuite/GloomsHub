# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases **A–E are DONE and QA'd** — all three tools render inside the
one Suite window and consume LibGloomSkin.

> ## ▶ NEXT SESSION = PHASE F (retire StoneTweaks).
> **Task 0 (the identity scrub) is DONE — 2026-07-24.** All five repos were rewritten, verified
> clean on fresh clones *from GitHub*, and force-pushed. **Every repo is still PRIVATE** — nothing
> was flipped public. Read the Task 0 record below before considering any flip, and note the open
> item about Build Barn's WoWup delivery.

## Orientation (read in this order)
1. This file.
2. [../CLAUDE.md](../CLAUDE.md) — **the PRIVACY block is mandatory reading** before you write a
   single line of doc, comment or commit message.
3. [SUITE-STATE.md](SUITE-STATE.md) — the phase ledger + locked decisions + the polish backlog.
4. [SUITE-PLAN.md](SUITE-PLAN.md) · [CONTRACTS.md](CONTRACTS.md) — architecture; shared contracts.

---

## ★ Working agreements (learned the hard way — do not repeat these)

1. **QA as you go. Do NOT build a mountain and hand it over.** Phase E gate B was written in one
   stretch across three addons before the owner saw a single pixel. Design check-ins are not
   verification. Get something on screen early, then iterate in small steps.
2. **Two identities to protect, not one:** the owner's real name/email AND his personal GitHub
   handle. See the CLAUDE.md privacy block. Do not "helpfully" set a git identity to a
   `…@users.noreply.github.com` address — those embed the handle.
3. **GB is the UI reference for the suite, not GA.** Copy Gloom's Bars when a pattern exists in both.
4. **No self-arming "click twice" confirms.** Destructive actions use `UI.confirm`.
5. **US spelling** in user-visible text ("Favorites", "color").
6. QA is ONE copy-paste step at a time; verify before claiming; **BugSack text first**. New
   files/assets → FULL CLIENT RESTART. Lua-only edits → `/reload`.

---

# TASK 0 — THE IDENTITY SCRUB ✅ DONE (2026-07-24)

**What it was:** the owner's real name + personal email, *and* his personal GitHub handle, were
present across all five repos — in file content, in commit messages, and in author/committer
metadata. Flipping the repos PRIVATE on 2026-07-24 contained it; this rewrite removed it.

### How it was done
- **Backups first:** `git clone --mirror` of all five → `~/glooms-scrub-backups-2026-07-24/`
  (38 MB), plus `GloomsBuildBarn-SERVER-TRUE.git` (see trap 2). ⚠ **These backups still contain
  the old identity — they are the undo, and must never be pushed anywhere.**
- **Tool:** `git-filter-repo` 2.47.0 (`brew install git-filter-repo`).
- **Rules:** one replacements file used for BOTH `--replace-text` (blobs) and `--replace-message`
  (commit messages), plus a `--mailmap` mapping the old name/email **and** the handle's
  `…@users.noreply.github.com` address → `Gloom <gloom@handofdevastation.invalid>`.
- Attribution by first name → "the owner" / "the owner's"; `/Users/<handle>/` → `~/`; the personal
  handle → "the org admin account". Sentence-start forms were re-capitalized.

### Verified — every gate ZERO, on fresh mirror clones *from GitHub*

| Repo | commits | author/committer | messages | all-history blobs | HEAD files |
|---|---|---|---|---|---|
| GloomsHub | 17 | 0 | 0 | 0 | 0 |
| GloomsOverlays | 3 | 0 | 0 | 0 | 0 |
| GloomsBars | 124 | 0 | 0 | 0 | 0 |
| GloomsAuras | 44 | 0 | 0 | 0 | 0 |
| GloomsBuildBarn | 7 | 0 | 0 | 0 | 0 |

Every author *and* committer across all history is now `Gloom <gloom@handofdevastation.invalid>`
(plus `github-actions[bot]` on Build Barn's cron commits — correct, leave it). `StoneTweaks` /
`StoneCast` names and the `VibeOverlayDB` / `VibeOverlayDBChar` SavedVariables globals were NOT
touched; all 25 Lua files pass `luac -p`; no binary asset contained the identity.

### ★★ Two traps this hit — DO NOT REPEAT
1. **Release ZIPs are a SEPARATE surface a force-push cannot reach.** GloomsBars' three published
   release zips contained the name — in `Core.lua` and in a packager-generated `CHANGELOG.md`
   built from commit messages. Force-pushing the rewritten **tags** re-triggered the BigWigs
   packager, which rebuilt all three assets from scrubbed source (new asset IDs, re-verified 0
   hits). **After ANY history rewrite, download and grep the release assets.**
2. **★ Build Barn's REMOTE was AHEAD of the local clone.** Its cron commits `BuildData.lua` and
   tags a dated release *directly on GitHub*, so `~/Desktop/glooms-build-barn` was missing three
   "Weekly data refresh" commits and three tags. Scrubbing the stale local copy and force-pushing
   it rolled `main` back from 2026-07-21 to 2026-07-06. Recovered from the surviving tags, rebuilt
   from the true server history, re-pushed; `BuildData.lua` verified byte-identical to the
   pre-scrub published asset — nothing lost. **ALWAYS `git fetch --all --tags` before rewriting a
   repo that has automation writing to it.**

### Still open (deliberately NOT done)
- **Nothing was made public.** All five repos remain PRIVATE.
- **Old commits may linger on GitHub addressable by SHA.** A force-push leaves the pre-rewrite
  objects unreachable but not necessarily purged. The airtight version is delete-and-recreate,
  which needs a `delete_repo` scope the `gh` token lacks
  (`gh auth refresh -h github.com -s delete_repo`). Bars/Auras would be cheap to recreate — their
  releases regenerate automatically from a tag push. **Build Barn must NOT be deleted.**
- These repos were PUBLIC with the identity until 2026-07-24, so third-party mirrors of public
  GitHub event data are outside anyone's control. This scrub is forward-looking.
- `.claude/settings.json` `additionalDirectories` now reads `~/GloomsBars` etc. — confirm `~`
  expands there, or put absolute paths back.

### ⚠ THE PUBLIC QUESTION — Build Barn is currently undeliverable
GBB is installed by guild members **via WoWup through GitHub**, which reads Releases through the
API; a PRIVATE repo returns 404 to them. **GBB has been undeliverable to the guild since it was
flipped private on 2026-07-24** — the cron still runs and still publishes releases, but nobody can
fetch them. GBB is now fully scrubbed *and* its release zips are verified clean, so it is safe to
make public again — but the privacy block requires an explicit instruction from the owner, so it
was left private. Same applies to GB/GA/Hub/Overlays for the Phase G WoWup path.

### Known-good facts (verified 2026-07-24 — don't re-litigate)
- Org membership IS private (`/orgs/HandofDevastation/public_members/<handle>` → 404).
- Releases are authored by `github-actions[bot]`, not the owner's account.
- The leak path was git config → GitHub auto-linking commits by registered email. The org setup
  itself was fine; it simply never covered local commit metadata.
- WoWup's GitHub install path effectively needs a PUBLIC repo — private + PAT is reported broken.
  If public is ever unacceptable, the alternative is packaging to CurseForge/Wago instead.

---

# PHASE F — retire StoneTweaks (after Task 0; SUITE-PLAN §5.F)

**Why it's unblocked:** Overlays was the suite's last StoneTweaks consumer, and Phase E gate A
moved it to `GloomsHub:ResolveAssetPath`. Nothing in the suite reads ST data any more.

1. Confirm nothing references ST: grep all four suite repos for `StoneTweaks`, `CatStoneTweaks`,
   `StoneTweaksDB`, `StoneTweaks_ResolveAssetPath`. The only expected hit is the Hub's deliberate
   compat shim (CONTRACTS §3).
2. **Disable** StoneTweaks in the addon list (do not delete the folder) → full client restart.
3. Verify off the Hub alone: fonts still serve (DrukMedium), textures + graphics still resolve, the
   Media tab catalog still reads 1 font / 6 textures / 36 graphics, and **overlays still render** —
   including on a `Goldset` character (Gloomthorn).
4. The compat shim goes LIVE here (ST's real resolver is gone). Confirm the "skipped — already
   registered" login lines are gone too; those were ST's own code.
5. Only after sign-off: move the ST folder out of AddOns (**move to Desktop, don't delete** —
   mirrors gate A). `~/Desktop/VibeOverlay-retired-2026-07-24` can be deleted at that point too.
6. Decide the compat shim's lifetime (SUITE-PLAN §6 open question).

**Then G** = packaging/release: `.pkgmeta`, embed LibGloomSkin as an external per tool, Releases,
WoWup. Version strings show literally as `@project-version@` until then.

---

## Where Phase E landed (do NOT redo any of this)
- **`~/GloomsOverlays`** — the `overlays` tab (order 30): a 240 left rail (GO mark + wordmark ·
  shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, plus an
  in-tab footer (Save & Apply + status). Asset browser is a 360-wide docked drawer opened from the
  Texture field's **Browse…**; "Use This Texture" returns the pick. Bare `/go` toggles the tab.
  Zero native chrome remains.
- **LibGloomSkin → MINOR 3**: `UI.dropdown` + `UI.flyout`, `UI.nameDialog`, `UI.confirm`,
  `UI.profileBlock`. GB's and GA's private copies are DELETED — GB's rail (profile + preset) and
  GA's profiles drawer both drive the shared block.
- ★ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys SavedVariables
  off the addon FOLDER name; 23 files were copied in place at gate A and **12 characters ride
  non-Default profiles**. Renaming those globals silently resets it.

## Polish backlog — in SUITE-STATE; don't start it mid-phase
The **Auras tab layout rework** (its own session), and **Overlays' Width / Height / X / Y should be
sliders, not typed boxes**.

## Other reminders
- ONE minimap launcher for the suite (the Hub's GS button) — never one per tool.
- Locked decisions (full list in SUITE-STATE): hard dependency, no fallback windows; Build Barn is
  OUT; never "v1"/"later phase" framing; GUI over slash.
- **macOS `sed` has no `\b`.** Verify identifier renames with a token count, and `luac -p` every
  touched Lua file.
