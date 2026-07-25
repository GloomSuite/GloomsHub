# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases **A–E are DONE and QA'd** — all three tools render inside the
one Suite window and consume LibGloomSkin.

> ## ⛔ NEXT SESSION = TASK 0 (THE IDENTITY SCRUB), NOT PHASE F.
> Phase F (retire StoneTweaks) is ready to go and is described below, but **Task 0 outranks it**.
> Every repo is PRIVATE right now, which is the only reason nothing is exposed. Distribution
> (BigWigs packager → GitHub Releases → WoWup) needs them PUBLIC, and they cannot go public until
> the scrub is finished. Do Task 0 first, on a fresh head, with backups.

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

# TASK 0 — THE IDENTITY SCRUB (blocking; do this first)

**Why:** the owner's real name and personal email were exposed on three then-public repos. They
were flipped PRIVATE on 2026-07-24, which contained it. The global git identity is now
`Gloom <gloom@handofdevastation.invalid>`, so *new* commits are clean — but history is not.
Nothing may be published until this is done.

### The three surfaces (measured 2026-07-24, all five repos)

| Repo | author/committer fields w/ old email | "the owner" in HEAD files | commit messages w/ name |
|---|---|---|---|
| GloomsBars | 248 | 212 | 37 |
| GloomsAuras | 88 | 90 | 7 |
| GloomsHub | 30 | 48 | 11 |
| GloomsOverlays | 6 | 5 | 3 |
| glooms-build-barn | 8 | 0 | 0 |
| **total** | **380** | **355** | **58** |

Paths: `~/GloomsHub`, `~/GloomsOverlays`, `~/GloomsBars`, `~/GloomsAuras`,
`~/Desktop/glooms-build-barn`.

### Steps

1. **Back up first — non-negotiable.** `git clone --mirror` each of the five somewhere outside the
   working dirs (~38 MB total). A history rewrite is not undoable without this.
2. **Install the tool:** `git-filter-repo` is NOT installed (`brew install git-filter-repo`).
3. **Content + commit messages.** Write a replacements file (the owner's first name, last name,
   full name, and `gloom@handofdevastation.invalid` → neutral text such as "the owner"), then per repo:
   `git filter-repo --replace-text <file>` for blob content, plus `--message-callback` for the 58
   commit messages. Mind case variants and possessives ("the owner's").
4. **Author/committer metadata.** A `--mailmap` file mapping the old name/email →
   `Gloom <gloom@handofdevastation.invalid>` covers all 380 fields.
5. **Verify before pushing.** In every repo, both must return zero:
   - `git log --format='%an%n%ae%n%cn%n%ce' | grep -ci 'owner\|redacted'`
   - `git grep -i owner $(git rev-list --all) -- | wc -l` (or `--replace-text` dry-run equivalent)
   Also re-check nothing reintroduced the personal GitHub handle anywhere.
6. **Re-add remotes and force-push** Bars, Auras, Build Barn (filter-repo drops `origin` on
   purpose — re-add it). This rewrites published history; the repos are private and single-author,
   so there is no one to coordinate with.
7. **Create the two missing repos** — `HandofDevastation/GloomsHub` and
   `HandofDevastation/GloomsOverlays` do not exist yet, and neither has a remote. Create them
   PRIVATE first, push, verify clean, then flip.
8. **Only then** flip whichever repos need to be public for WoWup. Confirm afterwards that
   releases still show `github-actions[bot]` as author (they did before) and that org membership
   is still private.

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
