# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24.** Phases **A–F are DONE and QA'd** — all three tools render inside the
one Suite window and consume LibGloomSkin, and **StoneTweaks is retired**.

> ## ▶ NEXT SESSION = PHASE G (packaging/release). Briefing at the bottom of this file.
> **★ Phase G's blocker, found 2026-07-24: `GloomsHub` cannot publish a release at all** — it has no
> `.pkgmeta` and no `.github/workflows/release.yml`. Every tool declares `## Dependencies: GloomsHub`,
> and **`GloomsBars` v0.2.0 is already published, so it currently installs BROKEN via WoWup: it
> demands a Hub that has no release to install.** Fixing the Hub's packaging is job one.
>
> **Phase F is ✅ DONE — 2026-07-24, all 6 steps QA'd by the owner.** StoneTweaks is disabled AND its
> folder is out of AddOns (moved, not deleted, to `~/Desktop/StoneTweaks-retired-2026-07-24`); the Hub
> serves all media alone; the compat shim is live and proven and is **KEPT PERMANENTLY** (step 6,
> closed). `StoneTweaksDB` was left in WTF, so rollback is still just moving the folder back.
>
> **Task 0 (the identity scrub) is DONE — 2026-07-24.** All five repos were rewritten, verified
> clean, and re-published. **All five repos are PUBLIC again and WoWup delivery is restored.**
> The scrub is finished; read the Task 0 record below for the two traps and the big lesson (a
> force-push does NOT purge — the repos had to be deleted and recreated).

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
  (38 MB, later 71 MB), plus `GloomsBuildBarn-SERVER-TRUE.git` — which is what made trap 2
  recoverable. **These were DELETED on 2026-07-24** once every repo was public, verified clean and
  in sync, because they were the last copy of the old identity on disk. Take fresh backups before
  any future rewrite; there is no undo now.
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

### ★★★ THE BIG LESSON — a force-push does NOT purge, and a private repo hides that from you
Rewriting history unlinks the old commits; it does **not** delete them from GitHub. Proven on
2026-07-24:
- While the repos were PRIVATE, `GET /repos/…/commits/<old-sha>` returned **404**, which looked
  like a purge. **It was not.** A private repo 404s that endpoint for *any* SHA, valid or not —
  the test is meaningless while private.
- The instant the repos were flipped PUBLIC, those same pre-rewrite SHAs returned **200, serving
  the old identity in the author, committer and message fields.** Everything was flipped straight
  back to private (~2 minutes exposed).

**Rules that follow — do not relearn these the hard way:**
1. Never treat a force-push as a purge. The only reliable purge is **delete the repo and recreate
   it** (needs `gh auth refresh -h github.com -s delete_repo`).
2. Never validate a purge from a private repo. Verify **unauthenticated**, against the **public**
   repo, and expect **422** ("no commit found for SHA") — *not* 404, which means repo-not-found.
3. A brand-new repo has no leftovers, which is why recreate-and-push is airtight.

### How it was finished (2026-07-24)
`GloomsBars`, `GloomsAuras` and `GloomsBuildBarn` were **deleted and recreated**, then the scrubbed
history + tags pushed. `GloomsHub` and `GloomsOverlays` needed no recreation — they were created
that same day and only ever received scrubbed history. Re-pushing the tags made the BigWigs
packager rebuild every release asset from clean source. **All five repos are now PUBLIC**, so the
WoWup install/update path works again. Verified unauthenticated: pre-rewrite SHAs → 422, current
commits → 200, zero identity in commit metadata, messages, all-history blobs or release zips, and
org membership still private.

### Still open / watch out for
- **Release ZIPs need re-checking after any rewrite** — see trap 1 above.
- **Actions on a recreated repo:** the org disables write permissions for workflows by default, so
  `default_workflow_permissions` is `read`. That is fine *because* both `release.yml` files declare
  `permissions: contents: write` themselves. A workflow without that block will fail to publish.
  Also, tags pushed in the same breath as the initial branch push may land before the workflow is
  registered and silently trigger nothing — re-push the tags if no run appears.
- **GBB's `weekly-data.yml` only releases when the data CHANGED**, so `workflow_dispatch` on
  unchanged data is a no-op. To force a release, re-push the tag (fires `release.yml`).
- **★ Recreating releases out of order breaks "latest" — which is what WoWup installs.** After the
  recreate, GBB's latest resolved to `v2026.07.06` and GB's to `v0.0.1`, because the older tags were
  re-pushed last. Fixed with
  `gh api -X PATCH repos/<owner>/<repo>/releases/<id> -f make_latest=true`. **Always finish by
  checking `/releases/latest` anonymously** — and note that endpoint caches, so a stale answer may
  just need a re-read before you go chasing it.
