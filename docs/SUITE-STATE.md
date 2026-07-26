# Gloom Suite — STATE

> **Where things stand. Settled facts only.**
>
> Nothing provisional belongs here — a guess written beside a fact inherits the fact's authority,
> which is exactly how a wrong conclusion nearly cost a day's work on 2026-07-26. Diagnosis lives in
> [FINDINGS.md](FINDINGS.md) with an evidence tag; open work lives in [BACKLOG.md](BACKLOG.md).
>
> **Keep this file short enough to re-read.** If it passes ~180 lines, move the settled history to
> [ARCHIVE.md](ARCHIVE.md). A document nobody re-reads is a document nobody corrects.

**Last updated:** 2026-07-26

---

## The one-paragraph answer

**The 7-phase plan is complete and QA'd. All four addons ship and install cleanly.** GloomsHub is the
shared base; Bars, Auras and Overlays each mount a tab in its window and hard-depend on it.
StoneTweaks is retired, all five repos are public under the **`GloomSuite`** org (Build Barn stayed
with `HandofDevastation`). What's left is in [BACKLOG.md](BACKLOG.md) — five items: three are 12.1
testing, one is a font-licence question, and one is finishing the release cut below.
**There is no known live bug in shipped code.**

**⚠ RELEASE STATE IS MID-CUT, 2026-07-26.** All four suite repos are **tagged `v1.2.0` on their
remotes** (a one-time squaring-up at the owner's request — *not* a new rule; drift is still
permitted, see the locked decision below). Only **Overlays actually published**, because it is the
one suite repo with no `.pkgmeta` externals. Bars, Auras and the Hub all failed at the packaging
step on **`repos.wowace.com` returning HTTP 500** — a third-party SVN outage, nothing to do with the
code. So the **published** state is: Overlays `v1.2.0` · Bars `v1.1.2` · Auras `v1.0.1` ·
**Hub: NO published release at all** (its two earlier ones were deleted in the PII purge).
**The tags are already pushed — finishing this is a re-run, not a re-tag.**

**★ The identity scrub was INCOMPLETE until 2026-07-26 and is now re-verified on a fourth surface.**
It had covered file contents and commit metadata; it had never covered **file paths**. A texture
named after the owner's real first name was public from the Hub's first commit. It was purged with
`git-filter-repo`, the repo was deleted and recreated, and the old commit returns **422** while the
repo is verifiably public. The user's three drop-in asset directories went with it. See
[LESSONS.md](LESSONS.md) — all four surfaces must be scanned, every time.

---

## Phase status — all seven done

| Phase | What | Status |
|---|---|---|
| **A** | Stand up GloomsHub, media only | ✅ QA'd 2026-07-24 |
| **B** | Tabbed shell + Media tab + `/gloom` | ✅ QA'd 2026-07-24 |
| **C** | Migrate Gloom's Bars; toolkit → `LibGloomSkin` | ✅ QA'd 2026-07-24 |
| **D** | Migrate Gloom's Auras | ✅ QA'd 2026-07-24 |
| **E** | VibeOverlay → Gloom's Overlays; mount + reskin | ✅ QA'd 2026-07-24 (two gates) |
| **F** | Retire StoneTweaks | ✅ QA'd 2026-07-24 |
| **G** | Packaging / release / WoWup | ✅ QA'd 2026-07-25 (install **and** update paths) |

Full QA evidence for every phase is in [ARCHIVE.md](ARCHIVE.md). Do not redo any of it.

---

## Locked decisions — do not reopen

- **Shared base = GloomsHub**, permanent asset path `Interface\AddOns\GloomsHub\…`.
- **Four separate addons + one shared base**, not a mega-addon. The Hub ships its own release.
- **HARD dependency on GloomsHub, no standalone fallback** (2026-07-24). Each tool deleted its own
  window; its config renders ONLY inside the Hub's shell. Chosen over graceful fallback precisely to
  avoid two window paths that could drift. A tool installed without the Hub fails **loudly**.
- **★ VERSIONS MAY DRIFT — release only the addon that changed** (2026-07-25). *"It doesn't bother
  me if the versions of the individual units drift."* The shell footer lists every installed addon's
  version, which is what retired the reason for synchronizing them.
  **Still true after the 2026-07-26 sync to `v1.2.0`** — the owner asked for a one-time squaring-up
  because the Hub's published releases had just been deleted in the PII purge, which would have left
  the shared base looking *older* than its own dependents. That was a tidy-up of a specific mess, not
  a standing requirement. Do not synchronize versions again by default.
- **★ EVERY `LibGloomSkin` CONSUMER CARRIES A VERSION GATE** — pinned in [CONTRACTS.md](CONTRACTS.md)
  §6. This is what makes drift safe. `## Dependencies: GloomsHub` checks only that the Hub is
  PRESENT, never that it is NEW ENOUGH — WoW's TOC system has no version constraint. Each consumer
  declares `SKIN_NEEDS` and returns early with one actionable line.
  **★ Bump `SKIN_NEEDS` in the SAME commit that first calls a newer widget** — the only way to
  defeat the gate is to forget.