- These repos were PUBLIC with the identity until 2026-07-24, so third-party mirrors of public
  GitHub event data are outside anyone's control. This scrub is forward-looking.
- `.claude/settings.json` `additionalDirectories` now reads `~/GloomsBars` etc. — confirm `~`
  expands there, or put absolute paths back.
- ⚠ **Never write the real name or the personal handle into these docs, even to describe the leak.**
  That happened once while documenting this very task and had to be scrubbed again. Say "the old
  identity".

### Known-good facts (verified 2026-07-24 — don't re-litigate)
- Org membership IS private (`/orgs/HandofDevastation/public_members/<handle>` → 404).
- Releases are authored by `github-actions[bot]`, not the owner's account.
- The leak path was git config → GitHub auto-linking commits by registered email. The org setup
  itself was fine; it simply never covered local commit metadata.
- WoWup's GitHub install path effectively needs a PUBLIC repo — private + PAT is reported broken.
  If public is ever unacceptable, the alternative is packaging to CurseForge/Wago instead.

---

# PHASE F — retire StoneTweaks ✅ STEPS 1–5 DONE (2026-07-24), one confirmation restart left

**Status:** steps 1–4 QA'd by the owner and step 5 executed. **StoneTweaks is disabled AND its folder
is out of AddOns** — moved to `~/Desktop/StoneTweaks-retired-2026-07-24` (73 files, count-verified).
**`StoneTweaksDB` in WTF was deliberately left in place**, so rollback is still just moving the folder
back and re-enabling. Outstanding: one full client restart with the folder physically gone (it was
removed mid-session, while ST was merely disabled), then step 6.

**Why it was unblocked:** Overlays was the suite's last StoneTweaks consumer, and Phase E gate A
moved it to `GloomsHub:ResolveAssetPath`. Nothing in the suite reads ST data any more.

1. ✅ **DONE + verified 2026-07-24.** Nothing references ST. The sweep covered all four suite repos
   **and the entire live AddOns folder** (105 addons): zero hits for `StoneTweaks_ResolveAssetPath`,
   `StoneTweaksDB`, `StoneTweaks_FrameDefs`, `CatStoneTweaks` outside ST's own three files. In the
   suite, the only *live-code* hits are the Hub's deliberate compat shim + copy-migration in
   `Core.lua` (CONTRACTS §3); every other hit is a comment or a doc line. Also verified offline:
   - `GloomsHubDB` and `StoneTweaksDB` hold **identical** catalogs (1 font / 6 textures / 36
     graphics, same name→file pairs) — ST registered nothing new since Phase A, so there is no
     second migration to run.
   - **All 43 catalog files exist under the Hub**, and `Fonts/` / `Textures/` / `Graphics/` are the
     **same file sets** in both addons — retiring ST loses no asset.
   - ST's ElvUI half is provably unused on this account (`frameTextures` empty, `suppressGlow`
     false), so disabling it kills nothing that was in service.
   - ⚠ Note for the Media tab: the catalog carries a leftover `test-remove` / `test-remove.png`
     graphic. It came from **ST** (it's in `StoneTweaksDB` too), not from Phase B QA. Harmless (the
     file exists), but it's clutter the owner may want to remove in the Media tab.
2. ✅ **DONE — QA'd by the owner 2026-07-24.** ST disabled + full client restart. Clean: BugSack empty,
   `Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.` present and unchanged, **zero
   `StoneTweaks:` lines**, **zero Hub-prefixed "skipped" lines**.
   ★ **`/st` no longer does anything — and that is the positive proof, not mere silence.** `/st` was
   registered by ST's own code; with ST off that code never runs, so the command cannot exist. Same
   for ST's `StoneTweaks loaded. Type /st to open the panel.` login line, which is absent.
   ⚠ Don't misread other addons' output: **ArcUI prints its own `SKIPPED …` lines** (`ArcUI:` prefix,
   about CDMGroups) that have nothing to do with media registration. Check the prefix.
3. ✅ **DONE — QA'd by the owner 2026-07-24.** Off the Hub alone: `/gh` → 1 font / 6 textures / 36
   graphics, `migratedFromST = true`; **Goldset overlays render on Gloomthorn**; all four tabs
   (Bars/Auras/Overlays/Media) open; Media tab previews draw for fonts, textures and graphics.