- **One profile/preset mechanism for the whole suite** (2026-07-24) — `UI.profileBlock`, MINOR 3.
  **GB is the UI reference for the suite, not GA.** When a pattern exists in both, copy Bars.
- **No self-arming "click twice" confirms** (2026-07-24). Destructive actions use `UI.confirm`,
  which has a Cancel and an ESC.
- **StoneTweaks is fully retired**; its media half is the Hub's Media tab. The
  `StoneTweaks_ResolveAssetPath` compat shim in `Core.lua` is **KEPT PERMANENTLY** (CONTRACTS §3) —
  do not "clean it up."
- **VibeOverlay → Gloom's Overlays**, reskinned in one go. The `Vibe` name is retired; the slash
  is `/go`.
- **Gloom's Build Barn is OUT of the suite** — a data-fed cron pipeline, not a tab tool.
- **Never "v1" / "later phase" framing. GUI over slash for user controls.**

---

## What is physically in place

**`~/GloomsHub`** — symlinked into AddOns. `Core.lua` (namespace, `GloomsHubDB`, ST copy-migration,
the permanent compat shim, `/gh` probe) · `Skin.lua` (**the body of `LibGloomSkin-1.0`**, LibStub-
registered, **MINOR 5** — tokens, toolkit, `WarmFonts`/`RegisterWarmPairs`; `GloomsHub.COLOR/.FONT/
.UI/.MEDIA` are aliases) · `Shell.lua` (the Suite window: `RegisterTab`/`Open`/`FocusTab`/
`ToggleWindow` + `/gloom`) · `Media.lua` (LSM registration, `ResolveAssetPath`, `ListMedia`, the
Media tab) · `MinimapButton.lua` (**the ONE suite launcher** — never one per tool).

**Tracked assets are `Media/` ONLY** — Khand ×2, GeneralSans ×3, their licence files, the GS and Gh
marks. `Libs/` is gitignored and pulled by the packager. ⚠ **`Fonts/`, `Textures/` and `Graphics/`
are the USER's drop-in directories and are gitignored** (2026-07-26). They still exist on the
owner's disk — 7 / 13 / 45 files, which his catalog resolves normally — but they are not in the repo,
not in history, and not in any release. **Never track them.**

**`~/GloomsBars`** — `main`. Hard-deps the Hub; local toolkit and standalone window deleted; mounts
the **Bars** tab; `/gb` → `ToggleWindow("bars")`. `SKIN_NEEDS = 5` (its font picker branches on
`UI.setFont`'s return value).

**`~/GloomsAuras`** — `main`. Hard-deps the Hub; mounts the **Auras** tab, fully reworked 2026-07-25
(rail + full-width editor; splash, name banner and four drawers gone); `SKIN_NEEDS = 4`.

**`~/GloomsOverlays`** — `master`. Hard-deps the Hub; mounts the **Overlays** tab; frame pooling and
in-place layout apply; all nine stratas plus a numeric Level.
⚠ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys SavedVariables off
the addon FOLDER name; 23 save files were copied in place and **12 characters ride non-Default
profiles**. Renaming those globals is silent data loss, not cleanup.

**Live on the owner's account:** `GloomsHubDB` = 1 font / 6 textures / 36 graphics,
`migratedFromST = true`. The Hub is the only media registrar and wins all 7 LSM names with no
collision.

### ⚠ Two Desktop folders that must NOT be deleted
- **`~/Desktop/VibeOverlay-retired-2026-07-24`** — the ONLY copy of the pre-rename VibeOverlay
  source. Git never held it: GloomsOverlays' first commit already contains the renamed files.
- **`~/Desktop/StoneTweaks-retired-2026-07-24`** — 73 files. `StoneTweaksDB` was deliberately left
  in WTF, so rollback is just moving this folder back and re-enabling.

Both were identity-scanned and are clean.

---

## ⚠ Standing hazards

- **The dev symlinks and a WoWup install target the SAME folder names.** If an install QA is ever
  re-run on this machine, move the symlinks aside first and restore after — **and uninstall in
  WoWup BEFORE restoring them**, because WoWup's Remove deletes the folder it manages and could
  follow a symlink into live source.
- **All four addons point at their normal repos on BOTH the retail and PTR clients**, so an edit is
  live on both. Remember that before editing during PTR work.

---

## How to keep this honest

1. **Settled facts only.** Anything unproven goes in [FINDINGS.md](FINDINGS.md) with a tag.
2. **Closed work leaves.** When an item closes, its record moves to [ARCHIVE.md](ARCHIVE.md) — it
   does not accumulate here as another "before that…" clause.
3. **Point, never copy.** A cross-cutting fact restated in a second repo *will* go stale; release
   state was copied into three sibling docs and all three were wrong within a day.
4. **The handoff ritual maintains this file.** See the Hub's [CLAUDE.md](../CLAUDE.md).