4. ✅ **DONE — the compat shim is LIVE and proven, 2026-07-24.**
   `StoneTweaks_ResolveAssetPath("goldset-player-frame")` → `Interface\AddOns\GloomsHub\Graphics\goldset-player-frame.png`
   (a global only ST ever defined, now answered by Core.lua's shim). Both resolver branches verified
   (`goldset-texture` → `…\Textures\…`), and `LSM:HashTable("font").DrukMedium` → `…\GloomsHub\Fonts\DrukMedium.ttf`.
   ★ **Read the registered LSM table, never `LSM:Fetch`** — `Fetch` silently returns WoW's default
   font for a missing name, which reads as a false pass.
   ★★ **WoW's chat edit box truncates at 255 characters, and `!BugGrabber` swallows the resulting
   syntax error so the command appears to do NOTHING.** A 360-char `/run` one-liner was lost exactly
   this way during QA. Keep QA commands short — prefer several `/dump` one-liners (~50–90 chars) over
   one long `/run`.
   ★ **But check the PREFIX, not the wording** — the Hub's `Media.lua` prints a
   *word-for-word identical* "Font/Texture skipped — … is already registered" line (`GloomsHub:Print`,
   so it reads **`Gloom's Hub:`** instead of **`StoneTweaks:`**). Today the Hub loads first, wins the
   LSM names, and ST prints 7 skip lines. So the exact expectation after disabling ST is:
   - **`Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.`** — unchanged, still there.
   - **Zero `StoneTweaks:` lines** (that's the retirement working).
   - **Zero `Gloom's Hub: … skipped` lines.** A Hub-prefixed skip line is NOT a leftover — it means a
     *third-party* addon claimed that LSM name first (`EnhanceQoLSharedMedia` and `EllesmereUI` are
     both installed). That would be a real collision to chase, not the transition artifact.
5. ✅ **DONE 2026-07-24 — moved, not deleted.** `…/AddOns/StoneTweaks` →
   `~/Desktop/StoneTweaks-retired-2026-07-24`, 73 files before and after. `StoneTweaksDB` left in WTF.
   **Still to do: one full client restart** to confirm the client is happy with the folder physically
   absent (it was moved while the client was running and ST merely disabled).
   ⚠ **`~/Desktop/VibeOverlay-retired-2026-07-24` is NOT a safe delete, and the owner chose to KEEP
   it (2026-07-24)** — despite what this file used to say. **Git never held the pre-rename
   originals:** GloomsOverlays' *first* commit (`5be4b1b`) already contains the renamed
   `GloomsOverlays*.lua` files, and no `Vibe`-named file appears anywhere in that repo's history.
   That Desktop folder is therefore the **only copy of the original VibeOverlay source** (96 KB).
   Leave it alone; it is not cleanup debt.
   (Both unscrubbed folders were identity-scanned and are clean: `## Author: You` and
   `## Author: StoneTweaks`, zero hits for the old identity. The "no copy of the old identity remains
   on disk" claim in TASK 0 still holds.)
6. ✅ **DONE — CLOSED by the owner 2026-07-24: KEEP THE SHIM PERMANENTLY.** One line, zero cost,
   proven working, and nothing in the suite calls it — pure insurance for anything stale outside the
   suite. Pinned in CONTRACTS §3 and commented in `Core.lua`. **Do not "clean it up" in Phase G.**

**Phase F is closed.** Nothing carries over from it. Phase G's briefing is at the bottom of this file.

### Two QA lessons from Phase F worth keeping
1. **★ WoW's chat edit box truncates at 255 characters, and `!BugGrabber` swallows the resulting Lua
   syntax error — so an over-long command appears to do NOTHING AT ALL.** A 360-char `/run` one-liner
   was lost exactly this way and read as "doesn't do anything." Keep QA commands short: prefer several
   `/dump` one-liners (~50–90 chars) over one long `/run`. Measure before sending.
2. **★ Never verify an LSM registration with `LSM:Fetch`** — it silently returns WoW's *default* font
   for a missing name, so a failure reads as a pass. Read the registered table instead:
   `LibStub("LibSharedMedia-3.0"):HashTable("font").<Name>`.
3. **Absence of a slash command is real proof.** `/st` going dead proved ST's code never loaded —
   stronger evidence than the absence of its login print, and much stronger than mere silence.
4. **Check the PREFIX on every login line.** ArcUI prints its own `SKIPPED …` lines about CDMGroups
   that look alarming and are unrelated. The Hub's own skip-line wording is word-for-word identical
   to StoneTweaks'.

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

---

# PHASE G — packaging / release ◀ THIS IS THE NEXT JOB (SUITE-PLAN §5.G)

**Ground surveyed 2026-07-24. Read this before touching anything — two plan items are wrong.**

## ★ The blocker: the Hub cannot publish, and that breaks an already-published tool
| Repo | `.pkgmeta` | `release.yml` | Releases on GitHub |
|---|---|---|---|
| **GloomsHub** | ❌ **absent** | ❌ **absent** | ❌ **none** |
| GloomsBars | ✅ | ✅ | ✅ `v0.2.0` (latest), `v0.1.0`, `v0.0.1` |
| GloomsAuras | ✅ | ❌ absent | ❌ none |
| GloomsOverlays | ❌ absent | ❌ absent | ❌ none |
| GloomsBuildBarn *(not suite)* | ✅ | ✅ | ✅ 5 dated tags, latest `v2026.07.21` |

All three tools declare `## Dependencies: GloomsHub`. **`GloomsBars` v0.2.0 is public, so it installs
BROKEN via WoWup today** — it demands a Hub with no release to install. **Ship the Hub first.**
(Release "latest" pointers were re-verified via `gh` and are correct on both repos that have releases,
so the TASK 0 `make_latest` fix held.)

## ★★ DROP the plan's "embed LibGloomSkin as an external per tool"
SUITE-PLAN §5.G says to embed `LibGloomSkin-1.0` in each tool via `.pkgmeta` externals. **That item
predates the hard-dependency lock and should not be done:**
- **No tool ships or loads its own copy today** — verified: nothing in GB/GA/Overlays' TOCs
  references it. All three simply call `LibStub("LibGloomSkin-1.0")` and resolve to the Hub's
  `Skin.lua`, which IS the lib body.
- The **hard dependency guarantees the Hub is present**, so there is nothing to insure against.
- Embedding would create N copies for LibStub to arbitrate by MINOR — **exactly the drift the suite
  exists to prevent**, and it would silently split the "ONE copy" rule in CLAUDE.md.
- There is **no standalone LibGloomSkin repo** to fetch as an external anyway; the plan's line is not
  implementable as written.

→ Consume from the Hub. If a *future* non-suite consumer ever needs it, publish it properly then.

## The actual work
1. **`GloomsHub/.pkgmeta`** — copy `GloomsBars/.pkgmeta` as the shape (GitHub Releases only, no
   CurseForge/Wago). `package-as: GloomsHub`; `enable-nolib-creation: no`; externals for the Hub's
   five libs (LibStub, CallbackHandler-1.0, **LibSharedMedia-3.0**, **LibDataBroker-1.1**,
   **LibDBIcon-1.0** — the Hub needs all five per its TOC, more than GB does); `ignore:` README,
   CLAUDE.md, .github, .gitignore, .pkgmeta, docs, tools.
   ⚠ **Do NOT ignore `Fonts/`, `Textures/`, `Graphics/` or `Media/`** — unlike the other repos, the
   Hub's committed assets ARE the product (43 catalog files + the GS/GO marks + 5 UI fonts).
2. **`GloomsHub/.github/workflows/release.yml`** — copy GB's. ★ **It MUST declare
   `permissions: contents: write`**: the org sets `default_workflow_permissions: read`, so a workflow
   without that block fails to publish (recorded under TASK 0).
3. **`GloomsOverlays/.pkgmeta` + `release.yml`**, and **`GloomsAuras/release.yml`** (GA already has
   `.pkgmeta`).
4. **Cut the Hub's first release, then re-cut the tools.** Version strings render literally as
   `@project-version@` until a packaged build exists — that is expected, not a bug.
5. **Document the one-time WoWup step** (add each GitHub repo URL) for the friends/guild audience.
6. *QA:* fresh WoWup install of GloomsHub + one tool on a clean profile; then an update cycle.

## Packaging traps already learned the hard way (full detail under TASK 0)
- **Tags pushed in the same breath as the initial branch push can land before the workflow is
  registered and silently trigger nothing.** If no run appears, re-push the tag.
- **Recreating/pushing releases out of order breaks `latest` — which is what WoWup installs.** Always
  finish by checking `/releases/latest` **anonymously**; that endpoint caches, so re-read a stale
  answer before chasing it. Fix with `gh api -X PATCH repos/<owner>/<repo>/releases/<id> -f make_latest=true`.
- **Published release ZIPs are a separate surface** from git history — after any rewrite, download and
  grep the assets.
- ⚠ **`.claude/settings.json` `additionalDirectories` uses `~`** — confirm it expands, or restore
  absolute paths.
